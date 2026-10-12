import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import 'download_stub.dart' if (dart.library.js_interop) 'download_web.dart' as dl;

/// Justificatif choisi par l'utilisateur (PDF ou photo, 5 Mo au plus).
class PickedDocument {
  PickedDocument(this.name, this.extension, this.bytes);
  final String name;
  final String extension;
  final Uint8List bytes;
}

const maxDocumentBytes = 5 * 1024 * 1024;

Future<PickedDocument?> pickDocument() async {
  final f = await FilePicker.pickFile(
    type: FileType.custom,
    allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png', 'webp'],
  );
  if (f == null) return null;
  final dot = f.name.lastIndexOf('.');
  final ext = dot < 0 ? 'pdf' : f.name.substring(dot + 1).toLowerCase();
  return PickedDocument(f.name, ext, await f.readAsBytes());
}

const maxLogoBytes = 1024 * 1024;

/// Image (logo) : PNG, JPEG ou WebP.
Future<PickedDocument?> pickImage() async {
  final f = await FilePicker.pickFile(
    type: FileType.custom,
    allowedExtensions: const ['png', 'jpg', 'jpeg', 'webp'],
  );
  if (f == null) return null;
  final dot = f.name.lastIndexOf('.');
  final ext = dot < 0 ? 'png' : f.name.substring(dot + 1).toLowerCase();
  return PickedDocument(f.name, ext, await f.readAsBytes());
}

/// Photos 5 Mo, vidéos 50 Mo au plus (médiathèque publicitaire).
const maxPhotoBytes = 5 * 1024 * 1024;
const maxVideoBytes = 50 * 1024 * 1024;
const _videoExtensions = ['mp4', 'webm', 'mov'];

bool isVideoName(String name) => _videoExtensions.contains(name.split('.').last.toLowerCase());

/// Photos et/ou vidéos (plusieurs à la fois si [multiple]).
Future<List<PickedDocument>> pickMedia({bool videos = true, bool images = true, bool multiple = true}) async {
  final extensions = [if (images) ...['png', 'jpg', 'jpeg', 'webp'], if (videos) ..._videoExtensions];
  final files = multiple
      ? await FilePicker.pickFiles(type: FileType.custom, allowedExtensions: extensions)
      : [?await FilePicker.pickFile(type: FileType.custom, allowedExtensions: extensions)];
  return [
    for (final f in files)
      PickedDocument(f.name, f.name.contains('.') ? f.name.split('.').last.toLowerCase() : 'jpg', await f.readAsBytes()),
  ];
}

Future<void> openLink(String url) => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);

/// Exporte un fichier texte : téléchargement sur le Web ; ailleurs, copie dans
/// le presse-papiers (renvoie false dans ce cas).
Future<bool> exportText(String filename, String content, String mime) => dl.exportText(filename, content, mime);

/// CSV compatible tableurs (séparateur « ; », guillemets, BOM UTF-8 pour Excel).
String toCsv(List<String> header, List<List<Object?>> rows) {
  String cell(Object? v) {
    final s = v?.toString() ?? '';
    return (s.contains(';') || s.contains('"') || s.contains('\n')) ? '"${s.replaceAll('"', '""')}"' : s;
  }

  final b = StringBuffer('﻿')..writeln(header.map(cell).join(';'));
  for (final r in rows) {
    b.writeln(r.map(cell).join(';'));
  }
  return b.toString();
}
