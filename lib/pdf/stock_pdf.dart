import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../core/money.dart';
import '../data/models.dart';
import '../data/stock_api.dart';
import '../features/stock/stock_screen.dart' show StockData;
import '../l10n/app_localizations.dart';
import 'pdf_fonts.dart';

/// Rapports du stock (A4) : état valorisé, mouvements, inventaire avec
/// écarts, coût matière par plat, lots proches de leur date limite, bon de
/// commande fournisseur.
class StockDocContext {
  StockDocContext({required this.t, required this.locale, required this.minorUnit, required this.branch});
  final AppLocalizations t;
  final String locale;
  final int minorUnit;
  final Branch branch;

  String money(num minor) => pdfText(Money(minor.round(), branch.currency).format(locale, minorUnit));
  String qty(double q) => NumberFormat.decimalPatternDigits(
    locale: locale,
    decimalDigits: 3,
  ).format(q).replaceAll(RegExp(r'([.,]\d*?)0+$'), r'$1').replaceAll(RegExp(r'[.,]$'), '');
  String unit(String code) => switch (code) {
    'unit' => t.unitPiece,
    'dozen' => t.unitDozen,
    _ => code,
  };
  String day(DateTime d) => DateFormat.yMMMd(locale).format(d.toLocal());
  String dateTime(DateTime d) => DateFormat.yMd(locale).add_Hm().format(d.toLocal());
}

const _gold = PdfColor.fromInt(0xFFC69C3A);
const _ink = PdfColor.fromInt(0xFF231A12);
const _band = PdfColor.fromInt(0xFFF2E8D6);

pw.Widget _kpi(String label, String value) => pw.Container(
  width: 125,
  padding: const pw.EdgeInsets.all(8),
  decoration: pw.BoxDecoration(
    border: pw.Border.all(color: _gold, width: 0.8),
    borderRadius: pw.BorderRadius.circular(6),
  ),
  child: pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(pdfText(label), style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
      pw.Text(
        pdfText(value),
        style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: _ink),
      ),
    ],
  ),
);

pw.Widget _table(List<String> head, List<List<String>> rows, {Set<int> left = const {0}}) => pw.TableHelper.fromTextArray(
  headers: head.map(pdfText).toList(),
  data: [for (final row in rows) row.map(pdfText).toList()],
  headerStyle: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: _ink),
  cellStyle: const pw.TextStyle(fontSize: 8.5),
  headerDecoration: const pw.BoxDecoration(color: _band),
  border: pw.TableBorder(horizontalInside: pw.BorderSide(color: PdfColors.grey300, width: 0.5)),
  cellAlignments: {for (var i = 0; i < head.length; i++) i: left.contains(i) ? pw.Alignment.centerLeft : pw.Alignment.centerRight},
);

Future<Uint8List> _a4(StockDocContext c, String title, String subtitle, List<pw.Widget> Function() build) async {
  final fonts = await PdfFonts.load();
  final doc = pw.Document(theme: fonts.theme());
  final b = c.branch;
  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      header: (_) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      pdfText(b.legalName?.isNotEmpty == true ? b.legalName! : b.name),
                      style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: _ink),
                    ),
                    pw.Text(
                      pdfText([b.name, b.city].where((x) => x.isNotEmpty).toSet().join(' · ')),
                      style: const pw.TextStyle(fontSize: 9),
                    ),
                  ],
                ),
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    pdfText(title),
                    style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: _gold),
                  ),
                  pw.Text(pdfText(subtitle), style: const pw.TextStyle(fontSize: 9)),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 6),
          pw.Container(height: 1.2, color: _gold),
          pw.SizedBox(height: 12),
        ],
      ),
      footer: (ctx) => pw.Row(
        children: [
          pw.Text(pdfText(c.t.generatedOn(c.dateTime(DateTime.now()))), style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey600)),
          pw.Spacer(),
          pw.Text('${ctx.pageNumber} / ${ctx.pagesCount}', style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey600)),
        ],
      ),
      build: (_) => build(),
    ),
  );
  return doc.save();
}

/// État du stock valorisé à l'instant.
Future<Uint8List> valuationPdf(StockDocContext c, StockData d) {
  final t = c.t;
  final lines = [...d.overview]..sort((a, b) => a.name.compareTo(b.name));
  final total = lines.fold<int>(0, (a, l) => a + l.valueMinor);
  return _a4(
    c,
    t.reportValuation,
    c.dateTime(DateTime.now()),
    () => [
      pw.Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _kpi(t.stockValueLabel, c.money(total)),
          _kpi(t.articlesLabel, '${lines.length}'),
          _kpi(t.belowThresholdLabel, '${lines.where((l) => l.belowMin).length}'),
          _kpi(t.outOfStockLabel, '${lines.where((l) => l.quantity <= 0).length}'),
        ],
      ),
      pw.SizedBox(height: 14),
      _table(
        [t.articleLabel, t.quantity, t.alertThreshold, t.avgCostShort, t.valueLabel],
        [
          for (final l in lines)
            [
              l.belowMin ? '${l.name}  (!)' : l.name,
              '${c.qty(l.quantity)} ${c.unit(l.unitCode)}',
              l.minQuantity > 0 ? '${c.qty(l.minQuantity)} ${c.unit(l.unitCode)}' : '—',
              l.avgUnitCost > 0 ? '${c.money(l.avgUnitCost)} / ${c.unit(l.unitCode)}' : '—',
              c.money(l.valueMinor),
            ],
          ['', '', '', t.total, c.money(total)],
        ],
      ),
    ],
  );
}

/// Mouvements (ou pertes) d'une période, avec totaux par nature.
Future<Uint8List> movementsPdf(StockDocContext c, List<StockMovement> list, DateTime from, DateTime to, {required String title}) {
  final t = c.t;
  final byKind = <String, double>{};
  for (final m in list) {
    byKind[m.kind] = (byKind[m.kind] ?? 0) + m.value;
  }
  String kind(String k) => switch (k) {
    'opening' => t.mvOpening,
    'receipt' => t.mvReceipt,
    'sale' => t.mvSale,
    'production_in' => t.mvProductionIn,
    'production_out' => t.mvProductionOut,
    'waste' => t.mvWaste,
    'staff_meal' => t.mvStaffMeal,
    'return' => t.mvReturn,
    'transfer_in' => t.mvTransferIn,
    'transfer_out' => t.mvTransferOut,
    'adjustment' => t.mvAdjustment,
    _ => t.mvInventory,
  };
  final rows = [...list]..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  return _a4(
    c,
    title,
    '${c.day(from)} – ${c.day(to)}',
    () => [
      pw.Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [_kpi(t.movementsTab, '${list.length}'), for (final e in byKind.entries) _kpi(kind(e.key), c.money(e.value.abs()))],
      ),
      pw.SizedBox(height: 14),
      _table(
        [t.dateLabel, t.typeLabel, t.articleLabel, t.quantity, t.valueLabel, t.reason],
        [
          for (final m in rows)
            [
              c.dateTime(m.createdAt),
              kind(m.kind),
              m.ingredientName,
              '${m.quantity > 0 ? '+' : ''}${c.qty(m.quantity)} ${c.unit(m.unitCode)}',
              c.money(m.value.abs()),
              [?m.reason, if (m.batch != null) t.batchShort(m.batch!)].join(' · '),
            ],
        ],
        left: const {0, 1, 2, 5},
      ),
    ],
  );
}

/// Inventaire validé : théorique, compté, écart, valeur de l'écart.
Future<Uint8List> inventoryPdf(StockDocContext c, InventoryCount count, StockData d, String location) {
  final t = c.t;
  final rows = <List<String>>[];
  var gain = 0.0;
  var loss = 0.0;
  final entries = count.lines.entries.toList()
    ..sort((a, b) => (d.ingredient(a.key)?.name ?? '').compareTo(d.ingredient(b.key)?.name ?? ''));
  for (final e in entries) {
    final ing = d.ingredient(e.key);
    if (ing == null) continue;
    final (counted, diff) = e.value;
    final cost = d.line(e.key)?.avgUnitCost ?? 0;
    final value = (diff ?? 0) * cost;
    if (value > 0) gain += value;
    if (value < 0) loss -= value;
    rows.add([
      ing.name,
      diff == null ? '—' : '${c.qty(counted - diff)} ${c.unit(ing.unitCode)}',
      '${c.qty(counted)} ${c.unit(ing.unitCode)}',
      diff == null ? '—' : '${diff > 0 ? '+' : ''}${c.qty(diff)}',
      c.money(value),
    ]);
  }
  return _a4(
    c,
    t.reportInventory,
    '$location · ${c.dateTime(count.startedAt)}',
    () => [
      pw.Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _kpi(t.articlesLabel, '${rows.length}'),
          _kpi(t.inventoryGains, c.money(gain)),
          _kpi(t.inventoryLosses, c.money(loss)),
          _kpi(t.inventoryNet, c.money(gain - loss)),
        ],
      ),
      pw.SizedBox(height: 14),
      _table([t.articleLabel, t.theoreticalLabel, t.countedLabel, t.differenceLabel, t.valueLabel], rows),
      pw.SizedBox(height: 30),
      pw.Row(
        children: [
          pw.Expanded(child: pw.Text(pdfText(t.countedBySignature), style: const pw.TextStyle(fontSize: 9))),
          pw.Expanded(child: pw.Text(pdfText(t.validatedBySignature), style: const pw.TextStyle(fontSize: 9))),
        ],
      ),
    ],
  );
}

/// Coût matière de chaque plat : coût de revient, prix, part du prix, marge.
Future<Uint8List> foodCostPdf(StockDocContext c, List<RecipeCost> costs) {
  final t = c.t;
  final target = c.branch.targetFoodCostPercent;
  final withRecipe = costs.where((x) => x.hasRecipe && x.costMinor != null).toList()..sort((a, b) => _ratio(b).compareTo(_ratio(a)));
  final missing = costs.where((x) => !x.hasRecipe).length;
  final above = withRecipe.where((x) => _ratio(x) > target).length;
  return _a4(
    c,
    t.reportFoodCost,
    t.targetFoodCostValue(target.toStringAsFixed(0)),
    () => [
      pw.Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [_kpi(t.dishesWithRecipe, '${withRecipe.length}'), _kpi(t.aboveTarget, '$above'), _kpi(t.withoutRecipe, '$missing')],
      ),
      pw.SizedBox(height: 14),
      _table(
        [t.dishLabel, t.costPriceShort, t.sellingPriceShort, t.foodCostShort, t.marginShort],
        [
          for (final x in withRecipe)
            [
              x.variantName.isEmpty ? x.itemName : '${x.itemName} (${x.variantName})',
              c.money(x.costMinor!),
              x.priceMinor == null ? '—' : c.money(x.priceMinor!),
              x.priceMinor == null || x.priceMinor == 0 ? '—' : '${_ratio(x).toStringAsFixed(1)} %${_ratio(x) > target ? '  (!)' : ''}',
              x.priceMinor == null ? '—' : c.money(x.priceMinor! - x.costMinor!),
            ],
        ],
      ),
    ],
  );
}

double _ratio(RecipeCost x) => x.priceMinor == null || x.priceMinor == 0 ? 0 : (x.costMinor ?? 0) * 100 / x.priceMinor!;

/// Lots encore en stock dont la date limite approche.
Future<Uint8List> expiringPdf(StockDocContext c, List<ExpiringLot> lots) {
  final t = c.t;
  return _a4(
    c,
    t.expiringLotsTitle,
    c.dateTime(DateTime.now()),
    () => [
      _kpi(t.valueLabel, c.money(lots.fold<int>(0, (a, l) => a + l.valueMinor))),
      pw.SizedBox(height: 14),
      _table(
        [t.articleLabel, t.batchNumber, t.expiryDate, t.quantity, t.valueLabel],
        [
          for (final l in lots)
            [l.name, l.batch ?? '—', c.day(l.expiresOn), '${c.qty(l.remaining)} ${c.unit(l.unitCode)}', c.money(l.valueMinor)],
        ],
        left: const {0, 1, 2},
      ),
    ],
  );
}

/// Bon de commande à envoyer au fournisseur.
Future<Uint8List> reorderPdf(StockDocContext c, {required String supplier, required List<(ReorderSuggestion, double)> lines}) {
  final t = c.t;
  final total = lines.fold<double>(0, (a, e) => a + e.$2 * e.$1.lastUnitCost);
  return _a4(
    c,
    t.orderFormTitle,
    c.day(DateTime.now()),
    () => [
      pw.Text(pdfText(t.supplierLabelValue(supplier)), style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
      pw.SizedBox(height: 10),
      _table(
        [t.articleLabel, t.quantity, t.packagingLabel, t.unitPriceShort, t.amount],
        [
          for (final (r, q) in lines)
            [
              r.name,
              '${c.qty(q)} ${c.unit(r.unitCode)}',
              r.purchaseUnitQty == null || r.purchaseUnitLabel == null
                  ? '—'
                  : '${(q / r.purchaseUnitQty!).ceil()} × ${r.purchaseUnitLabel}',
              r.lastUnitCost > 0 ? '${c.money(r.lastUnitCost)} / ${c.unit(r.unitCode)}' : '—',
              c.money(q * r.lastUnitCost),
            ],
          ['', '', '', t.estimatedTotal, c.money(total)],
        ],
      ),
      pw.SizedBox(height: 24),
      pw.Text(pdfText(t.orderFormFooter), style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
    ],
  );
}
