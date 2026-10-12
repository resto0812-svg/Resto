import 'dart:io';
import 'dart:math';

import 'package:image/image.dart' as img;

/// Dessine l'icône de Resto (choix J : « r » blanc sur fond coupé en
/// diagonale bordeaux et or) en haute résolution :
///   dart run tool/gen_icon.dart
/// Produit assets/icon/icon.png (icône complète), icon_background.png et
/// icon_foreground.png (icône adaptative Android : fond et « r » séparés).
/// Le dessin est fait à 4 096 px puis réduit à 1 024 px pour des bords nets.
const _burgundy = (0x7A, 0x17, 0x30);
const _gold = (0xE9, 0xC4, 0x6A);
const _white = (0xFF, 0xFD, 0xF7);

const _big = 4096;
const _out = 1024;

img.Color _c((int, int, int) rgb, [int a = 255]) => img.ColorRgba8(rgb.$1, rgb.$2, rgb.$3, a);

/// Fond : bordeaux, avec le triangle inférieur droit en or.
void _background(img.Image im) {
  img.fill(im, color: _c(_burgundy));
  img.fillPolygon(
    im,
    vertices: [img.Point(0, _big), img.Point(_big, 0), img.Point(_big, _big)],
    color: _c(_gold),
  );
}

/// Le « r » : trait épais aux bouts arrondis (barre verticale, courbe, petite
/// barre horizontale), dessiné dans un repère de 120 unités.
void _letter(img.Image im, {double scale = 1, double cx = 60, double cy = 64}) {
  final u = _big / 120;
  final radius = 7.5 * scale * u;
  // Points du tracé dans le repère 120 × 120, puis mise à l'échelle autour de (cx, cy).
  Point<double> p(double x, double y) => Point((cx + (x - cx) * scale) * u, (cy + (y - cy) * scale) * u);
  final path = <Point<double>>[];
  for (var y = 90.0; y >= 54; y -= 0.05) {
    path.add(p(44, y));
  }
  // Courbe quadratique de (44, 54) à (62, 38), point de contrôle (44, 38).
  for (var t = 0.0; t <= 1; t += 0.0008) {
    final x = (1 - t) * (1 - t) * 44 + 2 * (1 - t) * t * 44 + t * t * 62;
    final y = (1 - t) * (1 - t) * 54 + 2 * (1 - t) * t * 38 + t * t * 38;
    path.add(p(x, y));
  }
  for (var x = 62.0; x <= 76; x += 0.05) {
    path.add(p(x, 38));
  }
  for (final pt in path) {
    img.fillCircle(im, x: pt.x.round(), y: pt.y.round(), radius: radius.round(), color: _c(_white));
  }
}

void _save(img.Image im, String path) {
  final small = img.copyResize(im, width: _out, height: _out, interpolation: img.Interpolation.average);
  File(path)
    ..createSync(recursive: true)
    ..writeAsBytesSync(img.encodePng(small));
  stdout.writeln('$path (${_out}×$_out)');
}

void main() {
  final full = img.Image(width: _big, height: _big);
  _background(full);
  _letter(full);
  _save(full, 'assets/icon/icon.png');

  final background = img.Image(width: _big, height: _big);
  _background(background);
  _save(background, 'assets/icon/icon_background.png');

  // Icône adaptative : le « r » réduit pour rester dans la zone visible
  // quel que soit le masque (cercle, goutte, carré arrondi).
  final foreground = img.Image(width: _big, height: _big, numChannels: 4);
  img.fill(foreground, color: img.ColorRgba8(0, 0, 0, 0));
  _letter(foreground, scale: 0.78, cx: 60, cy: 64);
  _save(foreground, 'assets/icon/icon_foreground.png');
}
