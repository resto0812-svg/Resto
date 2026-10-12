// Génère supabase/seed/ref_iso.sql à partir des sources officielles :
//   - ISO 4217 : liste « one » de l'agence de maintenance (SIX Group) ;
//   - ISO 3166-1 : projet Debian iso-codes (maintenu, licence LGPL).
// Usage : dart run tool/generer_referentiels.dart [iso4217.xml iso_3166-1.json]
// Le fichier produit est rejouable (on conflict do update) et ne supprime rien.
import 'dart:convert';
import 'dart:io';

import 'package:xml/xml.dart';

const _iso4217Url =
    'https://www.six-group.com/dam/download/financial-information/data-center/iso-currrency/lists/list-one.xml';
const _iso3166Url =
    'https://salsa.debian.org/iso-codes-team/iso-codes/-/raw/main/data/iso_3166-1.json';

Future<String> _download(String url) async {
  final client = HttpClient();
  try {
    final request = await client.getUrl(Uri.parse(url));
    final response = await request.close();
    if (response.statusCode != 200) {
      throw HttpException('HTTP ${response.statusCode}', uri: Uri.parse(url));
    }
    return await response.transform(utf8.decoder).join();
  } finally {
    client.close();
  }
}

String _q(String s) => "'${s.replaceAll("'", "''")}'";

/// Monnaies : code → (numérique, décimales, nom). Les entrées sans
/// décimales définies (« N.A. » : or, fonds…) sont écartées.
Map<String, (String, int, String)> parseCurrencies(String xmlText) {
  final result = <String, (String, int, String)>{};
  for (final entry in XmlDocument.parse(xmlText).findAllElements('CcyNtry')) {
    final code = entry.getElement('Ccy')?.innerText.trim();
    final number = entry.getElement('CcyNbr')?.innerText.trim();
    final minor = int.tryParse(entry.getElement('CcyMnrUnts')?.innerText.trim() ?? '');
    final name = entry.getElement('CcyNm')?.innerText.trim();
    if (code == null || number == null || minor == null || name == null) continue;
    if (!RegExp(r'^[A-Z]{3}$').hasMatch(code) || minor < 0 || minor > 4) continue;
    result[code] = (number.padLeft(3, '0'), minor, name);
  }
  return result;
}

/// Pays : alpha-2 → (alpha-3, numérique, nom anglais).
Map<String, (String, String, String)> parseCountries(String jsonText) {
  final list = (jsonDecode(jsonText) as Map<String, dynamic>)['3166-1'] as List<dynamic>;
  final result = <String, (String, String, String)>{};
  for (final item in list.cast<Map<String, dynamic>>()) {
    final a2 = item['alpha_2'] as String?;
    final a3 = item['alpha_3'] as String?;
    final num = item['numeric'] as String?;
    final name = item['name'] as String?;
    if (a2 == null || a3 == null || num == null || name == null) continue;
    result[a2] = (a3, num, name);
  }
  return result;
}

String buildSql(Map<String, (String, int, String)> currencies,
    Map<String, (String, String, String)> countries, DateTime generatedAt) {
  final b = StringBuffer()
    ..writeln('-- Généré par tool/generer_referentiels.dart le ${generatedAt.toUtc().toIso8601String()}')
    ..writeln('-- Sources : ISO 4217 (SIX Group), ISO 3166-1 (Debian iso-codes).')
    ..writeln('-- Rejouable ; ne supprime aucune ligne. À coller après 001_fondations.sql.')
    ..writeln('begin;')
    ..writeln('insert into public.ref_currencies (code, numeric_code, minor_unit, name) values');
  final cur = currencies.keys.toList()..sort();
  b.writeln(cur.map((c) {
    final (n, m, name) = currencies[c]!;
    return '  (${_q(c)}, ${_q(n)}, $m, ${_q(name)})';
  }).join(',\n'));
  b
    ..writeln('on conflict (code) do update set numeric_code = excluded.numeric_code,')
    ..writeln('  minor_unit = excluded.minor_unit, name = excluded.name;')
    ..writeln('insert into public.ref_countries (code, alpha3, numeric_code, name) values');
  final ctr = countries.keys.toList()..sort();
  b.writeln(ctr.map((c) {
    final (a3, n, name) = countries[c]!;
    return '  (${_q(c)}, ${_q(a3)}, ${_q(n)}, ${_q(name)})';
  }).join(',\n'));
  b
    ..writeln('on conflict (code) do update set alpha3 = excluded.alpha3,')
    ..writeln('  numeric_code = excluded.numeric_code, name = excluded.name;')
    ..writeln('commit;');
  return b.toString();
}

/// Sans argument : téléchargement direct. Avec deux chemins (fichiers
/// récupérés autrement, ex. derrière un proxy) : lecture locale.
Future<void> main(List<String> args) async {
  final local = args.length == 2;
  final currencies = parseCurrencies(local ? await File(args[0]).readAsString() : await _download(_iso4217Url));
  final countries = parseCountries(local ? await File(args[1]).readAsString() : await _download(_iso3166Url));
  // Garde-fous : une source tronquée ne doit pas produire un seed incomplet.
  if (currencies.length < 150 || countries.length < 240) {
    stderr.writeln('Sources incomplètes : ${currencies.length} monnaies, ${countries.length} pays.');
    exit(1);
  }
  final out = File('supabase/seed/ref_iso.sql');
  await out.writeAsString(buildSql(currencies, countries, DateTime.now()));
  stdout.writeln('${out.path} : ${currencies.length} monnaies, ${countries.length} pays.');
}
