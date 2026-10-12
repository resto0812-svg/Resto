import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../data/dashboard_api.dart';
import '../data/models.dart';
import '../data/purchases_api.dart';
import '../l10n/app_localizations.dart';
import 'pdf_fonts.dart';

/// Rapport du tableau de bord (A4) : chiffres clés, ventes par jour, plats,
/// moyens de paiement, équipe, temps de service, annulations, résultat.
class DashboardPdfContext {
  DashboardPdfContext({
    required this.t,
    required this.locale,
    required this.money,
    required this.branch,
    required this.from,
    required this.to,
  });
  final AppLocalizations t;
  final String locale;
  final String Function(int minor) money;
  final Branch branch;
  final DateTime from;
  final DateTime to;
}

const _gold = PdfColor.fromInt(0xFFC69C3A);
const _ink = PdfColor.fromInt(0xFF231A12);
const _band = PdfColor.fromInt(0xFFF2E8D6);
const _muted = PdfColor.fromInt(0xFF7A6E60);

Future<Uint8List> dashboardPdf(DashboardPdfContext c, Dashboard d, Insights? i, FinanceSummary f) async {
  final fonts = await PdfFonts.load();
  final t = c.t;
  final day = DateFormat.yMMMd(c.locale);
  String m(int v) => pdfText(c.money(v));

  pw.Widget kpi(String label, String value, [String? sub]) => pw.Container(
        width: 122,
        padding: const pw.EdgeInsets.all(8),
        decoration: pw.BoxDecoration(border: pw.Border.all(color: _gold, width: 0.8), borderRadius: pw.BorderRadius.circular(6)),
        child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Text(pdfText(label), style: const pw.TextStyle(fontSize: 8, color: _muted)),
          pw.Text(pdfText(value), style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: _ink)),
          if (sub != null) pw.Text(pdfText(sub), style: const pw.TextStyle(fontSize: 7.5, color: _muted)),
        ]),
      );
  pw.Widget title(String s) => pw.Padding(
        padding: const pw.EdgeInsets.only(top: 14, bottom: 6),
        child: pw.Text(pdfText(s), style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: _gold)),
      );
  pw.Widget table(List<String> head, List<List<String>> rows, {Map<int, pw.Alignment>? align}) => pw.TableHelper.fromTextArray(
        headers: head.map(pdfText).toList(),
        data: [for (final r in rows) r.map(pdfText).toList()],
        headerStyle: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: _ink),
        headerDecoration: const pw.BoxDecoration(color: _band),
        cellStyle: const pw.TextStyle(fontSize: 8.5),
        cellAlignments: align ?? {},
        border: pw.TableBorder(horizontalInside: pw.BorderSide(color: PdfColors.grey300, width: 0.5)),
      );

  final right = {1: pw.Alignment.centerRight, 2: pw.Alignment.centerRight, 3: pw.Alignment.centerRight};
  final doc = pw.Document(theme: fonts.theme());
  doc.addPage(pw.MultiPage(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.fromLTRB(32, 28, 32, 28),
    header: (_) => pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      pw.Row(children: [
        pw.Expanded(
          child: pw.Text(pdfText(t.navReports), style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: _ink)),
        ),
        pw.Text(pdfText(c.branch.name), style: pw.TextStyle(fontSize: 11, color: _gold, fontWeight: pw.FontWeight.bold)),
      ]),
      pw.Text(pdfText('${day.format(c.from)} – ${day.format(c.to)}'), style: const pw.TextStyle(fontSize: 9, color: _muted)),
      pw.SizedBox(height: 4),
      pw.Container(height: 1.2, color: _gold),
      pw.SizedBox(height: 8),
    ]),
    footer: (ctx) => pw.Row(children: [
      pw.Expanded(
        child: pw.Text(pdfText(DateFormat.yMd(c.locale).add_Hm().format(DateTime.now())), style: const pw.TextStyle(fontSize: 7.5, color: _muted)),
      ),
      pw.Text('${ctx.pageNumber} / ${ctx.pagesCount}', style: const pw.TextStyle(fontSize: 7.5, color: _muted)),
    ]),
    build: (_) => [
      pw.Wrap(spacing: 8, runSpacing: 8, children: [
        kpi(t.salesOfPeriod, m(d.sales ?? 0), d.salesTrend == null ? null : '${d.salesTrend! >= 0 ? '+' : ''}${d.salesTrend!.toStringAsFixed(0)} %'),
        kpi(t.ordersCountLabel, '${d.ordersClosed}'),
        kpi(t.averageTicket, m(d.averageTicket)),
        if (i != null) kpi(t.coversLabel, '${i.covers}', t.perCoverLabel(c.money(i.perCover))),
        kpi(t.collected, m(f.collected)),
        kpi(t.grossMargin, m(f.grossMargin)),
        kpi(t.expensesExclTax, m(f.expensesHt)),
        kpi(t.estimatedResult, m(f.estimatedResult)),
      ]),
      if (i != null && i.ordersByDay.isNotEmpty) ...[
        title(t.salesByDay),
        table(
          [t.dateLabel, t.ordersCountLabel, t.salesInclTax],
          [for (final r in i.ordersByDay) [day.format(r.$1), '${r.$2}', m(r.$3)]],
          align: right,
        ),
      ],
      if (i != null && i.items.isNotEmpty) ...[
        title(t.topDishes),
        table([t.articleLabel, t.quantity, t.salesInclTax], [for (final x in i.items.take(15)) [x.name, '${x.quantity}', m(x.total)]],
            align: right),
      ],
      if (i != null && i.payments.isNotEmpty) ...[
        title(t.paymentsByMethod),
        table([t.paymentMethodLabel, t.ordersCountLabel, t.amountLabel, t.staffTips],
            [for (final p in i.payments) [p.$1, '${p.$4}', m(p.$3), m(p.$5)]], align: right),
      ],
      if (i != null && i.staff.isNotEmpty) ...[
        title(t.teamPerformance),
        table([t.memberLabel, t.staffOrders, t.staffSales, t.staffTips], [for (final s in i.staff) [s.$1, '${s.$2}', m(s.$3), m(s.$4)]],
            align: right),
      ],
      if (i != null) ...[
        title(t.serviceTimes),
        pw.Text(
          pdfText('${t.prepTime} : ${i.prepMinutes == null ? '—' : t.minutesValue(i.prepMinutes!.round())}   ·   '
              '${t.serveTime} : ${i.serveMinutes == null ? '—' : t.minutesValue(i.serveMinutes!.round())}   ·   '
              '${t.tableTime} : ${i.tableMinutes == null ? '—' : t.minutesValue(i.tableMinutes!.round())}'),
          style: const pw.TextStyle(fontSize: 9.5),
        ),
        title(t.cancellationsTitle),
        pw.Text(pdfText('${t.cancelledOrdersCount(i.cancelledOrders)} · ${c.money(i.cancelledOrdersAmount)}'),
            style: const pw.TextStyle(fontSize: 9.5)),
        pw.Text(pdfText('${t.cancelledItemsCount(i.cancelledItems)} · ${c.money(i.cancelledItemsAmount)}'),
            style: const pw.TextStyle(fontSize: 9.5)),
        for (final r in i.cancelReasons) pw.Text(pdfText('• ${r.$1} (${r.$2})'), style: const pw.TextStyle(fontSize: 9, color: _muted)),
      ],
      title(t.financialResult),
      table(
        [t.financeItemLabel, t.amountLabel],
        [
          [t.salesInclTax, m(f.salesTtc)],
          [t.salesExclTax, m(f.salesHt)],
          [t.costOfSales, m(f.cogs)],
          [t.grossMargin, m(f.grossMargin)],
          [t.lossesValue, m(f.losses)],
          [t.expensesExclTax, m(f.expensesHt)],
          [t.estimatedResult, m(f.estimatedResult)],
          [t.purchasesValue, m(f.purchases)],
          [t.supplierDebtShort, m(f.supplierDebt)],
        ],
        align: {1: pw.Alignment.centerRight},
      ),
      pw.SizedBox(height: 6),
      pw.Text(pdfText(t.resultDisclaimer), style: const pw.TextStyle(fontSize: 7.5, color: _muted)),
    ],
  ));
  return doc.save();
}
