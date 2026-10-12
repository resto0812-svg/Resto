import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../data/models.dart';
import '../data/purchases_api.dart';
import '../l10n/app_localizations.dart';
import 'pdf_fonts.dart';

const _gold = PdfColor.fromInt(0xFFC69C3A);
const _ink = PdfColor.fromInt(0xFF231A12);
const _band = PdfColor.fromInt(0xFFF2E8D6);
const _muted = PdfColor.fromInt(0xFF7A6E60);

/// Rapport des dépenses d'un mois (A4) : total, répartition par catégorie,
/// détail de chaque dépense (les dépenses annulées sont signalées à part).
Future<Uint8List> expensesPdf({
  required AppLocalizations t,
  required String locale,
  required String Function(int minor) money,
  required Branch branch,
  required DateTime month,
  required List<Expense> expenses,
  required String Function(String categoryId) categoryName,
}) async {
  final fonts = await PdfFonts.load();
  final day = DateFormat.yMMMd(locale);
  final recorded = expenses.where((e) => e.status == 'recorded').toList();
  final total = recorded.fold<int>(0, (a, e) => a + e.amountMinor);
  final tax = recorded.fold<int>(0, (a, e) => a + e.taxMinor);
  final byCat = <String, int>{};
  for (final e in recorded) {
    byCat[e.categoryId] = (byCat[e.categoryId] ?? 0) + e.amountMinor;
  }
  final split = byCat.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
  pw.Widget table(List<String> head, List<List<String>> rows, Map<int, pw.Alignment> align) => pw.TableHelper.fromTextArray(
        headers: head.map(pdfText).toList(),
        data: [for (final r in rows) r.map(pdfText).toList()],
        headerStyle: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: _ink),
        headerDecoration: const pw.BoxDecoration(color: _band),
        cellStyle: const pw.TextStyle(fontSize: 9),
        cellAlignments: align,
        border: pw.TableBorder(horizontalInside: pw.BorderSide(color: PdfColors.grey300, width: 0.5)),
      );
  final doc = pw.Document(theme: fonts.theme());
  doc.addPage(pw.MultiPage(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.fromLTRB(36, 30, 36, 30),
    header: (_) => pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      pw.Row(children: [
        pw.Expanded(
          child: pw.Text(pdfText(t.navExpenses), style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: _ink)),
        ),
        pw.Text(pdfText(branch.name), style: pw.TextStyle(fontSize: 11, color: _gold, fontWeight: pw.FontWeight.bold)),
      ]),
      pw.Text(pdfText(DateFormat.yMMMM(locale).format(month)), style: const pw.TextStyle(fontSize: 9.5, color: _muted)),
      pw.SizedBox(height: 4),
      pw.Container(height: 1.2, color: _gold),
      pw.SizedBox(height: 10),
    ]),
    footer: (ctx) => pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.Text('${ctx.pageNumber} / ${ctx.pagesCount}', style: const pw.TextStyle(fontSize: 7.5, color: _muted)),
    ),
    build: (_) => [
      pw.Text(pdfText(t.totalAmount(money(total))), style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
      if (tax > 0) pw.Text(pdfText(t.includingTax(money(tax))), style: const pw.TextStyle(fontSize: 9, color: _muted)),
      pw.SizedBox(height: 12),
      pw.Text(pdfText(t.expensesByCategory), style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: _gold)),
      pw.SizedBox(height: 6),
      table(
        [t.expenseCategoryField, t.amountLabel, '%'],
        [for (final e in split) [categoryName(e.key), money(e.value), total == 0 ? '0' : '${(e.value * 100 / total).round()}']],
        {1: pw.Alignment.centerRight, 2: pw.Alignment.centerRight},
      ),
      pw.SizedBox(height: 14),
      pw.Text(pdfText(t.navExpenses), style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: _gold)),
      pw.SizedBox(height: 6),
      table(
        [t.dateLabel, t.description, t.expenseCategoryField, t.amountLabel],
        [
          for (final e in expenses)
            [
              day.format(e.expenseDate),
              e.status == 'cancelled' ? '${e.description} (${t.cancelledLabel})' : e.description,
              categoryName(e.categoryId),
              money(e.amountMinor),
            ],
        ],
        {3: pw.Alignment.centerRight},
      ),
    ],
  ));
  return doc.save();
}
