import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../data/models.dart';
import '../data/purchases_api.dart';
import '../l10n/app_localizations.dart';
import 'pdf_fonts.dart';

/// Documents d'achat (A4) : bon de commande à envoyer au fournisseur et
/// relevé de compte fournisseur (factures, paiements, solde).
class PurchaseDocContext {
  PurchaseDocContext({required this.t, required this.locale, required this.money, required this.branch});
  final AppLocalizations t;
  final String locale;
  final String Function(int minor) money;
  final Branch branch;
}

const _gold = PdfColor.fromInt(0xFFC69C3A);
const _ink = PdfColor.fromInt(0xFF231A12);
const _band = PdfColor.fromInt(0xFFF2E8D6);
const _muted = PdfColor.fromInt(0xFF7A6E60);

Future<Uint8List> _a4(PurchaseDocContext c, String title, String subtitle, List<pw.Widget> body) async {
  final fonts = await PdfFonts.load();
  final b = c.branch;
  final address = [b.addressLine1, b.city].whereType<String>().where((s) => s.isNotEmpty).join(', ');
  final doc = pw.Document(theme: fonts.theme());
  doc.addPage(pw.MultiPage(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.fromLTRB(36, 30, 36, 30),
    header: (_) => pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Expanded(
          child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Text(pdfText(b.legalName?.isNotEmpty == true ? b.legalName! : b.name),
                style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: _ink)),
            if (address.isNotEmpty) pw.Text(pdfText(address), style: const pw.TextStyle(fontSize: 8.5, color: _muted)),
            if (b.phone?.isNotEmpty == true) pw.Text(pdfText(b.phone!), style: const pw.TextStyle(fontSize: 8.5, color: _muted)),
          ]),
        ),
        pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
          pw.Text(pdfText(title), style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: _gold)),
          pw.Text(pdfText(subtitle), style: const pw.TextStyle(fontSize: 9, color: _muted)),
        ]),
      ]),
      pw.SizedBox(height: 6),
      pw.Container(height: 1.2, color: _gold),
      pw.SizedBox(height: 10),
    ]),
    footer: (ctx) => pw.Row(children: [
      pw.Expanded(
        child: pw.Text(pdfText(DateFormat.yMd(c.locale).add_Hm().format(DateTime.now())), style: const pw.TextStyle(fontSize: 7.5, color: _muted)),
      ),
      pw.Text('${ctx.pageNumber} / ${ctx.pagesCount}', style: const pw.TextStyle(fontSize: 7.5, color: _muted)),
    ]),
    build: (_) => body,
  ));
  return doc.save();
}

pw.Widget _table(List<String> head, List<List<String>> rows, Map<int, pw.Alignment> align) => pw.TableHelper.fromTextArray(
      headers: head.map(pdfText).toList(),
      data: [for (final r in rows) r.map(pdfText).toList()],
      headerStyle: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: _ink),
      headerDecoration: const pw.BoxDecoration(color: _band),
      cellStyle: const pw.TextStyle(fontSize: 9),
      cellAlignments: align,
      border: pw.TableBorder(horizontalInside: pw.BorderSide(color: PdfColors.grey300, width: 0.5)),
    );

pw.Widget _supplierBlock(AppLocalizations t, Supplier s) => pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(border: pw.Border.all(color: _gold, width: 0.8), borderRadius: pw.BorderRadius.circular(6)),
      child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Text(pdfText(t.supplierLabel), style: const pw.TextStyle(fontSize: 8, color: _muted)),
        pw.Text(pdfText(s.name), style: pw.TextStyle(fontSize: 11.5, fontWeight: pw.FontWeight.bold)),
        for (final l in [?s.contactName, ?s.phone, ?s.email, ?s.address]) pw.Text(pdfText(l), style: const pw.TextStyle(fontSize: 9)),
      ]),
    );

/// Bon de commande fournisseur : articles, quantités, prix, total, livraison souhaitée.
Future<Uint8List> purchaseOrderPdf(
  PurchaseDocContext c, {
  required PurchaseOrder po,
  required Supplier supplier,
  required String Function(String ingredientId) itemName,
  required String Function(String unitCode) unitName,
}) {
  final t = c.t;
  final day = DateFormat.yMMMd(c.locale);
  final qty = NumberFormat.decimalPatternDigits(locale: c.locale, decimalDigits: 2);
  return _a4(c, t.purchaseOrderTitle, t.poNumber(po.number), [
    _supplierBlock(t, supplier),
    pw.SizedBox(height: 10),
    if (po.expectedOn != null) pw.Text(pdfText(t.expectedOn(day.format(po.expectedOn!))), style: const pw.TextStyle(fontSize: 10)),
    pw.SizedBox(height: 10),
    _table(
      [t.articleLabel, t.quantity, t.unitPriceShort, t.total],
      [
        for (final l in po.lines)
          [
            itemName(l.ingredientId),
            '${qty.format(l.quantity)} ${unitName(l.unitCode)}',
            c.money((l.unitPrice).round()),
            c.money((l.unitPrice * l.quantity).round()),
          ],
      ],
      {1: pw.Alignment.centerRight, 2: pw.Alignment.centerRight, 3: pw.Alignment.centerRight},
    ),
    pw.SizedBox(height: 8),
    pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.Text(pdfText('${t.total} : ${c.money(po.totalMinor)}'), style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
    ),
    if (po.note?.isNotEmpty == true) ...[
      pw.SizedBox(height: 12),
      pw.Text(pdfText(po.note!), style: const pw.TextStyle(fontSize: 9.5, color: _muted)),
    ],
  ]);
}

/// Relevé de compte fournisseur : factures (montant, payé, reste) et solde dû.
Future<Uint8List> supplierStatementPdf(PurchaseDocContext c, {required Supplier supplier, required List<SupplierInvoice> invoices}) {
  final t = c.t;
  final day = DateFormat.yMMMd(c.locale);
  final open = invoices.where((i) => i.status == 'open').toList();
  final due = open.fold<int>(0, (a, i) => a + i.dueMinor);
  return _a4(c, t.supplierStatementTitle, day.format(DateTime.now()), [
    _supplierBlock(t, supplier),
    pw.SizedBox(height: 12),
    _table(
      [t.invoiceNumber, t.dateLabel, t.dueDateLabel, t.total, t.paidShort, t.remainingDue],
      [
        for (final i in invoices.where((i) => i.status != 'cancelled'))
          [
            i.number,
            day.format(i.invoiceDate),
            i.dueDate == null ? '—' : day.format(i.dueDate!),
            c.money(i.totalMinor),
            c.money(i.paidMinor),
            c.money(i.status == 'open' ? i.dueMinor : 0),
          ],
      ],
      {3: pw.Alignment.centerRight, 4: pw.Alignment.centerRight, 5: pw.Alignment.centerRight},
    ),
    pw.SizedBox(height: 10),
    pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.Text(pdfText('${t.balanceDue} : ${c.money(due)}'), style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: _ink)),
    ),
  ]);
}
