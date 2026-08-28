import 'package:flutter/material.dart';

class NautikLogoMark extends StatelessWidget {
  final double size;
  const NautikLogoMark({super.key, this.size = 32});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.25),
            blurRadius: size * 0.3,
            offset: Offset(0, size * 0.1),
          ),
        ],
      ),
      padding: EdgeInsets.all(size * 0.18),
      child: CustomPaint(
        painter: _NautikLogoPainter(),
      ),
    );
  }
}

class _NautikLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();
    final w = size.width;
    final h = size.height;

    // Bar 1 (Top Wave)
    path.moveTo(w * 0.18, h * 0.32);
    path.quadraticBezierTo(w * 0.18, h * 0.08, w * 0.44, h * 0.08);
    path.lineTo(w * 0.88, h * 0.08);
    path.quadraticBezierTo(w * 0.82, h * 0.32, w * 0.52, h * 0.32);
    path.close();

    // Bar 2 (Middle Wave)
    path.moveTo(w * 0.12, h * 0.60);
    path.quadraticBezierTo(w * 0.12, h * 0.36, w * 0.38, h * 0.36);
    path.lineTo(w * 0.78, h * 0.36);
    path.quadraticBezierTo(w * 0.72, h * 0.60, w * 0.46, h * 0.60);
    path.close();

    // Bar 3 (Bottom Wave)
    path.moveTo(w * 0.06, h * 0.88);
    path.quadraticBezierTo(w * 0.06, h * 0.64, w * 0.32, h * 0.64);
    path.lineTo(w * 0.70, h * 0.64);
    path.quadraticBezierTo(w * 0.64, h * 0.88, w * 0.40, h * 0.88);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
