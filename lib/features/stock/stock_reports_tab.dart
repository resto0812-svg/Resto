import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';

import '../../app_state.dart';
import '../../data/stock_api.dart';
import '../../pdf/stock_pdf.dart';
import '../../ui/common.dart';
import '../../ui/kit.dart';
import '../../ui/theme.dart';
import 'stock_screen.dart';

/// Rapports PDF du stock : état valorisé, mouvements, pertes, inventaire avec
/// écarts, coût matière par plat, lots proches de leur date limite.
class StockReportsTab extends StatefulWidget {
  const StockReportsTab({super.key, required this.stock});
  final StockContext stock;

  @override
  State<StockReportsTab> createState() => _StockReportsTabState();
}

class _StockReportsTabState extends State<StockReportsTab> {
  late DateTimeRange _range = DateTimeRange(start: DateTime.now().subtract(const Duration(days: 29)), end: DateTime.now());
  String? _busy;

  StockContext get s => widget.stock;

  StockDocContext get _doc =>
      StockDocContext(t: context.t, locale: Localizations.localeOf(context).toString(), minorUnit: s.minorUnit, branch: s.branch);

  Future<void> _run(String id, String filename, Future<Uint8List> Function() build) async {
    setState(() => _busy = id);
    try {
      final bytes = await build();
      await Printing.sharePdf(bytes: bytes, filename: filename);
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => _busy = null);
    }
  }

  String get _period {
    final f = DateFormat('yyyyMMdd');
    return '${f.format(_range.start)}-${f.format(_range.end)}';
  }

  Future<void> _inventory() async {
    final t = context.t;
    final api = AppScope.read(context).api!.stock;
    final list = (await api.inventories(s.branch.id!)).where((c) => c.status == 'validated').toList();
    if (!mounted) return;
    if (list.isEmpty) {
      showInfo(context, t.noValidatedInventory);
      return;
    }
    final names = {for (final l in s.data.locations) l.id: l.name};
    final fmt = DateFormat.yMMMd(Localizations.localeOf(context).toString()).add_Hm();
    final chosen = await showDialog<InventoryCount>(
      context: context,
      builder: (c) => SimpleDialog(
        title: Text(t.chooseInventory),
        children: [
          for (final i in list)
            SimpleDialogOption(onPressed: () => Navigator.pop(c, i), child: Text('${names[i.locationId] ?? ''} · ${fmt.format(i.startedAt.toLocal())}')),
        ],
      ),
    );
    if (chosen == null || !mounted) return;
    await _run('inventory', 'inventaire-${DateFormat('yyyyMMdd').format(chosen.startedAt)}.pdf',
        () => inventoryPdf(_doc, chosen, s.data, names[chosen.locationId] ?? ''));
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final side = MediaQuery.sizeOf(context).width < 600 ? 16.0 : 22.0;
    final day = DateFormat.yMMMd(Localizations.localeOf(context).toString());
    final api = AppScope.read(context).api!.stock;
    final reports = <(String, IconData, String, String, Future<void> Function())>[
      ('valuation', Icons.account_balance_wallet_outlined, t.reportValuation, t.reportValuationHint,
          () => _run('valuation', 'stock-valorise.pdf', () => valuationPdf(_doc, s.data))),
      ('movements', Icons.swap_vert_rounded, t.movementsReportTitle, t.reportMovementsHint,
          () => _run('movements', 'mouvements-$_period.pdf', () async {
                final list = await api.movementsBetween(s.branch.id!, _range.start, _range.end);
                return movementsPdf(_doc, list, _range.start, _range.end, title: t.movementsReportTitle);
              })),
      ('waste', Icons.delete_outline_rounded, t.wasteReportTitle, t.reportWasteHint,
          () => _run('waste', 'pertes-$_period.pdf', () async {
                final list = await api.movementsBetween(s.branch.id!, _range.start, _range.end, kinds: const ['waste']);
                return movementsPdf(_doc, list, _range.start, _range.end, title: t.wasteReportTitle);
              })),
      ('inventory', Icons.fact_check_outlined, t.reportInventory, t.reportInventoryHint, _inventory),
      if (s.membership.can('finance.read'))
        ('costs', Icons.menu_book_outlined, t.reportFoodCost, t.reportFoodCostHint,
            () => _run('costs', 'cout-matiere.pdf', () async => foodCostPdf(_doc, await api.recipeCosts(s.branch.id!)))),
      ('expiring', Icons.event_busy_outlined, t.expiringLotsTitle, t.reportExpiringHint,
          () => _run('expiring', 'dates-limites.pdf', () async => expiringPdf(_doc, await api.expiring(s.branch.id!, days: 14)))),
    ];
    return ListView(padding: EdgeInsets.fromLTRB(side, 6, side, 40), children: [
      Row(children: [
        Expanded(child: Text(t.stockReportsTab, style: serifTitle(context, size: 26))),
        ActionChip(
          avatar: const Icon(Icons.date_range_rounded, size: 18),
          label: Text('${day.format(_range.start)} – ${day.format(_range.end)}'),
          onPressed: () async {
            final r = await showDateRangePicker(
              context: context,
              initialDateRange: _range,
              firstDate: DateTime.now().subtract(const Duration(days: 730)),
              lastDate: DateTime.now(),
            );
            if (r != null) setState(() => _range = r);
          },
        ),
      ]),
      const SizedBox(height: 14),
      LayoutBuilder(builder: (context, box) {
        final cols = box.maxWidth >= 1000 ? 3 : (box.maxWidth >= 600 ? 2 : 1);
        final w = (box.maxWidth - (cols - 1) * 14) / cols;
        return Wrap(spacing: 14, runSpacing: 14, children: [
          for (final (id, icon, title, hint, action) in reports)
            SizedBox(
              width: w,
              child: SoftCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Row(children: [
                    GoldIcon(icon, size: 46),
                    const SizedBox(width: 12),
                    Expanded(child: Text(title, style: serifTitle(context, size: 19))),
                  ]),
                  const SizedBox(height: 8),
                  Text(hint, style: const TextStyle(color: RestoColors.muted, fontSize: 12.5)),
                  const SizedBox(height: 12),
                  _busy == id
                      ? const Center(child: SizedBox.square(dimension: 26, child: CircularProgressIndicator(strokeWidth: 2.5)))
                      : GoldButton(label: t.generatePdf, icon: Icons.picture_as_pdf_outlined, outlined: true, onPressed: _busy == null ? action : null),
                ]),
              ),
            ),
        ]);
      }),
    ]);
  }
}
