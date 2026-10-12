import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart' show PdfGoogleFonts;

/// Polices des documents PDF (tickets, rapports) : Noto Sans, téléchargée une
/// fois ; Helvetica si le réseau ne répond pas.
class PdfFonts {
  PdfFonts._(this.regular, this.bold);
  final pw.Font regular;
  final pw.Font bold;

  static PdfFonts? _cache;

  static Future<PdfFonts> load() async {
    if (_cache != null) return _cache!;
    // Polices intégrées à l'application (aucun réseau nécessaire).
    try {
      final f = await Future.wait([bundledFont('NotoSans-Regular.ttf'), bundledFont('NotoSans-Bold.ttf')]);
      return _cache = PdfFonts._(f[0], f[1]);
    } catch (_) {}
    try {
      final f = await Future.wait([PdfGoogleFonts.notoSansRegular(), PdfGoogleFonts.notoSansBold()]);
      return _cache = PdfFonts._(f[0], f[1]);
    } catch (_) {
      return PdfFonts._(pw.Font.helvetica(), pw.Font.helveticaBold());
    }
  }

  pw.ThemeData theme() => pw.ThemeData.withFont(base: regular, bold: bold);
}

/// Police intégrée (assets/google_fonts/).
Future<pw.Font> bundledFont(String file) async => pw.Font.ttf(await rootBundle.load('assets/google_fonts/$file'));

/// Espaces insécables des montants formatés → espaces simples (lisibles partout).
String pdfText(String s) => s.replaceAll(' ', ' ').replaceAll(' ', ' ');
