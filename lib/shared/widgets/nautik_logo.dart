import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

class NautikLogoMark extends StatelessWidget {
  final double size;
  const NautikLogoMark({super.key, this.size = 32});

  @override
  Widget build(BuildContext context) {
    return GabismWordmark(height: size);
  }
}

class GabisLogo extends StatefulWidget {
  final bool? showingPay;
  final double size;
  final bool isWhite;

  const GabisLogo({
    super.key,
    this.showingPay,
    this.size = 32,
    this.isWhite = false,
  });

  @override
  State<GabisLogo> createState() => _GabisLogoState();
}

class _GabisLogoState extends State<GabisLogo> {
  late bool _showingPay;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _showingPay = widget.showingPay ?? true;
    if (widget.showingPay == null) {
      _timer = Timer.periodic(const Duration(seconds: 3), (_) {
        if (mounted) {
          setState(() {
            _showingPay = !_showingPay;
          });
        }
      });
    }
  }

  @override
  void didUpdateWidget(covariant GabisLogo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showingPay != null) {
      _showingPay = widget.showingPay!;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectivePay = widget.showingPay ?? _showingPay;
    final primaryColor = widget.isWhite ? Colors.white : const Color(0xFF11163F);
    final accentColor = widget.isWhite ? const Color(0xFF93C5FD) : (effectivePay ? const Color(0xFF5535E8) : const Color(0xFF292083));

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          'gabis',
          style: TextStyle(
            fontSize: widget.size,
            height: 0.95,
            fontWeight: FontWeight.w800,
            letterSpacing: -widget.size * 0.05,
            color: primaryColor,
          ),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.15),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: Text(
            effectivePay ? 'Pay' : 'm',
            key: ValueKey<bool>(effectivePay),
            style: TextStyle(
              fontSize: widget.size,
              height: 0.95,
              fontWeight: FontWeight.w800,
              letterSpacing: -widget.size * 0.05,
              color: accentColor,
            ),
          ),
        ),
      ],
    );
  }
}

class GabismWordmark extends StatelessWidget {
  final double height;
  final bool isWhite;
  const GabismWordmark({super.key, this.height = 32, this.isWhite = false});

  @override
  Widget build(BuildContext context) {
    return GabisLogo(size: height, isWhite: isWhite);
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
