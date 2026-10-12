import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app_state.dart';
import '../../data/models.dart';
import '../../data/stock_api.dart';
import '../../ui/common.dart';
import '../menus/menu_widgets.dart';
import 'stock_screen.dart';
import 'stock_widgets.dart';

/// Inventaires : un brouillon par emplacement, saisie des quantités
/// comptées, validation par un responsable (écarts enregistrés).
class InventoriesTab extends StatelessWidget {
  const InventoriesTab({super.key, required this.membership, required this.branch, required this.data, required this.onChanged});
  final Membership membership;
  final Branch branch;
  final StockData data;
  final VoidCallback onChanged;

  bool _can(String p) => membership.can(p) && (membership.allBranches || membership.branchIds.contains(branch.id));

  Future<void> _start(BuildContext context) async {
    final t = context.t;
    final locations = data.locations.where((l) => l.active).toList();
    String? location = locations.length == 1 ? locations.first.id : null;
    location ??= await showDialog<String>(
        context: context,
        builder: (c) => SimpleDialog(
          title: Text(t.chooseLocation),
          children: [for (final l in locations) SimpleDialogOption(onPressed: () => Navigator.pop(c, l.id), child: Text(l.name))],
        ),
      );
    if (location == null || !context.mounted) return;
    try {
      final id = await AppScope.read(context).api!.stock.startInventory(location, uuidV4());
      if (!context.mounted) return;
      await _open(context, id, location);
    } catch (e) {
      if (context.mounted) showError(context, e);
    }
  }

  Future<void> _open(BuildContext context, String countId, String locationId) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => InventoryCountScreen(
          countId: countId,
          location: data.locations.firstWhere((l) => l.id == locationId),
          data: data,
          canValidate: _can('stock.adjust'),
          branchId: branch.id!,
        ),
      ),
    );
    onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final api = AppScope.of(context).api!.stock;
    final fmt = DateFormat.yMMMd(Localizations.localeOf(context).toString()).add_Hm();
    final names = {for (final l in data.locations) l.id: l.name};
    return Scaffold(
      floatingActionButton: _can('stock.write')
          ? FloatingActionButton.extended(onPressed: () => _start(context), icon: const Icon(Icons.fact_check), label: Text(t.newInventory))
          : null,
      body: Loader<List<InventoryCount>>(
        load: () => api.inventories(branch.id!),
        builder: (context, list, _) => list.isEmpty
            ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(t.inventoriesIntro, textAlign: TextAlign.center)))
            : ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 96), children: [
                for (final c in list)
                  FormWidth(
                    maxWidth: 900,
                    child: Card(
                      child: ListTile(
                        leading: Icon(c.status == 'validated' ? Icons.verified_outlined : Icons.edit_note),
                        title: Text('${names[c.locationId] ?? ''} · ${fmt.format(c.startedAt.toLocal())}'),
                        subtitle: Text(c.status == 'validated'
                            ? t.inventoryValidated(c.lines.values.where((v) => (v.$2 ?? 0) != 0).length)
                            : t.inventoryDraft(c.lines.length)),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _open(context, c.id, c.locationId),
                      ),
                    ),
                  ),
              ]),
      ),
    );
  }
}

class InventoryCountScreen extends StatefulWidget {
  const InventoryCountScreen({
    super.key,
    required this.countId,
    required this.location,
    required this.data,
    required this.canValidate,
    required this.branchId,
  });

  final String countId;
  final StockLocation location;
  final StockData data;
  final bool canValidate;
  final String branchId;

  @override
  State<InventoryCountScreen> createState() => _InventoryCountScreenState();
}

class _InventoryCountScreenState extends State<InventoryCountScreen> {
  InventoryCount? _count;
  final _fields = <String, TextEditingController>{};
  String _filter = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    for (final c in _fields.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    final list = await AppScope.read(context).api!.stock.inventories(widget.branchId);
    if (!mounted) return;
    final c = list.firstWhere((x) => x.id == widget.countId);
    setState(() {
      _count = c;
      for (final i in widget.data.ingredients.where((i) => i.active)) {
        _fields.putIfAbsent(i.id, () => TextEditingController(text: c.lines.containsKey(i.id) ? formatQty(context, c.lines[i.id]!.$1) : ''));
      }
    });
  }

  /// Enregistre les quantités saisies (les lignes vides sont ignorées).
  Future<bool> _saveLines() async {
    final t = context.t;
    final api = AppScope.read(context).api!.stock;
    try {
      for (final i in widget.data.ingredients.where((i) => i.active)) {
        final text = _fields[i.id]?.text.trim() ?? '';
        if (text.isEmpty) continue;
        final q = parseQty(text);
        if (q == null) {
          if (mounted) showInfo(context, '${i.name} : ${t.errorInvalidQuantity}');
          return false;
        }
        if (_count!.lines[i.id]?.$1 == q) continue;
        await api.countLine(widget.countId, i.id, q, i.unitCode);
      }
      return true;
    } catch (e) {
      if (mounted) showError(context, e);
      return false;
    }
  }

  Future<void> _validate() async {
    final t = context.t;
    if (!await _saveLines() || !mounted) return;
    if (!await confirm(context, t.validateInventoryConfirm, action: t.validate) || !mounted) return;
    try {
      final n = await AppScope.read(context).api!.stock.validateInventory(widget.countId);
      if (!mounted) return;
      showInfo(context, t.inventoryAdjustments(n));
      Navigator.pop(context);
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final c = _count;
    final draft = c?.status == 'draft';
    final ingredients = widget.data.ingredients
        .where((i) => i.active && (_filter.isEmpty || i.name.toLowerCase().contains(_filter.toLowerCase())))
        .toList();
    return Scaffold(
      appBar: AppBar(title: Text(t.inventoryOf(widget.location.name))),
      body: c == null
          ? const Center(child: CircularProgressIndicator())
          : Column(children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: FormWidth(
                  maxWidth: 820,
                  child: TextField(
                    decoration: InputDecoration(prefixIcon: const Icon(Icons.search), labelText: t.search),
                    onChanged: (v) => setState(() => _filter = v),
                  ),
                ),
              ),
              Expanded(
                child: ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 24), children: [
                  if (draft) FormWidth(maxWidth: 820, child: Text(t.inventoryHint, style: Theme.of(context).textTheme.bodySmall)),
                  for (final i in ingredients)
                    FormWidth(
                      maxWidth: 820,
                      child: ListTile(
                        title: Text(i.name),
                        subtitle: !draft && c.lines[i.id]?.$2 != null && c.lines[i.id]!.$2 != 0
                            ? Text(t.inventoryDifference('${c.lines[i.id]!.$2! > 0 ? '+' : ''}${formatQty(context, c.lines[i.id]!.$2!)} ${unitLabel(t, i.unitCode)}'))
                            : null,
                        trailing: SizedBox(
                          width: 150,
                          child: TextField(
                            controller: _fields[i.id],
                            enabled: draft,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            textAlign: TextAlign.end,
                            decoration: InputDecoration(isDense: true, suffixText: unitLabel(t, i.unitCode)),
                          ),
                        ),
                      ),
                    ),
                ]),
              ),
              if (draft)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Wrap(spacing: 12, runSpacing: 8, alignment: WrapAlignment.end, children: [
                    OutlinedButton(
                      onPressed: () async {
                        if (await _saveLines() && context.mounted) {
                          showInfo(context, t.saved);
                          await _load();
                        }
                      },
                      child: Text(t.save),
                    ),
                    if (widget.canValidate) FilledButton(onPressed: _validate, child: Text(t.validateInventory)),
                  ]),
                ),
            ]),
    );
  }
}
