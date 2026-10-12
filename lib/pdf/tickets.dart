import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../data/order_models.dart';
import '../l10n/app_localizations.dart';
import 'pdf_fonts.dart';

/// Tickets au format rouleau 80 mm (imprimante thermique ou PDF) :
/// bon de préparation pour la cuisine, addition pour le client.
class TicketContext {
  TicketContext({
    required this.t,
    required this.locale,
    required this.minorUnit,
    required this.branchName,
    required this.place,
    this.branchAddress,
    this.branchPhone,
  });
  final AppLocalizations t;
  final String locale;
  final int minorUnit;
  final String branchName;
  final String? branchAddress;
  final String? branchPhone;

  /// « VIP 1 », « À emporter », « Livraison ».
  final String place;
}

pw.Widget _rule() => pw.Padding(
  padding: const pw.EdgeInsets.symmetric(vertical: 4),
  child: pw.Container(height: 0.6, color: PdfColors.grey600),
);

/// Bon de préparation : gros caractères, sans prix.
Future<Uint8List> kitchenTicketPdf(TicketContext c, Order o, {List<OrderLine>? lines}) async {
  final fonts = await PdfFonts.load();
  final t = c.t;
  final time = DateFormat.Hm(c.locale);
  final shown = (lines ?? o.lines.where((l) => !l.cancelled && !l.held)).toList();
  final doc = pw.Document(theme: fonts.theme());
  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.roll80,
      margin: const pw.EdgeInsets.all(8),
      build: (_) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          pw.Text(pdfText(c.place.toUpperCase()), style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
          pw.Text(pdfText('${t.orderNumber(o.number)} · ${time.format(DateTime.now())}'), style: const pw.TextStyle(fontSize: 10)),
          if (o.customerName != null) pw.Text(pdfText(o.customerName!), style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
          if (o.guests != null) pw.Text(pdfText(t.guestsCount(o.guests!)), style: const pw.TextStyle(fontSize: 10)),
          if (o.scheduledFor != null)
            pw.Text(
              pdfText(t.forTime(time.format(o.scheduledFor!.toLocal()))),
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
            ),
          _rule(),
          for (final l in shown) ...[
            pw.Text(pdfText('${l.quantity} × ${l.title}'), style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            for (final opt in l.options) pw.Text(pdfText('   + ${opt.name}'), style: const pw.TextStyle(fontSize: 11)),
            if (l.note != null) pw.Text(pdfText('   » ${l.note}'), style: pw.TextStyle(fontSize: 11, fontStyle: pw.FontStyle.italic)),
            pw.SizedBox(height: 4),
          ],
          if (o.note != null) ...[_rule(), pw.Text(pdfText(o.note!), style: const pw.TextStyle(fontSize: 11))],
        ],
      ),
    ),
  );
  return doc.save();
}

/// Impression (ou PDF) selon l'appareil : boîte d'impression du système.
Future<void> printTicket(Uint8List bytes, String name, {PdfPageFormat format = PdfPageFormat.roll80}) =>
    Printing.layoutPdf(onLayout: (_) async => bytes, name: name, format: format);
