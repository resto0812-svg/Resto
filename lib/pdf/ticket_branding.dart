import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'pdf_fonts.dart';

/// Identité du restaurant sur les tickets clients : logo, nom et slogan de la
/// marque, site, QR code, largeur du rouleau de l'imprimante.
class TicketBranding {
  const TicketBranding({
    this.logo,
    this.brandName,
    this.subtitle,
    this.slogan,
    this.farewell,
    this.website,
    this.qrUrl,
    this.qrTitle,
    this.qrCaption,
    this.paperMm = 80,
    this.items = const {},
  });

  /// Logo (PNG, JPEG ou WebP) ; un PNG transparent rend le mieux.
  final Uint8List? logo;
  final String? brandName;
  final String? subtitle;
  final String? slogan;

  /// « À très bientôt chez … » (réglage de l'établissement).
  final String? farewell;
  final String? website;
  final String? qrUrl;
  final String? qrTitle;
  final String? qrCaption;

  /// Rouleau de l'imprimante thermique : 80 mm (standard) ou 58 mm.
  final int paperMm;

  /// Article → description et vignette (photo de la carte).
  final Map<String, TicketItemInfo> items;

  static const none = TicketBranding();

  PdfPageFormat get pageFormat => paperMm == 58 ? PdfPageFormat.roll57 : PdfPageFormat.roll80;
}

class TicketItemInfo {
  const TicketItemInfo({this.description, this.photo});
  final String? description;
  final Uint8List? photo;
}

/// Ligne « libellé … valeur » d'un ticket.
class TicketRow {
  const TicketRow(this.left, [this.right = '', this.kind = TicketRowKind.normal]);
  final String left;
  final String right;
  final TicketRowKind kind;
}

enum TicketRowKind { normal, muted, detail, strong }

/// Article : nom, quantité, prix unitaire, total, options, description, photo.
class TicketItem {
  const TicketItem(
    this.label,
    this.amount, {
    this.quantity = 1,
    this.unitPrice = '',
    this.options = const [],
    this.description,
    this.photo,
  });
  final String label;
  final String amount;
  final int quantity;
  final String unitPrice;
  final List<String> options;
  final String? description;
  final Uint8List? photo;
}

/// Paiement : mode, montant, référence de la transaction, détails (monnaie…).
class TicketPayment {
  const TicketPayment({required this.method, required this.label, required this.amount, this.reference, this.details = const []});

  /// cash, card, mobile_money, transfer, other.
  final String method;
  final String label;
  final String amount;
  final String? reference;
  final List<TicketRow> details;
}

/// Contenu d'un ticket client (ticket de caisse ou addition), déjà formaté.
class TicketContent {
  const TicketContent({
    required this.title,
    this.subtitle,
    this.address = const [],
    this.phone,
    this.email,
    this.legalLines = const [],
    this.heading,
    this.info = const [],
    required this.columns,
    this.items = const [],
    this.extras = const [],
    required this.totalLabel,
    required this.totalAmount,
    this.payments = const [],
    this.paymentNotes = const [],
    this.approvedLabel,
    this.referenceLabel,
    required this.footer,
    this.seeYou,
    this.recycle,
  });

  final String title;
  final String? subtitle;
  final List<String> address;
  final String? phone;
  final String? email;

  /// Raison sociale, n° fiscal.
  final List<String> legalLines;

  /// « ADDITION » tant que la commande n'est pas soldée.
  final String? heading;

  /// « Établissement : … », « Date : … » (libellé, valeur).
  final List<TicketRow> info;

  /// Libellés des colonnes : article, quantité, prix unitaire, total.
  final (String, String, String, String) columns;
  final List<TicketItem> items;

  /// Réductions, frais, sous-total, taxe.
  final List<TicketRow> extras;
  final String totalLabel;
  final String totalAmount;
  final List<TicketPayment> payments;

  /// Reste à payer…
  final List<TicketRow> paymentNotes;
  final String? approvedLabel;

  /// « Réf. : {ref} » : modèle où {ref} est remplacé.
  final String? referenceLabel;
  final String footer;
  final String? seeYou;
  final String? recycle;
}

// Palette : bordeaux, or, crème (rendu en niveaux de gris sur une imprimante thermique).
const _ink = PdfColor.fromInt(0xFF1E1E1E);
const _muted = PdfColor.fromInt(0xFF6B6B6B);
const _wine = PdfColor.fromInt(0xFF6B1027);
const _gold = PdfColor.fromInt(0xFFB4873A);
const _cream = PdfColor.fromInt(0xFFF6EEE3);
const _line = PdfColor.fromInt(0xFFD9D4CC);

class _TicketFonts {
  _TicketFonts(this.base, this.serif, this.serifItalic, this.icons);
  final PdfFonts base;
  final pw.Font serif;
  final pw.Font serifItalic;
  final pw.Font? icons;

  static _TicketFonts? _cache;

  static Future<_TicketFonts> load() async {
    if (_cache != null) return _cache!;
    final base = await PdfFonts.load();
    pw.Font? icons;
    try {
      icons = await PdfGoogleFonts.materialIcons();
    } catch (_) {
      icons = null;
    }
    try {
      final f = await Future.wait([PdfGoogleFonts.playfairDisplayBold(), PdfGoogleFonts.playfairDisplayBoldItalic()]);
      return _cache = _TicketFonts(base, f[0], f[1], icons);
    } catch (_) {
      return _TicketFonts(base, pw.Font.timesBold(), pw.Font.timesBoldItalic(), icons);
    }
  }
}

// Pictogrammes (police Material Icons).
const _icPlace = 0xe0c8;
const _icPhone = 0xe0cd;
const _icWeb = 0xe894;
const _icMail = 0xe158;
const _icCard = 0xe870;
const _icCash = 0xef63;
const _icMobile = 0xe32c;
const _icBank = 0xe84f;
const _icCheck = 0xe86c;
const _icCrown = 0xe7af;
const _icStar = 0xe838;
const _icLeaf = 0xea35;

/// Ticket client pour imprimante thermique (rouleau 80 ou 58 mm) : en-tête de
/// la maison, informations, tableau des articles, totaux, paiement, QR code,
/// remerciements.
Future<Uint8List> customerTicketPdf(TicketContent c, TicketBranding b) async {
  final fonts = await _TicketFonts.load();
  final narrow = b.paperMm == 58;
  final regular = fonts.base.regular;
  final fallback = [regular];
  pw.TextStyle st(double size, {PdfColor color = _ink, bool bold = false, double spacing = 0, pw.Font? font}) => pw.TextStyle(
    font: font ?? (bold ? fonts.base.bold : regular),
    fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
    fontFallback: fallback,
    fontSize: size,
    color: color,
    letterSpacing: spacing,
    lineSpacing: 1,
  );
  pw.Widget text(String s, pw.TextStyle style, {pw.TextAlign? align, int? maxLines}) =>
      pw.Text(pdfText(s), style: style, textAlign: align, maxLines: maxLines);
  pw.Widget icon(int code, double size, {PdfColor color = _wine}) => fonts.icons == null
      ? pw.SizedBox(width: size, height: size)
      : pw.Text(
          String.fromCharCode(code),
          style: pw.TextStyle(font: fonts.icons, fontSize: size, color: color),
        );
  pw.ImageProvider? image(Uint8List? bytes) {
    if (bytes == null) return null;
    try {
      return pw.MemoryImage(bytes);
    } catch (_) {
      return null;
    }
  }

  final logo = image(b.logo);
  final qr = (b.qrUrl == null || b.qrUrl!.isEmpty) ? null : b.qrUrl!;
  final s = narrow ? 0.9 : 1.0;

  pw.Widget rule({double v = 6}) => pw.Padding(
    padding: pw.EdgeInsets.symmetric(vertical: v),
    child: pw.Container(height: 0.6, color: _line),
  );
  pw.Widget goldDash() => pw.Center(child: pw.Container(width: 22, height: 0.9, color: _gold));
  pw.Widget dashed() => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 8),
    child: pw.Container(
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: _muted, width: 0.6, style: pw.BorderStyle.dashed),
        ),
      ),
    ),
  );

  // ---------------------------------------------------------------- en-tête
  pw.Widget contact(int code, String value) => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 1.2),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(width: 13, child: icon(code, 9)),
        pw.SizedBox(width: 4),
        pw.Expanded(child: text(value, st(7.6 * s))),
      ],
    ),
  );
  pw.Widget info(TicketRow r) => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 1),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(width: narrow ? 58 : 70, child: text(r.left, st(7.4 * s, bold: true))),
        text(':  ', st(7.4 * s)),
        pw.Expanded(
          child: text(r.right, st(7.4 * s, color: r.kind == TicketRowKind.strong ? _wine : _ink, bold: r.kind == TicketRowKind.strong)),
        ),
      ],
    ),
  );

  // ---------------------------------------------------------------- articles
  final photos = c.items.any((i) => i.photo != null);
  final thumb = narrow ? 20.0 : 27.0;
  const qtyW = 18.0;
  final puW = narrow ? 0.0 : 44.0;
  final totalW = narrow ? 42.0 : 46.0;

  pw.Widget tableHeader() => pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 4),
    decoration: pw.BoxDecoration(color: _wine, borderRadius: pw.BorderRadius.circular(3)),
    child: pw.Row(
      children: [
        pw.Expanded(child: text(c.columns.$1, st(7.6 * s, color: PdfColors.white, bold: true))),
        pw.SizedBox(
          width: qtyW,
          child: text(c.columns.$2, st(7.2 * s, color: PdfColors.white, bold: true), align: pw.TextAlign.center),
        ),
        if (!narrow)
          pw.SizedBox(
            width: puW,
            child: pw.FittedBox(
              fit: pw.BoxFit.scaleDown,
              alignment: pw.Alignment.centerRight,
              child: text(c.columns.$3, st(7.2, color: PdfColors.white, bold: true)),
            ),
          ),
        pw.SizedBox(
          width: totalW,
          child: text(c.columns.$4, st(7.6 * s, color: PdfColors.white, bold: true), align: pw.TextAlign.right),
        ),
      ],
    ),
  );

  pw.Widget itemRow(TicketItem it, bool last) {
    final photo = image(it.photo);
    return pw.Container(
      padding: const pw.EdgeInsets.fromLTRB(2, 5, 3, 5),
      decoration: last
          ? null
          : const pw.BoxDecoration(
              border: pw.Border(bottom: pw.BorderSide(color: _line, width: 0.5)),
            ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          if (photos)
            pw.Padding(
              padding: const pw.EdgeInsets.only(right: 5),
              child: pw.ClipRRect(
                horizontalRadius: 3,
                verticalRadius: 3,
                child: pw.Container(
                  width: thumb,
                  height: thumb,
                  color: _cream,
                  child: photo == null ? null : pw.Image(photo, fit: pw.BoxFit.cover),
                ),
              ),
            ),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                text(it.label, st(8.2 * s, bold: true)),
                if (it.description != null && it.description!.trim().isNotEmpty)
                  text(it.description!.trim(), st(6.6 * s, color: _muted), maxLines: 2),
                for (final o in it.options) text('+ $o', st(6.8 * s, color: _muted)),
                if (narrow && it.unitPrice.isNotEmpty) text('${it.quantity} × ${it.unitPrice}', st(6.8 * s, color: _muted)),
              ],
            ),
          ),
          pw.SizedBox(
            width: qtyW,
            child: text('${it.quantity}', st(8.2 * s), align: pw.TextAlign.center),
          ),
          if (!narrow)
            pw.SizedBox(
              width: puW,
              child: pw.FittedBox(fit: pw.BoxFit.scaleDown, alignment: pw.Alignment.topRight, child: text(it.unitPrice, st(7.8))),
            ),
          pw.SizedBox(
            width: totalW,
            child: pw.FittedBox(
              fit: pw.BoxFit.scaleDown,
              alignment: pw.Alignment.topRight,
              child: text(it.amount, st(8.2 * s, bold: true)),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------- totaux
  pw.Widget totalRow(TicketRow r) => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 1.6, horizontal: 6),
    child: pw.Row(
      children: [
        pw.Expanded(child: text(r.left, st(8 * s, color: r.kind == TicketRowKind.muted ? _muted : _ink))),
        text(r.right, st(8 * s, bold: r.kind != TicketRowKind.muted)),
      ],
    ),
  );
  final totals = pw.Row(
    children: [
      pw.Spacer(flex: narrow ? 1 : 3),
      pw.Expanded(
        flex: 7,
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            for (final r in c.extras) totalRow(r),
            pw.SizedBox(height: 3),
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
              decoration: pw.BoxDecoration(color: _cream, borderRadius: pw.BorderRadius.circular(3)),
              child: pw.Row(
                children: [
                  pw.Expanded(child: text(c.totalLabel, st(9 * s, color: _wine, bold: true))),
                  text(c.totalAmount, st(13 * s, color: _wine, bold: true)),
                ],
              ),
            ),
          ],
        ),
      ),
    ],
  );

  // ---------------------------------------------------------------- paiement
  int payIcon(String m) => switch (m) {
    'cash' => _icCash,
    'mobile_money' => _icMobile,
    'transfer' => _icBank,
    _ => _icCard,
  };
  pw.Widget payment(TicketPayment p) => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 2),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Row(
          children: [
            pw.SizedBox(width: 15, child: icon(payIcon(p.method), 10.5)),
            pw.SizedBox(width: 4),
            pw.Expanded(child: text(p.label, st(8 * s))),
            text(p.amount, st(8 * s, bold: true)),
          ],
        ),
        if (p.reference != null && p.reference!.isNotEmpty)
          pw.Padding(
            padding: const pw.EdgeInsets.only(top: 3),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(width: 15, child: icon(_icCheck, 10.5)),
                pw.SizedBox(width: 4),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      if (c.approvedLabel != null) text(c.approvedLabel!, st(7.6 * s)),
                      text((c.referenceLabel ?? '{ref}').replaceAll('{ref}', p.reference!), st(7 * s, color: _muted)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        for (final d in p.details)
          pw.Padding(
            padding: const pw.EdgeInsets.only(left: 19, top: 1),
            child: pw.Row(
              children: [
                pw.Expanded(child: text(d.left, st(7 * s, color: _muted))),
                text(d.right, st(7 * s, color: _muted)),
              ],
            ),
          ),
      ],
    ),
  );

  pw.Widget qrBlock() => pw.Row(
    crossAxisAlignment: pw.CrossAxisAlignment.center,
    children: [
      pw.Container(
        padding: const pw.EdgeInsets.all(3),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: _line, width: 0.6),
          borderRadius: pw.BorderRadius.circular(3),
        ),
        child: pw.BarcodeWidget(
          barcode: pw.Barcode.qrCode(),
          data: qr!,
          width: narrow ? 46 : 54,
          height: narrow ? 46 : 54,
          drawText: false,
          color: _ink,
        ),
      ),
      pw.SizedBox(width: 8),
      pw.Expanded(
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            if (b.qrTitle != null)
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  icon(_icCrown, 10, color: _gold),
                  pw.SizedBox(width: 3),
                  pw.Expanded(child: text(b.qrTitle!, st(7.8 * s, color: _wine, bold: true))),
                ],
              ),
            if (b.qrCaption != null) ...[pw.SizedBox(height: 2), text(b.qrCaption!, st(6.6 * s, color: _muted))],
          ],
        ),
      ),
    ],
  );

  // ---------------------------------------------------------------- page
  final content = pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
    children: [
      if (logo != null)
        pw.Center(
          child: pw.ConstrainedBox(
            constraints: pw.BoxConstraints(maxHeight: narrow ? 38 : 48, maxWidth: narrow ? 90 : 120),
            child: pw.Image(logo, fit: pw.BoxFit.contain),
          ),
        ),
      if (logo != null) pw.SizedBox(height: 4),
      pw.Center(
        child: pw.FittedBox(
          fit: pw.BoxFit.scaleDown,
          child: text(c.title, st(narrow ? 17 : 21, color: _wine, font: fonts.serif)),
        ),
      ),
      if (c.subtitle != null && c.subtitle!.isNotEmpty) ...[
        pw.SizedBox(height: 2),
        pw.Center(
          child: text(c.subtitle!.toUpperCase(), st(6.4 * s, color: _gold, spacing: 2.2), align: pw.TextAlign.center),
        ),
      ],
      if (b.slogan != null && b.slogan!.trim().isNotEmpty) ...[
        pw.SizedBox(height: 6),
        pw.Center(
          child: text(
            b.slogan!.trim(),
            st(9 * s, color: _wine, font: fonts.serifItalic),
            align: pw.TextAlign.center,
          ),
        ),
        pw.SizedBox(height: 5),
        goldDash(),
      ],
      pw.SizedBox(height: 9),
      if (c.address.isNotEmpty) contact(_icPlace, c.address.join('\n')),
      if (c.phone != null) contact(_icPhone, c.phone!),
      if (b.website != null) contact(_icWeb, b.website!),
      if (c.email != null) contact(_icMail, c.email!),
      for (final l in c.legalLines)
        pw.Padding(
          padding: const pw.EdgeInsets.only(left: 17),
          child: text(l, st(6.8 * s, color: _muted)),
        ),
      if (c.heading != null) ...[
        pw.SizedBox(height: 8),
        pw.Center(child: text(c.heading!.toUpperCase(), st(12 * s, color: _wine, bold: true, spacing: 1.5))),
      ],
      rule(v: 7),
      for (final r in c.info) info(r),
      rule(v: 7),
      tableHeader(),
      for (var i = 0; i < c.items.length; i++) itemRow(c.items[i], i == c.items.length - 1),
      rule(v: 5),
      totals,
      if (c.payments.isNotEmpty || c.paymentNotes.isNotEmpty || qr != null) rule(v: 7),
      for (final p in c.payments) payment(p),
      for (final r in c.paymentNotes) totalRow(r),
      if (qr != null) ...[if (c.payments.isNotEmpty || c.paymentNotes.isNotEmpty) pw.SizedBox(height: 8), qrBlock()],
      dashed(),
      pw.Center(
        child: text(
          c.footer,
          st(narrow ? 12 : 14, color: _wine, font: fonts.serifItalic),
          align: pw.TextAlign.center,
        ),
      ),
      if (c.seeYou != null) ...[pw.SizedBox(height: 2), pw.Center(child: text(c.seeYou!, st(7.6 * s), align: pw.TextAlign.center))],
      pw.SizedBox(height: 5),
      goldDash(),
      pw.SizedBox(height: 5),
      pw.Center(
        child: pw.Row(
          mainAxisSize: pw.MainAxisSize.min,
          children: [
            for (var i = 0; i < 5; i++)
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(horizontal: 1.5),
                child: icon(_icStar, 9, color: _gold),
              ),
          ],
        ),
      ),
      if (c.recycle != null) ...[
        pw.SizedBox(height: 9),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            icon(_icLeaf, 10, color: _wine),
            pw.SizedBox(width: 4),
            pw.Flexible(child: text(c.recycle!, st(6.6 * s, color: _muted))),
          ],
        ),
      ],
    ],
  );

  final doc = pw.Document(theme: fonts.base.theme());
  doc.addPage(
    pw.Page(
      pageFormat: b.pageFormat,
      margin: narrow ? const pw.EdgeInsets.fromLTRB(6, 10, 6, 14) : const pw.EdgeInsets.fromLTRB(10, 12, 10, 16),
      build: (_) => content,
    ),
  );
  return doc.save();
}
