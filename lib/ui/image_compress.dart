import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

import 'files.dart';

/// Photo prête à l'envoi : redimensionnée (1600 px au plus sur le grand côté)
/// et réencodée en JPEG, pour qu'une photo de téléphone (8 à 20 Mo) passe sous
/// la limite de 5 Mo sans perte visible. Les PNG transparents (logos) restent
/// en PNG. Une image illisible est renvoyée telle quelle (le serveur décidera).
Future<PickedDocument> compressPhoto(PickedDocument f, {int maxSide = 1600, int quality = 82}) async {
  if (isVideoName(f.name)) return f;
  try {
    final out = await compute(_compress, (f.bytes, f.extension, maxSide, quality));
    if (out == null) return f;
    final base = f.name.contains('.') ? f.name.substring(0, f.name.lastIndexOf('.')) : f.name;
    return PickedDocument('$base.${out.$2}', out.$2, out.$1);
  } catch (_) {
    return f;
  }
}

(Uint8List, String)? _compress((Uint8List, String, int, int) a) {
  final (bytes, ext, maxSide, quality) = a;
  final decoded = img.decodeImage(bytes);
  if (decoded == null) return null;
  final oriented = img.bakeOrientation(decoded);
  final big = oriented.width > maxSide || oriented.height > maxSide;
  final resized = big
      ? (oriented.width >= oriented.height
            ? img.copyResize(oriented, width: maxSide, interpolation: img.Interpolation.average)
            : img.copyResize(oriented, height: maxSide, interpolation: img.Interpolation.average))
      : oriented;
  final keepPng = ext == 'png' && resized.hasAlpha;
  if (!big && bytes.length <= 1024 * 1024 && (keepPng || ext == 'jpg' || ext == 'jpeg' || ext == 'webp')) return null;
  return keepPng
      ? (Uint8List.fromList(img.encodePng(resized, level: 6)), 'png')
      : (Uint8List.fromList(img.encodeJpg(resized, quality: quality)), 'jpg');
}

/// Vignette carrée (recadrée au centre) pour les tickets : petite et légère.
Future<Uint8List?> ticketThumbnail(Uint8List bytes, {int side = 140}) async {
  try {
    return await compute(_thumb, (bytes, side));
  } catch (_) {
    return null;
  }
}

Uint8List? _thumb((Uint8List, int) a) {
  final (bytes, side) = a;
  final decoded = img.decodeImage(bytes);
  if (decoded == null) return null;
  final square = img.copyResizeCropSquare(img.bakeOrientation(decoded), size: side, interpolation: img.Interpolation.average);
  return Uint8List.fromList(img.encodeJpg(square, quality: 80));
}
