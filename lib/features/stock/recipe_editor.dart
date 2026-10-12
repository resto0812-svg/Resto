import 'package:flutter/material.dart';

import '../../app_state.dart';
import '../../data/models.dart';
import '../../data/stock_api.dart';
import '../../ui/common.dart';
import '../../ui/kit.dart';
import '../../ui/theme.dart';
import 'stock_screen.dart';
import 'stock_widgets.dart';

/// Fiches techniques : coût de revient et marge de chaque plat, préparations maison.
class RecipesTab extends StatelessWidget {
  const RecipesTab({
    super.key,
    required this.membership,
    required this.branch,
    required this.data,
    required this.money,
    required this.onChanged,
  });

  final Membership membership;
  final Branch branch;
  final StockData data;
  final String Function(num) money;
  final VoidCallback onChanged;

  bool get _canEdit => membership.canOrg('menus.manage');
  bool get _seesCosts => membership.can('finance.read');

  Future<List<(String, String, int?, int?, bool)>> _load(BuildContext context) async {
    final api = AppScope.read(context).api!;
    if (_seesCosts) {
      return [
        for (final c in await api.stock.recipeCosts(branch.id!))
          (c.variantId, c.variantName.isEmpty ? c.itemName : '${c.itemName} (${c.variantName})', c.costMinor, c.priceMinor, c.hasRecipe),
      ];
    }
    final menu = await api.menu.load(branch.brandId);
    return [
      for (final i in menu.items.where((i) => i.active))
        for (final v in i.variants.where((v) => v.active)) (v.id, v.name.isEmpty ? i.name : '${i.name} (${v.name})', null, null, false),
    ];
  }

  Future<void> _open(BuildContext context, String title, {String? variantId, Ingredient? ingredient}) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => RecipeEditorScreen(
          title: title,
          variantId: variantId,
          produced: ingredient,
          data: data,
          canEdit: _canEdit,
          money: money,
        ),
      ),
    );
    if (changed == true) onChanged();
  }

  Future<void> _editTarget(BuildContext context) async {
    final t = context.t;
    final c = TextEditingController(text: branch.targetFoodCostPercent.toStringAsFixed(0));
    final v = await showDialog<double>(
      context: context,
      builder: (dc) => AlertDialog(
        title: Text(t.targetFoodCost),
        content: TextField(
          controller: c,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(labelText: t.targetFoodCost, suffixText: '%', helperText: t.targetFoodCostHint, helperMaxLines: 3),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dc), child: Text(t.cancel)),
          FilledButton(onPressed: () => Navigator.pop(dc, double.tryParse(c.text.replaceAll(',', '.'))), child: Text(t.save)),
        ],
      ),
    );
    c.dispose();
    if (v == null || v < 1 || v > 95 || !context.mounted) return;
    try {
      await AppScope.read(context).api!.stock.setTargetFoodCost(branch.id!, v);
      branch.targetFoodCostPercent = v;
      onChanged();
    } catch (e) {
      if (context.mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final semi = data.ingredients.where((i) => i.kind == 'semi_finished' && i.active).toList();
    final side = MediaQuery.sizeOf(context).width < 600 ? 16.0 : 22.0;
    final target = branch.targetFoodCostPercent;
    return Loader<List<(String, String, int?, int?, bool)>>(
      load: () => _load(context),
      builder: (context, rows, _) {
        double? ratio(int? cost, int? price) => cost == null || price == null || price == 0 ? null : cost * 100 / price;
        final withRecipe = rows.where((r) => r.$5).length;
        final above = rows.where((r) => (ratio(r.$3, r.$4) ?? 0) > target).length;
        return ListView(padding: EdgeInsets.fromLTRB(side, 6, side, 40), children: [
          Wrap(spacing: 12, runSpacing: 10, crossAxisAlignment: WrapCrossAlignment.center, children: [
            CounterTile(icon: Icons.menu_book_outlined, value: '$withRecipe / ${rows.length}', label: t.dishesWithRecipe, highlight: true),
            if (_seesCosts) CounterTile(icon: Icons.trending_up_rounded, value: '$above', label: t.aboveTarget),
            if (_seesCosts)
              ActionChip(
                avatar: const Icon(Icons.flag_outlined, size: 18),
                label: Text(t.targetFoodCostValue(target.toStringAsFixed(0))),
                onPressed: membership.can('branches.manage') ? () => _editTarget(context) : null,
              ),
          ]),
          const SizedBox(height: 8),
          Text(t.recipesIntro, style: const TextStyle(color: RestoColors.muted, fontSize: 12.5)),
          const SizedBox(height: 12),
          LayoutBuilder(builder: (context, box) {
            final cols = (box.maxWidth / 360).floor().clamp(1, 3);
            final w = (box.maxWidth - (cols - 1) * 12) / cols;
            return Wrap(spacing: 12, runSpacing: 12, children: [
              for (final (id, name, cost, price, has) in rows)
                SizedBox(
                  width: w,
                  child: SoftCard(
                    padding: const EdgeInsets.all(14),
                    onTap: () => _open(context, name, variantId: id),
                    child: Builder(builder: (context) {
                      final r = ratio(cost, price);
                      final over = r != null && r > target;
                      final color = !has ? RestoColors.muted : (over ? const Color(0xFFC0392B) : const Color(0xFF2E9E5B));
                      return Row(children: [
                        GoldIcon(has ? Icons.menu_book_rounded : Icons.edit_note_rounded, size: 42, filled: has),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
                            const SizedBox(height: 2),
                            Text(
                              !_seesCosts
                                  ? (has ? t.recipeDefined : t.noRecipe)
                                  : !has
                                      ? t.noRecipe
                                      : [t.costPrice(money(cost ?? 0)), if (price != null) t.sellingPrice(money(price))].join(' · '),
                              style: const TextStyle(color: RestoColors.muted, fontSize: 12),
                            ),
                          ]),
                        ),
                        if (_seesCosts && has && r != null)
                          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                            Text('${r.toStringAsFixed(0)} %', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: color)),
                            Text(over ? t.aboveTargetShort : t.foodCostShort, style: TextStyle(fontSize: 11, color: color)),
                          ])
                        else
                          const Icon(Icons.chevron_right_rounded, color: RestoColors.muted),
                      ]);
                    }),
                  ),
                ),
            ]);
          }),
          if (semi.isNotEmpty) ...[
            const SizedBox(height: 22),
            SectionHeading(title: t.ingSemiFinished, icon: Icons.blender_outlined),
            const SizedBox(height: 10),
            Wrap(spacing: 10, runSpacing: 10, children: [
              for (final i in semi)
                ActionChip(
                  avatar: const Icon(Icons.blender_outlined, size: 18),
                  label: Text(i.name),
                  onPressed: () => _open(context, i.name, ingredient: i),
                ),
            ]),
          ],
        ]);
      },
    );
  }
}
class _LineDraft {
  _LineDraft({this.ingredientId, String qty = '', this.unit, String waste = ''})
      : qty = TextEditingController(text: qty),
        waste = TextEditingController(text: waste);
  String? ingredientId;
  String? unit;
  final TextEditingController qty;
  final TextEditingController waste;
}

/// Fiche technique d'un plat (pour 1 portion, ou pour un rendement donné)
/// ou d'une préparation maison. Chaque enregistrement crée une version.
class RecipeEditorScreen extends StatefulWidget {
  const RecipeEditorScreen({
    super.key,
    required this.title,
    this.variantId,
    this.produced,
    required this.data,
    required this.canEdit,
    required this.money,
  });

  final String title;
  final String? variantId;
  final Ingredient? produced;
  final StockData data;
  final bool canEdit;
  final String Function(num) money;

  @override
  State<RecipeEditorScreen> createState() => _RecipeEditorScreenState();
}

class _RecipeEditorScreenState extends State<RecipeEditorScreen> {
  final _lines = <_LineDraft>[];
  final _yield = TextEditingController(text: '1');
  final _notes = TextEditingController();
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _yield.dispose();
    _notes.dispose();
    for (final l in _lines) {
      l.qty.dispose();
      l.waste.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final r = await AppScope.read(context).api!.stock.currentRecipe(variantId: widget.variantId, ingredientId: widget.produced?.id);
      setState(() {
        if (r != null) {
          _yield.text = formatQty(context, r.yieldQuantity);
          _notes.text = r.notes ?? '';
          for (final l in r.lines) {
            _lines.add(_LineDraft(
              ingredientId: l.ingredientId,
              qty: formatQty(context, l.quantity),
              unit: l.unit,
              waste: l.wastePercent == 0 ? '' : formatQty(context, l.wastePercent),
            ));
          }
        }
        if (_lines.isEmpty) _lines.add(_LineDraft());
        _loaded = true;
      });
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  Ingredient? _ing(String? id) => widget.data.ingredients.where((i) => i.id == id).firstOrNull;

  double _factor(String code) => widget.data.units.firstWhere((u) => u.code == code).factor;

  /// Coût estimé avec les coûts moyens actuels de l'établissement.
  double get _cost {
    final y = parseQty(_yield.text) ?? 1;
    var total = 0.0;
    for (final l in _lines) {
      final ing = _ing(l.ingredientId);
      final q = parseQty(l.qty.text);
      if (ing == null || q == null || l.unit == null) continue;
      final avg = widget.data.overview.where((s) => s.ingredientId == ing.id).firstOrNull?.avgUnitCost ?? 0;
      final w = parseQty(l.waste.text) ?? 0;
      total += q * _factor(l.unit!) / _factor(ing.unitCode) * (1 + w / 100) / (y == 0 ? 1 : y) * avg;
    }
    return total;
  }

  Future<void> _save() async {
    final t = context.t;
    final y = parseQty(_yield.text);
    final lines = <RecipeLine>[];
    for (final l in _lines) {
      if (l.ingredientId == null && l.qty.text.trim().isEmpty) continue;
      final q = parseQty(l.qty.text);
      final w = l.waste.text.trim().isEmpty ? 0.0 : parseQty(l.waste.text);
      if (l.ingredientId == null || q == null || q <= 0 || l.unit == null || w == null || w >= 100) {
        showInfo(context, t.errorInvalidRecipe);
        return;
      }
      lines.add(RecipeLine(l.ingredientId!, q, l.unit!, w));
    }
    if (y == null || y <= 0) {
      showInfo(context, t.errorInvalidRecipe);
      return;
    }
    try {
      await AppScope.read(context).api!.stock.saveRecipe(
            variantId: widget.variantId,
            ingredientId: widget.produced?.id,
            yieldQuantity: y,
            lines: lines,
            notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
          );
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
    final edit = widget.canEdit;
    final choices = widget.data.ingredients.where((i) => i.active && i.id != widget.produced?.id).toList();
    return Scaffold(
      appBar: AppBar(title: Text(t.recipeOf(widget.title))),
      body: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : ListView(padding: const EdgeInsets.fromLTRB(24, 16, 24, 32), children: [
              FormWidth(
                maxWidth: 820,
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  if (choices.isEmpty) Text(t.noIngredientsYet),
                  Row(children: [
                    SizedBox(
                      width: 220,
                      child: TextField(
                        controller: _yield,
                        enabled: edit,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: widget.produced == null ? t.portions : t.yieldQuantity,
                          suffixText: widget.produced == null ? null : unitLabel(t, widget.produced!.unitCode),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const Spacer(),
                    Text(t.costPrice(widget.money(_cost)), style: Theme.of(context).textTheme.titleMedium),
                  ]),
                  const SizedBox(height: 16),
                  for (final l in _lines)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Wrap(spacing: 12, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
                        SizedBox(
                          width: 260,
                          child: SearchSelect(
                            label: t.ingredient,
                            value: l.ingredientId,
                            enabled: edit,
                            entries: [for (final i in choices) (i.id, i.name)],
                            onChanged: (v) => setState(() {
                              l.ingredientId = v;
                              l.unit = _ing(v)?.unitCode;
                            }),
                          ),
                        ),
                        SizedBox(
                          width: 110,
                          child: TextField(
                            controller: l.qty,
                            enabled: edit,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(labelText: t.quantity),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        if (_ing(l.ingredientId) != null)
                          DropdownButton<String>(
                            value: l.unit,
                            items: [
                              for (final u in compatibleUnits(widget.data.units, _ing(l.ingredientId)!.unitCode))
                                DropdownMenuItem(value: u.code, child: Text(unitLabel(t, u.code))),
                            ],
                            onChanged: edit ? (v) => setState(() => l.unit = v) : null,
                          ),
                        SizedBox(
                          width: 100,
                          child: TextField(
                            controller: l.waste,
                            enabled: edit,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(labelText: t.wastePercent, suffixText: '%'),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        if (edit)
                          IconButton(
                            tooltip: t.removeLine,
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () => setState(() => _lines.remove(l)),
                          ),
                      ]),
                    ),
                  if (edit)
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: TextButton.icon(
                        onPressed: () => setState(() => _lines.add(_LineDraft())),
                        icon: const Icon(Icons.add),
                        label: Text(t.addIngredientLine),
                      ),
                    ),
                  TextField(
                    controller: _notes,
                    enabled: edit,
                    maxLength: 1000,
                    maxLines: 3,
                    minLines: 1,
                    decoration: InputDecoration(labelText: t.preparationNotes),
                  ),
                  const SizedBox(height: 16),
                  if (edit) BusyButton(label: t.save, onPressed: _save) else Text(t.readOnly),
                ]),
              ),
            ]),
    );
  }
}

