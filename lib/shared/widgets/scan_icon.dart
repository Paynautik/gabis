import 'package:flutter/material.dart';

/// "Scan" as four corner brackets and a scan line, drawn in the same stroke
/// weight as the outline icons it sits beside (support, notifications). The
/// stock QR glyph is a dense pixel grid that reads heavier than its neighbours.
class ScanIcon extends StatelessWidget {
  final double size;
  final Color? color;
  const ScanIcon({super.key, this.size = 24, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? IconTheme.of(context).color ?? Colors.black;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _ScanPainter(c)),
    );
  }
}

class _ScanPainter extends CustomPainter {
  final Color color;
  _ScanPainter(this.color);

  @override
  void paint(Canvas canvas, Size s) {
    final u = s.width / 24;
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2 * u
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Corner brackets with rounded outer corners.
    const inset = 3.0, len = 5.0, r = 2.0;
    for (final (x, y, dx, dy) in [
      (inset, inset, 1.0, 1.0),
      (24 - inset, inset, -1.0, 1.0),
      (inset, 24 - inset, 1.0, -1.0),
      (24 - inset, 24 - inset, -1.0, -1.0),
    ]) {
      final path = Path()
        ..moveTo(x * u, (y + dy * len) * u)
        ..lineTo(x * u, (y + dy * r) * u)
        ..quadraticBezierTo(x * u, y * u, (x + dx * r) * u, y * u)
        ..lineTo((x + dx * len) * u, y * u);
      canvas.drawPath(path, p);
    }

    // The scan line.
    canvas.drawLine(Offset(7 * u, 12 * u), Offset(17 * u, 12 * u), p);
  }

  @override
  bool shouldRepaint(_ScanPainter old) => old.color != color;
}
