import 'dart:io';

/// Contrôle avant envoi d'un script SQL : dart run tool/check_sql.dart fichier.sql
// Équilibre des parenthèses par instruction (séparée par ';' hors chaînes/dollar-quotes/commentaires).
void main(List<String> a) {
  final s = File(a[0]).readAsStringSync();
  var depth = 0, line = 1, start = 1, inStr = false, inCom = false;
  String? dollar;
  for (var k = 0; k < s.length; k++) {
    final c = s[k];
    if (c == '\n') { line++; if (inCom) inCom = false; }
    if (inCom) continue;
    if (dollar != null) { if (s.startsWith(dollar, k)) { k += dollar.length - 1; dollar = null; } continue; }
    if (inStr) { if (c == "'") inStr = false; continue; }
    if (c == '-' && k + 1 < s.length && s[k + 1] == '-') { inCom = true; continue; }
    if (c == "'") { inStr = true; continue; }
    if (c == r'$') { final m = RegExp(r'\$[a-z_]*\$').matchAsPrefix(s, k); if (m != null) { dollar = m[0]; k += m[0]!.length - 1; continue; } }
    if (c == '(') depth++;
    if (c == ')') depth--;
    if (c == ';') { if (depth != 0) stdout.writeln('Instruction lignes $start-$line : déséquilibre $depth'); depth = 0; start = line; }
  }
  stdout.writeln('fin');
}
