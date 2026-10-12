import 'dart:io';

/// Liste les fichiers de polices Google Fonts à intégrer à l'application :
///   dart run tool/list_fonts.dart <dossier google_fonts_parts>
/// Sortie : « empreinte nom-de-fichier » pour chaque variante retenue.
void main(List<String> args) {
  final dir = args.first;
  const wanted = {
    'poppins': ('Poppins', ['300', '400', '500', '600', '700', '800', '400i', '500i', '600i', '700i']),
    'playfairDisplay': ('PlayfairDisplay', ['400', '500', '600', '700', '800', '400i', '600i', '700i']),
    'notoSans': ('NotoSans', ['400', '700']),
  };
  const names = {
    '100': 'Thin', '200': 'ExtraLight', '300': 'Light', '400': 'Regular', '500': 'Medium',
    '600': 'SemiBold', '700': 'Bold', '800': 'ExtraBold', '900': 'Black',
  };
  for (final e in wanted.entries) {
    final file = File('$dir/part_${e.key[0].toLowerCase()}.dart').readAsStringSync();
    final start = file.indexOf('static TextStyle ${e.key}({');
    final body = file.substring(start, file.indexOf('return googleFontsTextStyle', start));
    final re = RegExp(r"fontWeight: FontWeight\.w(\d)00,\s*fontStyle: FontStyle\.(\w+),\s*\): GoogleFontsFile\(\s*'([0-9a-f]+)',\s*(\d+)");
    for (final m in re.allMatches(body)) {
      final w = '${m.group(1)}00';
      final italic = m.group(2) == 'italic';
      if (!e.value.$2.contains(italic ? '${w}i' : w)) continue;
      final variant = italic ? (w == '400' ? 'Italic' : '${names[w]}Italic') : names[w];
      stdout.writeln('${m.group(3)} ${m.group(4)} ${e.value.$1}-$variant.ttf');
    }
  }
}
