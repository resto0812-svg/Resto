import 'package:flutter/material.dart';
import 'package:qr/qr.dart';

/// QR code dessiné directement (sans image), net à toutes les tailles.
class QrView extends StatelessWidget {
  const QrView({super.key, required this.data, this.size = 220});
  final String data;
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox.square(
        dimension: size,
        child: CustomPaint(painter: _QrPainter(QrImage(QrCode.fromData(data: data, errorCorrectLevel: QrErrorCorrectLevel.M)))),
      );
}

class _QrPainter extends CustomPainter {
  _QrPainter(this.image);
  final QrImage image;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.white);
    const quiet = 2;
    final cell = size.shortestSide / (image.moduleCount + quiet * 2);
    final paint = Paint()..color = Colors.black;
    for (var r = 0; r < image.moduleCount; r++) {
      for (var c = 0; c < image.moduleCount; c++) {
        if (image.isDark(r, c)) {
          canvas.drawRect(Rect.fromLTWH((c + quiet) * cell, (r + quiet) * cell, cell + 0.3, cell + 0.3), paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _QrPainter old) => old.image != image;
}
