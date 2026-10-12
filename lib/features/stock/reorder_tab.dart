import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../../app_state.dart';
import '../../data/stock_api.dart';
import '../../pdf/stock_pdf.dart';
import '../../ui/common.dart';
import '../../ui/kit.dart';
import '../../ui/theme.dart';
import 'stock_screen.dart';
import 'stock_widgets.dart';

/// Commande suggérée : de quoi tenir N jours au-dessus du seuil, d'après la
/// consommation des 28 derniers jours, regroupée par fournisseur habituel.
/// Chaque groupe devient un bon de commande (module Achats) ou un PDF.
class ReorderTab extends StatefulWidget {
  const ReorderTab({super.key, required this.stock});
  final StockContext stock;

  @override
  State<ReorderTab> createState() => _ReorderTabState();
}

class _ReorderTabState extends State<ReorderTab> {
  int _cover = 7;
  late Future<List<ReorderSuggestion>> _data = _load();
  final Map<String, TextEditingController> _qty = {};
  final Set<String> _excluded = {};

  StockContext get s => widget.stock;

  Future<List<ReorderSuggestion>> _load() async {
    final list = await AppScope.read(context).api!.stock.reorder(s.branch.id!, coverDays: _cover);
    for (final c in _qty.values) {
      c.dispose();
    }
    _qty.clear();
    _excluded.clear();
    return list;
  }

  @override
  void dispose() {
    for (final c in _qty.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _field(ReorderSuggestion r) =>
      _qty.putIfAbsent(r.ingredientId, () => TextEditingController(text: formatQty(context, r.suggested)));

  List<(ReorderSuggestion, double)> _chosen(List<ReorderSuggestion> group) => [
        for (final r in group)
          if (!_excluded.contains(r.ingredientId) && (parseQty(_field(r).text) ?? 0) > 0) (r, parseQty(_field(r).text)!),
      ];

  Future<void> _createOrder(String supplierId, List<ReorderSuggestion> group) async {
    final t = context.t;
    final lines = _chosen(group);
    if (lines.isEmpty) return;
    try {
      await AppScope.read(context).api!.purchases.savePurchaseOrder(
        branchId: s.branch.id!,
        supplierId: supplierId,
        expectedOn: DateTime.now().add(const Duration(days: 2)),
        note: t.reorderNote,
        lines: [
          for (final (r, q) in lines)
            {'ingredient_id': r.ingredientId, 'quantity': q, 'unit': r.unitCode, 'unit_price': r.lastUnitCost},
        ],
      );
      if (!mounted) return;
      showInfo(context, t.purchaseOrderDraftCreated);
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  Future<void> _pdf(String supplier, List<ReorderSuggestion> group) async {
    final t = context.t;
    final lines = _chosen(group);
    if (lines.isEmpty) return;
    final bytes = await reorderPdf(
      StockDocContext(t: t, locale: Localizations.localeOf(context).toString(), minorUnit: s.minorUnit, branch: s.branch),
      supplier: supplier,
      lines: [for (final (r, q) in lines) (r, q)],
    );
    await Printing.sharePdf(bytes: bytes, filename: 'commande-${supplier.replaceAll(RegExp(r'[^A-Za-z0-9]+'), '-')}.pdf');
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final side = MediaQuery.sizeOf(context).width < 600 ? 16.0 : 22.0;
    final canOrder = s.can('purchases.manage');
    return FutureBuilder(
      future: _data,
      builder: (context, snap) {
        if (snap.hasError) return Center(child: TextButton(onPressed: () => setState(() => _data = _load()), child: Text(t.retry)));
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        final list = snap.data!;
        final groups = <String?, List<ReorderSuggestion>>{};
        for (final r in list) {
          groups.putIfAbsent(r.supplierId, () => []).add(r);
        }
        final keys = groups.keys.toList()..sort((a, b) => a == null ? 1 : (b == null ? -1 : 0));
        return ListView(padding: EdgeInsets.fromLTRB(side, 6, side, 40), children: [
          Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(t.reorderTitle, style: serifTitle(context, size: 26)),
                Text(t.reorderHint, style: const TextStyle(color: RestoColors.muted, fontSize: 12.5)),
              ]),
            ),
            PillBar<int>(
              dense: true,
              items: [PillItem(3, t.daysCount(3)), PillItem(7, t.daysCount(7)), PillItem(14, t.daysCount(14))],
              selected: _cover,
              onSelected: (v) => setState(() {
                _cover = v;
                _data = _load();
              }),
            ),
          ]),
          const SizedBox(height: 14),
          if (list.isEmpty) EmptyState(icon: Icons.check_circle_outline_rounded, title: t.nothingToReorder, message: t.nothingToReorderHint),
          for (final key in keys) ...[
            Builder(builder: (context) {
              final group = groups[key]!;
              final supplier = group.first.supplierName ?? t.noSupplier;
              final total = _chosen(group).fold<double>(0, (a, e) => a + e.$2 * e.$1.lastUnitCost);
              return GoldHeaderCard(
                title: supplier,
                titleIcon: key == null ? Icons.help_outline_rounded : Icons.storefront_outlined,
                badge: HeaderBadge(text: s.money(context, total)),
                info: key == null ? Text(t.noSupplierHint) : null,
                action: Wrap(spacing: 10, runSpacing: 8, alignment: WrapAlignment.end, children: [
                  OutlinedButton.icon(
                    onPressed: () => _pdf(supplier, group),
                    icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
                    label: Text(t.orderFormPdf),
                  ),
                  if (key != null && canOrder)
                    GoldButton(
                      label: t.createPurchaseOrder,
                      icon: Icons.send_rounded,
                      expand: false,
                      onPressed: () => _createOrder(key, group),
                    ),
                ]),
                child: Column(children: [
                  for (final r in group)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Row(children: [
                        Checkbox(
                          value: !_excluded.contains(r.ingredientId),
                          activeColor: RestoColors.primary,
                          onChanged: (v) => setState(() => v == true ? _excluded.remove(r.ingredientId) : _excluded.add(r.ingredientId)),
                        ),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(r.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                            Text(
                              [
                                t.inStockShort('${formatQty(context, r.quantity)} ${unitLabel(t, r.unitCode)}'),
                                if (r.minQuantity > 0) t.alertAt('${formatQty(context, r.minQuantity)} ${unitLabel(t, r.unitCode)}'),
                                if (r.daysLeft != null) t.daysLeftLong(r.daysLeft!.round()),
                              ].join(' · '),
                              style: TextStyle(
                                  color: (r.daysLeft ?? 99) < 2 ? const Color(0xFFC0392B) : RestoColors.muted, fontSize: 12),
                            ),
                          ]),
                        ),
                        SizedBox(
                          width: 120,
                          child: TextField(
                            controller: _field(r),
                            textAlign: TextAlign.end,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              isDense: true,
                              suffixText: unitLabel(t, r.unitCode),
                              helperText: r.purchaseUnitQty == null || r.purchaseUnitLabel == null
                                  ? null
                                  : '${((parseQty(_field(r).text) ?? 0) / r.purchaseUnitQty!).ceil()} × ${r.purchaseUnitLabel}',
                            ),
                          ),
                        ),
                      ]),
                    ),
                ]),
              );
            }),
            const SizedBox(height: 14),
          ],
        ]);
      },
    );
  }
}
