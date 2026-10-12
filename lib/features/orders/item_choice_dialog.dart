import 'package:flutter/material.dart';

import '../../data/menu_models.dart';
import '../../ui/common.dart';
import '../menus/menu_widgets.dart';

class ItemChoice {
  ItemChoice(this.variantId, this.modifierIds, this.quantity, this.note);
  final String variantId;
  final List<String> modifierIds;
  final int quantity;
  final String? note;
}

/// Choix de la taille, des options, de la quantité et d'une remarque pour la
/// cuisine. Les règles sont vérifiées ici pour guider, puis par le serveur.
class ItemChoiceDialog extends StatefulWidget {
  const ItemChoiceDialog({
    super.key,
    required this.item,
    required this.variants,
    required this.groups,
    required this.priceOf,
    required this.money,
  });

  final MenuItem item;
  final List<ItemVariant> variants;
  final List<ModifierGroup> groups;
  final int? Function(String id) priceOf;
  final String Function(int minor) money;

  @override
  State<ItemChoiceDialog> createState() => _ItemChoiceDialogState();
}

class _ItemChoiceDialogState extends State<ItemChoiceDialog> {
  late String _variantId = widget.variants.first.id;
  final _selected = <String, Set<String>>{}; // groupe → choix
  final _note = TextEditingController();
  int _quantity = 1;
  bool _tried = false;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  List<Modifier> _choices(ModifierGroup g) => g.modifiers.where((m) => m.active).toList();

  bool _groupOk(ModifierGroup g) {
    final n = (_selected[g.id] ?? const {}).length;
    return n >= g.minSelect && (g.maxSelect == null || n <= g.maxSelect!);
  }

  int get _unit {
    var total = widget.priceOf(_variantId) ?? 0;
    for (final ids in _selected.values) {
      for (final id in ids) {
        total += widget.priceOf(id) ?? 0;
      }
    }
    return total;
  }

  void _toggle(ModifierGroup g, String id, bool on) {
    setState(() {
      final set = _selected.putIfAbsent(g.id, () => {});
      if (g.maxSelect == 1) set.clear();
      if (on) {
        if (g.maxSelect == null || set.length < g.maxSelect!) set.add(id);
      } else {
        set.remove(id);
      }
    });
  }

  String _optionLabel(Modifier m) {
    final p = widget.priceOf(m.id) ?? 0;
    return p > 0 ? '${m.name} (+${widget.money(p)})' : m.name;
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final scheme = Theme.of(context).colorScheme;
    return AlertDialog(
      title: Text(widget.item.name),
      content: SizedBox(
        width: 460,
        child: SingleChildScrollView(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (widget.item.description != null)
              Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(widget.item.description!)),
            if (widget.variants.length > 1) ...[
              Text(t.sizeName, style: Theme.of(context).textTheme.titleSmall),
              RadioGroup<String>(
                groupValue: _variantId,
                onChanged: (v) => setState(() => _variantId = v ?? _variantId),
                child: Column(children: [
                  for (final v in widget.variants)
                    RadioListTile<String>(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      value: v.id,
                      title: Text('${v.name} — ${widget.money(widget.priceOf(v.id) ?? 0)}'),
                    ),
                ]),
              ),
            ],
            for (final g in widget.groups) ...[
              const SizedBox(height: 8),
              Text(g.name, style: Theme.of(context).textTheme.titleSmall),
              Text(
                optionRuleLabel(t, g.minSelect, g.maxSelect),
                style: TextStyle(
                  fontSize: 12,
                  color: _tried && !_groupOk(g) ? scheme.error : scheme.onSurfaceVariant,
                ),
              ),
              if (g.maxSelect == 1)
                RadioGroup<String>(
                  groupValue: (_selected[g.id] ?? const {}).firstOrNull ?? '',
                  onChanged: (id) => _toggle(g, id ?? '', (id ?? '').isNotEmpty),
                  child: Column(children: [
                    if (g.minSelect == 0)
                      RadioListTile<String>(contentPadding: EdgeInsets.zero, dense: true, value: '', title: Text(t.noneOption)),
                    for (final m in _choices(g))
                      RadioListTile<String>(contentPadding: EdgeInsets.zero, dense: true, value: m.id, title: Text(_optionLabel(m))),
                  ]),
                )
              else
                for (final m in _choices(g))
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    value: (_selected[g.id] ?? const {}).contains(m.id),
                    title: Text(_optionLabel(m)),
                    onChanged: (on) => _toggle(g, m.id, on == true),
                  ),
            ],
            const SizedBox(height: 8),
            TextField(
              controller: _note,
              maxLength: 300,
              decoration: InputDecoration(labelText: t.kitchenNote, hintText: t.kitchenNoteExamples),
            ),
            Row(children: [
              Text(t.quantity),
              const Spacer(),
              IconButton(
                onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                icon: const Icon(Icons.remove_circle_outline),
              ),
              Text('$_quantity', style: Theme.of(context).textTheme.titleMedium),
              IconButton(
                onPressed: _quantity < 999 ? () => setState(() => _quantity++) : null,
                icon: const Icon(Icons.add_circle_outline),
              ),
            ]),
          ]),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(t.cancel)),
        FilledButton(
          onPressed: () {
            if (!widget.groups.every(_groupOk)) {
              setState(() => _tried = true);
              return;
            }
            final note = _note.text.trim();
            Navigator.pop(
              context,
              ItemChoice(_variantId, [for (final s in _selected.values) ...s], _quantity, note.isEmpty ? null : note),
            );
          },
          child: Text(t.addForPrice(widget.money(_unit * _quantity))),
        ),
      ],
    );
  }
}
