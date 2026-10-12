import 'package:flutter/material.dart';

import '../../app_state.dart';
import '../../core/money.dart';
import '../../data/menu_models.dart';
import '../../ui/common.dart';
import 'menu_widgets.dart';
import 'menus_screen.dart';

/// Groupes d'options proposés avec les articles (accompagnement, cuisson,
/// sauces…) et leurs choix, avec le prix de chaque choix.
class OptionsScreen extends StatefulWidget {
  const OptionsScreen({super.key, required this.board});
  final MenuBoardContext board;

  @override
  State<OptionsScreen> createState() => _OptionsScreenState();
}

class _OptionsScreenState extends State<OptionsScreen> {
  Key _key = UniqueKey();

  MenuBoardContext get b => widget.board;

  Future<(List<ModifierGroup>, BranchMenuState)> _load() async {
    final api = AppScope.read(context).api!.menu;
    final r = await Future.wait<dynamic>([api.load(b.brand.id), api.branchState(b.branch.id!)]);
    return ((r[0] as BrandMenu).groups, r[1] as BranchMenuState);
  }

  Future<void> _open(BranchMenuState state, [ModifierGroup? group]) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => _GroupSheet(board: b, state: state, group: group)),
    );
    if (changed == true) setState(() => _key = UniqueKey());
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return Loader<(List<ModifierGroup>, BranchMenuState)>(
      key: _key,
      load: _load,
      builder: (context, data, _) {
        final (groups, state) = data;
        final locale = Localizations.localeOf(context).toString();
        return Scaffold(
          appBar: AppBar(title: Text(t.optionsTitle)),
          floatingActionButton: b.canCatalog
              ? FloatingActionButton.extended(
                  onPressed: () => _open(state), icon: const Icon(Icons.add), label: Text(t.newOptionGroup))
              : null,
          body: ListView(padding: const EdgeInsets.fromLTRB(16, 16, 16, 96), children: [
            FormWidth(maxWidth: 900, child: Text(t.optionsIntro)),
            const SizedBox(height: 8),
            if (groups.isEmpty) FormWidth(maxWidth: 900, child: Text(t.noOptionsYet)),
            for (final g in groups)
              FormWidth(
                maxWidth: 900,
                child: Card(
                  child: ListTile(
                    title: Text(g.active ? g.name : '${g.name} · ${t.hidden}'),
                    subtitle: Text([
                      optionRuleLabel(t, g.minSelect, g.maxSelect),
                      g.modifiers.where((m) => m.active).map((m) {
                        final p = state.prices[(m.id, 'default')];
                        return p == null || p == 0 ? m.name : '${m.name} (+${Money(p, b.currency).format(locale, b.minorUnit)})';
                      }).join(', '),
                    ].join(' · ')),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _open(state, g),
                  ),
                ),
              ),
          ]),
        );
      },
    );
  }
}

class _ChoiceDraft {
  _ChoiceDraft({this.id, String name = '', String price = ''})
      : name = TextEditingController(text: name),
        price = TextEditingController(text: price);

  String? id;
  final TextEditingController name;
  final TextEditingController price;
  bool active = true;
}

class _GroupSheet extends StatefulWidget {
  const _GroupSheet({required this.board, required this.state, this.group});
  final MenuBoardContext board;
  final BranchMenuState state;
  final ModifierGroup? group;

  @override
  State<_GroupSheet> createState() => _GroupSheetState();
}

class _GroupSheetState extends State<_GroupSheet> {
  final _form = GlobalKey<FormState>();
  late final b = widget.board;
  late final g = widget.group;
  late final _name = TextEditingController(text: g?.name);
  late int _min = g?.minSelect ?? 1;
  late int? _max = g == null ? 1 : g!.maxSelect;
  late bool _visible = g?.active ?? true;
  late final List<_ChoiceDraft> _choices = g == null
      ? [_ChoiceDraft(), _ChoiceDraft()]
      : [
          for (final m in g!.modifiers.where((m) => m.active))
            _ChoiceDraft(
                id: m.id, name: m.name, price: amountText(widget.state.prices[(m.id, 'default')], b.currency, b.minorUnit)),
        ];

  @override
  void dispose() {
    _name.dispose();
    for (final c in _choices) {
      c.name.dispose();
      c.price.dispose();
    }
    super.dispose();
  }

  Future<void> _translate({Modifier? modifier}) async {
    final changes = await editTranslations(
      context,
      title: modifier?.name ?? g!.name,
      current: modifier?.translations ?? g!.translations,
    );
    if (changes == null || changes.isEmpty || !mounted) return;
    final api = AppScope.read(context).api!.menu;
    try {
      for (final e in changes.entries) {
        await api.saveTranslation(
          table: modifier == null ? 'modifier_group_translations' : 'modifier_translations',
          keyColumn: modifier == null ? 'group_id' : 'modifier_id',
          orgId: b.orgId,
          entityId: modifier?.id ?? g!.id,
          locale: e.key,
          name: e.value.$1,
        );
      }
      if (mounted) showInfo(context, context.t.saved);
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  Future<void> _save() async {
    final t = context.t;
    if (!_form.currentState!.validate()) return;
    final active = _choices.where((c) => c.active && c.name.text.trim().isNotEmpty).toList();
    if (active.isEmpty) {
      showInfo(context, t.choicesRequired);
      return;
    }
    final api = AppScope.read(context).api!.menu;
    try {
      var groupId = g?.id;
      if (b.canCatalog) {
        if (groupId == null) {
          groupId = uuidV4();
          await api.saveGroup(
              orgId: b.orgId, brandId: b.brand.id, newId: groupId, name: _name.text, minSelect: _min, maxSelect: _max);
        } else {
          await api.saveGroup(
              orgId: b.orgId,
              brandId: b.brand.id,
              id: groupId,
              name: _name.text,
              minSelect: _min,
              maxSelect: _max,
              active: _visible);
        }
        final before = {for (final m in g?.modifiers ?? const <Modifier>[]) m.id: m};
        for (final c in _choices) {
          final name = c.name.text.trim();
          if (c.id == null) {
            if (!c.active || name.isEmpty) continue;
            c.id = uuidV4();
            await api.saveModifier(orgId: b.orgId, brandId: b.brand.id, groupId: groupId, newId: c.id, name: name);
          } else {
            final m = before[c.id];
            final keep = c.active && name.isNotEmpty;
            if (m == null || m.name != name || m.active != keep) {
              await api.saveModifier(
                  orgId: b.orgId, brandId: b.brand.id, groupId: groupId, id: c.id, name: keep ? name : m?.name ?? name, active: keep);
            }
          }
        }
      }
      if (b.canBranch) {
        for (final c in _choices.where((c) => c.active && c.id != null && c.name.text.trim().isNotEmpty)) {
          final amount = parseAmount(c.price.text, b.currency, b.minorUnit);
          if (amount == widget.state.prices[(c.id!, 'default')]) continue;
          await api.setPrice(branchId: b.branch.id!, modifierId: c.id, channel: 'default', amountMinor: amount);
        }
      }
      if (!mounted) return;
      showInfo(context, t.saved);
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final canCatalog = b.canCatalog;
    final rule = OptionRule.of(_min, _max);
    return Scaffold(
      appBar: AppBar(
        title: Text(g?.name ?? t.newOptionGroup),
        actions: [
          if (g != null && canCatalog)
            IconButton(tooltip: t.translations, icon: const Icon(Icons.translate), onPressed: () => _translate()),
        ],
      ),
      body: Form(
        key: _form,
        child: ListView(padding: const EdgeInsets.fromLTRB(24, 16, 24, 32), children: [
          FormWidth(
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              TextFormField(
                controller: _name,
                enabled: canCatalog,
                maxLength: 80,
                decoration: InputDecoration(labelText: t.optionGroupName, hintText: t.optionGroupExamples),
                validator: (v) => (v == null || v.trim().isEmpty) ? t.fieldRequired : null,
              ),
              const SizedBox(height: 8),
              Text(t.customerMust, style: Theme.of(context).textTheme.titleSmall),
              RadioGroup<OptionRule>(
                groupValue: rule,
                onChanged: (r) {
                  if (!canCatalog || r == null) return;
                  setState(() {
                    _min = r.min;
                    _max = r.max;
                  });
                },
                child: Column(children: [
                  for (final r in OptionRule.values)
                    RadioListTile<OptionRule>(
                      contentPadding: EdgeInsets.zero,
                      value: r,
                      enabled: canCatalog,
                      title: Text(optionRuleLabel(t, r.min, r.max)),
                    ),
                ]),
              ),
              if (rule == null) Text(optionRuleLabel(t, _min, _max)),
              if (g != null && canCatalog)
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(t.visibleOnMenu),
                  value: _visible,
                  onChanged: (v) => setState(() => _visible = v),
                ),
              const SizedBox(height: 16),
              Text(t.choices, style: Theme.of(context).textTheme.titleMedium),
              Text(t.choicePriceHint(b.branch.name), style: Theme.of(context).textTheme.bodySmall),
              const Divider(),
              for (final c in _choices.where((c) => c.active))
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Wrap(spacing: 12, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
                    SizedBox(
                      width: 220,
                      child: TextField(
                        controller: c.name,
                        enabled: canCatalog,
                        maxLength: 80,
                        decoration: InputDecoration(isDense: true, counterText: '', labelText: t.choiceName, hintText: t.choiceExamples),
                      ),
                    ),
                    AmountField(
                      controller: c.price,
                      label: t.extraPrice,
                      currency: b.currency,
                      minorUnit: b.minorUnit,
                      enabled: b.canBranch,
                      width: 150,
                    ),
                    if (canCatalog)
                      IconButton(
                        tooltip: t.removeChoice,
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () => setState(() => c.active = false),
                      ),
                    if (canCatalog && c.id != null)
                      IconButton(
                        tooltip: t.translations,
                        icon: const Icon(Icons.translate),
                        onPressed: () => _translate(modifier: g!.modifiers.firstWhere((m) => m.id == c.id)),
                      ),
                  ]),
                ),
              if (canCatalog)
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TextButton.icon(
                    onPressed: () => setState(() => _choices.add(_ChoiceDraft())),
                    icon: const Icon(Icons.add),
                    label: Text(t.addChoice),
                  ),
                ),
              const SizedBox(height: 24),
              if (canCatalog || b.canBranch) BusyButton(label: t.save, onPressed: _save) else Text(t.readOnly),
            ]),
          ),
        ]),
      ),
    );
  }
}
