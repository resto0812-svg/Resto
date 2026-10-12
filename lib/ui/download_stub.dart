import 'package:flutter/services.dart';

/// Hors Web : le contenu est copié dans le presse-papiers.
Future<bool> exportText(String filename, String content, String mime) async {
  await Clipboard.setData(ClipboardData(text: content));
  return false;
}
