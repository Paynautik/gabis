import 'dart:math' as math;
import 'package:flutter/material.dart';

class NautikLogoMark extends StatelessWidget {
  final double size;
  const NautikLogoMark({super.key, this.size = 32});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        'assets/logo_mark.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          // Fallback vector painter if AssetManifest is loading
          return CustomPaint(
            size: Size(size, size),
            painter: _ElumoOfficialLogoPainter(),
          );
        },
      ),
    );
  }
}

class _ElumoOfficialLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w * 0.50, h * 0.50);
    final outerRadius = w * 0.46;
    final strokeWidth = w * 0.22;

    // 1. Cyan-to-Blue Gradient Ring
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = const SweepGradient(
        colors: [
          Color(0xFF00E5BE), // Bright Turquoise / Cyan
          Color(0xFF00B0FF), // Sky Blue
          Color(0xFF0052FF), // Royal Blue
          Color(0xFF00D2B4), // Teal
          Color(0xFF00E5BE),
        ],
        stops: [0.0, 0.35, 0.70, 0.90, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: outerRadius));

    // Draw almost complete circle arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: outerRadius - strokeWidth * 0.5),
      -math.pi * 0.35,
      math.pi * 1.75,
      false,
      ringPaint,
    );

    // 2. Dark Navy Arrow / "1" cutting the lower right
    final arrowPaint = Paint()
      ..color = const Color(0xFF0A192F)
      ..style = PaintingStyle.fill;

    final arrowPath = Path()
      ..moveTo(w * 0.64, h * 0.36) // Top beak
      ..lineTo(w * 0.74, h * 0.30) // Arrow tip
      ..lineTo(w * 0.74, h * 0.88) // Bottom right
      ..lineTo(w * 0.64, h * 0.88) // Bottom left
      ..lineTo(w * 0.64, h * 0.46) // Inner stem
      ..lineTo(w * 0.58, h * 0.50) // Beak underside
      ..close();

    canvas.drawPath(arrowPath, arrowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
