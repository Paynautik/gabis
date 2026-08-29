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
    this.size = 36,
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
    final primaryColor = widget.isWhite ? Colors.white : const Color(0xFF1E0E62);
    final accentColor = widget.isWhite ? const Color(0xFF93C5FD) : const Color(0xFF5535E8);

    final s = widget.size;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // ── Custom 'g' ──────────────────────────────────────────
        _GeometricLetterG(size: s, color: primaryColor),
        SizedBox(width: s * 0.08),

        // ── Custom 'a' ──────────────────────────────────────────
        _GeometricLetterA(size: s, color: primaryColor),
        SizedBox(width: s * 0.08),

        // ── Custom 'b' (Defining Feature: solid circular bowl) ──
        _GeometricLetterB(size: s, color: primaryColor),
        SizedBox(width: s * 0.08),

        // ── Custom 'i' (Defining Feature: tilted oval dot) ──────
        _GeometricLetterI(size: s, color: primaryColor),
        SizedBox(width: s * 0.08),

        // ── Custom 's' ──────────────────────────────────────────
        _GeometricLetterS(size: s, color: primaryColor),
        SizedBox(width: s * 0.08),

        // ── Animated Suffix ('Pay' ↔ 'm') ───────────────────────
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
          child: effectivePay
              ? _GeometricSuffixPay(
                  key: const ValueKey('pay'),
                  size: s,
                  color: accentColor,
                )
              : _GeometricLetterM(
                  key: const ValueKey('m'),
                  size: s,
                  color: primaryColor,
                ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CUSTOM GEOMETRIC LETTER PAINTERS
// ─────────────────────────────────────────────────────────────────────────────

// ── 'g' ──
class _GeometricLetterG extends StatelessWidget {
  final double size;
  final Color color;
  const _GeometricLetterG({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    final w = size * 0.65;
    final h = size;
    return CustomPaint(
      size: Size(w, h),
      painter: _LetterGPainter(color: color),
    );
  }
}

class _LetterGPainter extends CustomPainter {
  final Color color;
  _LetterGPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.height * 0.09
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;
    final bowlTop = h * 0.32;
    final baseline = h * 0.76;
    final bowlHeight = baseline - bowlTop;
    final bowlWidth = w * 0.88;

    // Upper circular bowl
    canvas.drawOval(
      Rect.fromLTWH(0, bowlTop, bowlWidth, bowlHeight),
      paint,
    );

    // Right stem extending down and curving into hook descender
    final path = Path();
    path.moveTo(bowlWidth, bowlTop + bowlHeight * 0.2);
    path.lineTo(bowlWidth, baseline + h * 0.10);
    path.quadraticBezierTo(
      bowlWidth,
      baseline + h * 0.22,
      bowlWidth * 0.45,
      baseline + h * 0.22,
    );
    path.quadraticBezierTo(
      0,
      baseline + h * 0.22,
      0,
      baseline + h * 0.12,
    );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _LetterGPainter oldDelegate) => oldDelegate.color != color;
}

// ── 'a' ──
class _GeometricLetterA extends StatelessWidget {
  final double size;
  final Color color;
  const _GeometricLetterA({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    final w = size * 0.62;
    final h = size;
    return CustomPaint(
      size: Size(w, h),
      painter: _LetterAPainter(color: color),
    );
  }
}

class _LetterAPainter extends CustomPainter {
  final Color color;
  _LetterAPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final sw = size.height * 0.09;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = sw
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;
    final top = h * 0.32;
    final baseline = h * 0.76;
    final bowlHeight = baseline - top;
    final bowlWidth = w * 0.86;

    // Circular bowl
    canvas.drawOval(
      Rect.fromLTWH(0, top, bowlWidth, bowlHeight),
      paint,
    );

    // Right tangent stem
    final path = Path();
    path.moveTo(bowlWidth, top + bowlHeight * 0.1);
    path.lineTo(bowlWidth, baseline);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _LetterAPainter oldDelegate) => oldDelegate.color != color;
}

// ── 'b' (Custom signature letter: tall stem + solid circular bowl) ──
class _GeometricLetterB extends StatelessWidget {
  final double size;
  final Color color;
  const _GeometricLetterB({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    final w = size * 0.72;
    final h = size;
    return CustomPaint(
      size: Size(w, h),
      painter: _LetterBPainter(color: color),
    );
  }
}

class _LetterBPainter extends CustomPainter {
  final Color color;
  _LetterBPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final sw = size.height * 0.09;
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = sw
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final h = size.height;
    final ascenderTop = h * 0.10;
    final bowlTop = h * 0.32;
    final baseline = h * 0.76;
    final bowlHeight = baseline - bowlTop;
    final bowlRadius = bowlHeight * 0.50;

    // Tall vertical stem
    canvas.drawLine(
      Offset(sw * 0.5, ascenderTop),
      Offset(sw * 0.5, baseline),
      strokePaint,
    );

    // Bold solid circular bowl
    canvas.drawCircle(
      Offset(sw * 0.5 + bowlRadius, bowlTop + bowlRadius),
      bowlRadius,
      fillPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _LetterBPainter oldDelegate) => oldDelegate.color != color;
}

// ── 'i' (Custom signature letter: stem + tilted oval dot) ──
class _GeometricLetterI extends StatelessWidget {
  final double size;
  final Color color;
  const _GeometricLetterI({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    final w = size * 0.28;
    final h = size;
    return CustomPaint(
      size: Size(w, h),
      painter: _LetterIPainter(color: color),
    );
  }
}

class _LetterIPainter extends CustomPainter {
  final Color color;
  _LetterIPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final sw = size.height * 0.09;
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = sw
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;
    final top = h * 0.32;
    final baseline = h * 0.76;
    final centerX = w * 0.50;

    // Vertical stem
    canvas.drawLine(
      Offset(centerX, top),
      Offset(centerX, baseline),
      strokePaint,
    );

    // Tilted oval dot (tilted ~25 degrees)
    canvas.save();
    final dotCenter = Offset(centerX, h * 0.16);
    canvas.translate(dotCenter.dx, dotCenter.dy);
    canvas.rotate(-math.pi * 0.18);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset.zero,
        width: sw * 1.35,
        height: sw * 1.95,
      ),
      fillPaint,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _LetterIPainter oldDelegate) => oldDelegate.color != color;
}

// ── 's' ──
class _GeometricLetterS extends StatelessWidget {
  final double size;
  final Color color;
  const _GeometricLetterS({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    final w = size * 0.55;
    final h = size;
    return CustomPaint(
      size: Size(w, h),
      painter: _LetterSPainter(color: color),
    );
  }
}

class _LetterSPainter extends CustomPainter {
  final Color color;
  _LetterSPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final sw = size.height * 0.09;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = sw
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;
    final top = h * 0.32;
    final baseline = h * 0.76;
    final mid = (top + baseline) * 0.5;

    final path = Path();
    path.moveTo(w * 0.88, top + (mid - top) * 0.35);
    path.quadraticBezierTo(w * 0.88, top, w * 0.50, top);
    path.quadraticBezierTo(w * 0.12, top, w * 0.12, top + (mid - top) * 0.65);
    path.quadraticBezierTo(w * 0.12, mid, w * 0.50, mid);
    path.quadraticBezierTo(w * 0.88, mid, w * 0.88, mid + (baseline - mid) * 0.45);
    path.quadraticBezierTo(w * 0.88, baseline, w * 0.50, baseline);
    path.quadraticBezierTo(w * 0.12, baseline, w * 0.12, baseline - (baseline - mid) * 0.35);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _LetterSPainter oldDelegate) => oldDelegate.color != color;
}

// ── 'm' (Geometric wide lowercase) ──
class _GeometricLetterM extends StatelessWidget {
  final double size;
  final Color color;
  const _GeometricLetterM({super.key, required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    final w = size * 0.95;
    final h = size;
    return CustomPaint(
      size: Size(w, h),
      painter: _LetterMPainter(color: color),
    );
  }
}

class _LetterMPainter extends CustomPainter {
  final Color color;
  _LetterMPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final sw = size.height * 0.09;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = sw
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;
    final top = h * 0.32;
    final baseline = h * 0.76;

    final x1 = sw * 0.6;
    final x2 = w * 0.50;
    final x3 = w - sw * 0.6;

    // Stem 1
    canvas.drawLine(Offset(x1, top), Offset(x1, baseline), paint);

    // Arch 1
    final path1 = Path();
    path1.moveTo(x1, top + (baseline - top) * 0.3);
    path1.quadraticBezierTo(x1 + (x2 - x1) * 0.5, top, x2, top + (baseline - top) * 0.3);
    path1.lineTo(x2, baseline);
    canvas.drawPath(path1, paint);

    // Arch 2
    final path2 = Path();
    path2.moveTo(x2, top + (baseline - top) * 0.3);
    path2.quadraticBezierTo(x2 + (x3 - x2) * 0.5, top, x3, top + (baseline - top) * 0.3);
    path2.lineTo(x3, baseline);
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant _LetterMPainter oldDelegate) => oldDelegate.color != color;
}

// ── 'Pay' (Geometric matching style) ──
class _GeometricSuffixPay extends StatelessWidget {
  final double size;
  final Color color;
  const _GeometricSuffixPay({super.key, required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _GeometricLetterP(size: size, color: color),
        SizedBox(width: size * 0.06),
        _GeometricLetterA(size: size, color: color),
        SizedBox(width: size * 0.06),
        _GeometricLetterY(size: size, color: color),
      ],
    );
  }
}

class _GeometricLetterP extends StatelessWidget {
  final double size;
  final Color color;
  const _GeometricLetterP({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    final w = size * 0.64;
    final h = size;
    return CustomPaint(
      size: Size(w, h),
      painter: _LetterPPainter(color: color),
    );
  }
}

class _LetterPPainter extends CustomPainter {
  final Color color;
  _LetterPPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final sw = size.height * 0.09;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = sw
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;
    final top = h * 0.12; // Cap 'P'
    final baseline = h * 0.76;
    final mid = (top + baseline) * 0.54;

    // Stem
    canvas.drawLine(Offset(sw * 0.6, top), Offset(sw * 0.6, baseline), paint);

    // Upper bowl
    final bowlPath = Path();
    bowlPath.moveTo(sw * 0.6, top);
    bowlPath.quadraticBezierTo(w * 0.95, top, w * 0.95, (top + mid) * 0.5);
    bowlPath.quadraticBezierTo(w * 0.95, mid, sw * 0.6, mid);
    canvas.drawPath(bowlPath, paint);
  }

  @override
  bool shouldRepaint(covariant _LetterPPainter oldDelegate) => oldDelegate.color != color;
}

class _GeometricLetterY extends StatelessWidget {
  final double size;
  final Color color;
  const _GeometricLetterY({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    final w = size * 0.58;
    final h = size;
    return CustomPaint(
      size: Size(w, h),
      painter: _LetterYPainter(color: color),
    );
  }
}

class _LetterYPainter extends CustomPainter {
  final Color color;
  _LetterYPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final sw = size.height * 0.09;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = sw
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;
    final top = h * 0.32;
    final baseline = h * 0.76;
    final descender = baseline + h * 0.18;

    // Left branch
    canvas.drawLine(Offset(sw * 0.6, top), Offset(w * 0.48, baseline), paint);

    // Right full diagonal descending stem
    canvas.drawLine(Offset(w - sw * 0.6, top), Offset(0, descender), paint);
  }

  @override
  bool shouldRepaint(covariant _LetterYPainter oldDelegate) => oldDelegate.color != color;
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
