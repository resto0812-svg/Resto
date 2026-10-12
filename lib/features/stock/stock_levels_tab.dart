import 'package:flutter/material.dart';

import '../../app_state.dart';
import '../../data/stock_api.dart';
import '../../ui/common.dart';
import '../../ui/kit.dart';
import '../../ui/theme.dart';
import '../customer/customer_home.dart' show NetImage;
import '../menus/menu_widgets.dart' show uuidV4;
import 'stock_screen.dart';
import 'stock_widgets.dart';

/// État du stock : quantité, seuil, valeur ; entrées, pertes, transferts,
/// production, ajustements, seuil d'alerte.
class StockLevelsTab extends StatefulWidget {
  const StockLevelsTab({super.key, required this.stock});
  final StockContext stock;

  @override
  State<StockLevelsTab> createState() => _StockLevelsTabState();
}

class _StockLevelsTabState extends State<StockLevelsTab> {
  String? _locationId;
  String _query = '';
  String _filter = 'all';

  StockContext get s => widget.stock;
  StockData get d => s.data;

  Future<void> _run(Future<void> Function() action) async {
    try {
      await action();
      if (mounted) showInfo(context, context.t.saved);
      s.reload();
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  Future<void> _move(StockLine line, String kind) async {
    final t = context.t;
    final ing = d.ingredient(line.ingredientId);
    if (ing == null) return;
    final location = _locationId ?? d.locations.firstWhere((l) => l.active).id;
    final api = AppScope.read(context).api!.stock;
    final branchId = s.branch.id!;
    if (kind == 'threshold') {
      final c = TextEditingController(text: line.minQuantity == 0 ? '' : formatQty(context, line.minQuantity));
      final v = await showDialog<double>(
        context: context,
        builder: (dc) => AlertDialog(
          title: Text('${t.alertThreshold} · ${ing.name}'),
          content: TextField(
            controller: c,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: t.alertBelow, suffixText: unitLabel(t, ing.unitCode)),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dc), child: Text(t.cancel)),
            FilledButton(onPressed: () => Navigator.pop(dc, parseQty(c.text.isEmpty ? '0' : c.text)), child: Text(t.save)),
          ],
        ),
      );
      c.dispose();
      if (v == null || !mounted) return;
      await _run(() => api.setThreshold(branchId, ing.id, v));
      return;
    }
    final title = switch (kind) {
      'transfer' => t.mvTransferOut,
      'production' => t.produce,
      _ => movementLabel(t, kind),
    };
    final r = await showDialog<MovementResult>(
      context: context,
      builder: (_) => MovementDialog(
        title: title,
        kind: kind,
        ingredient: ing,
        units: d.units,
        currency: s.branch.currency,
        locations: d.locations,
        fromLocationId: location,
      ),
    );
    if (r == null || !mounted) return;
    await _run(() => switch (kind) {
          'transfer' => api.transfer(location, r.toLocationId!, ing.id, r.quantity, r.unit, r.reason, uuidV4()),
          'production' => api.produce(branchId, location, ing.id, r.quantity, uuidV4()),
          _ => api.movement(
              branchId: branchId,
              locationId: location,
              ingredientId: ing.id,
              kind: kind,
              quantity: r.quantity,
              unit: r.unit,
              unitCost: r.unitCost,
              reason: r.reason,
              batch: r.batch,
              expiresOn: r.expiresOn,
              clientId: uuidV4(),
            ),
        });
  }

  Future<void> _addLocation() async {
    final t = context.t;
    final c = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (dc) => AlertDialog(
        title: Text(t.newLocation),
        content: TextField(controller: c, autofocus: true, maxLength: 60, decoration: InputDecoration(labelText: t.name, hintText: t.locationExamples)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dc), child: Text(t.cancel)),
          FilledButton(onPressed: () => Navigator.pop(dc, c.text.trim()), child: Text(t.save)),
        ],
      ),
    );
    c.dispose();
    if (name == null || name.isEmpty || !mounted) return;
    final api = AppScope.read(context).api!.stock;
    await _run(() => api.addLocation(s.membership.organizationId, s.branch.id!, name));
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final side = MediaQuery.sizeOf(context).width < 600 ? 16.0 : 22.0;
    final total = d.overview.fold<int>(0, (a, l) => a + l.valueMinor);
    final alerts = d.overview.where((l) => l.belowMin).length;
    final empty = d.overview.where((l) => l.quantity <= 0).length;
    final locations = d.locations.where((l) => l.active).toList();
    final selected = _locationId ?? (locations.isEmpty ? null : locations.first.id);
    final q = _query.trim().toLowerCase();
    final lines = d.overview
        .where((l) => q.isEmpty || l.name.toLowerCase().contains(q))
        .where((l) => switch (_filter) {
              'alerts' => l.belowMin,
              'empty' => l.quantity <= 0,
              _ => true,
            })
        .toList();
    return ListView(padding: EdgeInsets.fromLTRB(side, 6, side, 40), children: [
      Wrap(spacing: 12, runSpacing: 10, crossAxisAlignment: WrapCrossAlignment.center, children: [
        CounterTile(icon: Icons.account_balance_wallet_outlined, value: s.money(context, total), label: t.stockValueLabel, highlight: true),
        CounterTile(icon: Icons.warning_amber_rounded, value: '$alerts', label: t.belowThresholdLabel),
        CounterTile(icon: Icons.remove_shopping_cart_outlined, value: '$empty', label: t.outOfStockLabel),
      ]),
      const SizedBox(height: 14),
      Wrap(spacing: 10, runSpacing: 10, crossAxisAlignment: WrapCrossAlignment.center, children: [
        SizedBox(
          width: 260,
          child: TextField(
            onChanged: (v) => setState(() => _query = v),
            decoration: InputDecoration(isDense: true, fillColor: Colors.white, hintText: t.search, prefixIcon: const Icon(Icons.search_rounded, size: 20)),
          ),
        ),
        PillBar<String>(
          dense: true,
          items: [
            PillItem('all', t.allFilter),
            PillItem('alerts', t.belowThresholdLabel, count: alerts == 0 ? null : alerts),
            PillItem('empty', t.outOfStockLabel),
          ],
          selected: _filter,
          onSelected: (v) => setState(() => _filter = v),
        ),
        if (locations.length > 1)
          PillBar<String>(
            dense: true,
            items: [for (final l in locations) PillItem(l.id, l.name, icon: Icons.place_outlined)],
            selected: selected!,
            onSelected: (v) => setState(() => _locationId = v),
          ),
        if (s.can('stock.adjust'))
          TextButton.icon(onPressed: _addLocation, icon: const Icon(Icons.add_location_alt_outlined), label: Text(t.newLocation)),
      ]),
      const SizedBox(height: 14),
      if (d.overview.isEmpty)
        EmptyState(icon: Icons.inventory_2_outlined, title: t.noIngredientsYet, message: t.stockEmptyHint)
      else if (lines.isEmpty)
        EmptyState(icon: Icons.search_off_rounded, title: t.noResults)
      else
        LayoutBuilder(builder: (context, box) {
          final cols = (box.maxWidth / 330).floor().clamp(1, 4);
          final w = (box.maxWidth - (cols - 1) * 12) / cols;
          return Wrap(spacing: 12, runSpacing: 12, children: [
            for (final l in lines) SizedBox(width: w, child: _LevelCard(stock: s, line: l, canMove: s.can('stock.write') && selected != null, multiLocation: locations.length > 1, onAction: (k) => _move(l, k))),
          ]);
        }),
    ]);
  }
}

class _LevelCard extends StatelessWidget {
  const _LevelCard({required this.stock, required this.line, required this.canMove, required this.multiLocation, required this.onAction});
  final StockContext stock;
  final StockLine line;
  final bool canMove;
  final bool multiLocation;
  final ValueChanged<String> onAction;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final l = line;
    final ing = stock.data.ingredient(l.ingredientId);
    final api = AppScope.read(context).api!.stock;
    final color = l.quantity <= 0
        ? const Color(0xFFC0392B)
        : l.belowMin
            ? StatusColors.toValidate
            : const Color(0xFF2E9E5B);
    final ratio = l.minQuantity > 0 ? (l.quantity / (l.minQuantity * 2)).clamp(0.0, 1.0) : (l.quantity > 0 ? 1.0 : 0.0);
    return SoftCard(
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 52,
              height: 52,
              child: ing?.imagePath != null
                  ? NetImage(api.imageUrl(ing!.imagePath!))
                  : Container(color: RestoColors.primarySoft, child: Icon(ingredientKindIcon(l.kind), color: RestoColors.primaryDeep)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(l.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              Text(
                [ingredientKindLabel(t, l.kind), if (ing != null) storageLabel(t, ing.storage)].join(' · '),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: RestoColors.muted, fontSize: 12),
              ),
            ]),
          ),
          if (canMove)
            PopupMenuButton<String>(
              onSelected: onAction,
              itemBuilder: (_) => [
                PopupMenuItem(value: 'receipt', child: Text(t.mvReceipt)),
                PopupMenuItem(value: 'waste', child: Text(t.mvWaste)),
                PopupMenuItem(value: 'staff_meal', child: Text(t.mvStaffMeal)),
                PopupMenuItem(value: 'return', child: Text(t.mvReturn)),
                if (multiLocation) PopupMenuItem(value: 'transfer', child: Text(t.mvTransferOut)),
                if (l.kind == 'semi_finished') PopupMenuItem(value: 'production', child: Text(t.produce)),
                if (stock.can('stock.adjust')) PopupMenuItem(value: 'opening', child: Text(t.mvOpening)),
                if (stock.can('stock.adjust')) PopupMenuItem(value: 'adjustment', child: Text(t.mvAdjustment)),
                PopupMenuItem(value: 'threshold', child: Text(t.alertThreshold)),
              ],
            ),
        ]),
        const SizedBox(height: 12),
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(formatQty(context, l.quantity), style: serifTitle(context, size: 28, color: l.quantity <= 0 ? color : RestoColors.ink)),
          const SizedBox(width: 4),
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(unitLabel(t, l.unitCode), style: const TextStyle(color: RestoColors.muted)),
          ),
          const Spacer(),
          if (l.valueMinor > 0) Text(stock.money(context, l.valueMinor), style: const TextStyle(fontWeight: FontWeight.w700, color: RestoColors.primaryDeep)),
        ]),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(value: ratio, minHeight: 7, color: color, backgroundColor: RestoColors.primarySoft),
        ),
        const SizedBox(height: 6),
        Row(children: [
          if (l.minQuantity > 0)
            Expanded(
              child: Text(t.alertAt('${formatQty(context, l.minQuantity)} ${unitLabel(t, l.unitCode)}'),
                  style: const TextStyle(color: RestoColors.muted, fontSize: 12)),
            )
          else
            const Spacer(),
          if (l.avgUnitCost > 0)
            Text(t.avgCost(stock.money(context, l.avgUnitCost), unitLabel(t, l.unitCode)), style: const TextStyle(color: RestoColors.muted, fontSize: 12)),
        ]),
      ]),
    );
  }
}
