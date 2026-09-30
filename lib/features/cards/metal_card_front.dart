import 'dart:math';
import 'package:flutter/material.dart';

/// Front of a gabis card, drawn to look like a physical metal card: brushed
/// grain, bevelled edge, engraved lettering, an EMV chip, a soft specular
/// highlight and a tilt that follows the pointer or finger.
class MetalCardFront extends StatelessWidget {
  const MetalCardFront({
    super.key,
    required this.last4,
    required this.holder,
    required this.isVisa,
    required this.frozen,
    required this.skin,
  });

  final String last4;
  final String holder;
  final bool isVisa;
  final bool frozen;

  /// One entry of the skins list on the cards screen: `gradient`, `textColor`,
  /// `accentColor`, `isDark`.
  final Map<String, dynamic> skin;

  static const _champagne = Color(0xFFC9B79C);
  static const _radius = 24.0;

  @override
  Widget build(BuildContext context) {
    final isDark = skin['isDark'] == true;
    final textColor = skin['textColor'] as Color;
    final accent = skin['accentColor'] as Color;
    final engrave = isDark ? _champagne : textColor;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: AspectRatio(
          aspectRatio: 1.586,
          child: _Tilt(
            builder: (context, light) => Container(
              decoration: BoxDecoration(
                gradient: skin['gradient'] as Gradient,
                borderRadius: BorderRadius.circular(_radius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 32,
                    spreadRadius: -4,
                    offset: Offset(-light.dx * 10, 18 - light.dy * 6),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(_radius),
                child: Stack(
                  children: [
                    // Brushed-metal grain
                    Positioned.fill(
                      child: RepaintBoundary(
                        child: CustomPaint(painter: _GrainPainter(isDark)),
                      ),
                    ),
                    // Broad sheen band that slides with the light
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment(-1.4 + light.dx, -1),
                            end: Alignment(0.2 + light.dx, 1),
                            colors: [
                              Colors.white.withValues(alpha: isDark ? 0.10 : 0.30),
                              Colors.white.withValues(alpha: 0.0),
                              Colors.black.withValues(alpha: isDark ? 0.18 : 0.06),
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                    ),
                    // Specular highlight under the pointer
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: Alignment(light.dx, light.dy),
                            radius: 0.85,
                            colors: [
                              Colors.white.withValues(alpha: isDark ? 0.16 : 0.34),
                              Colors.white.withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Bevelled edge: lit top-left, shaded bottom-right
                    Positioned.fill(
                      child: CustomPaint(painter: _BevelPainter(_radius)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: frozen
                          ? _frozen()
                          : _face(engrave, textColor, accent, isDark),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _frozen() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.lightBlueAccent.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(_radius - 8),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.ac_unit_rounded, color: Colors.white, size: 48),
            SizedBox(height: 8),
            Text(
              'FROZEN',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Text that looks pressed into the metal: a dark edge above-left and a
  /// faint highlight below-right.
  List<Shadow> _engraved(bool isDark) => [
        Shadow(
          color: Colors.black.withValues(alpha: isDark ? 0.65 : 0.25),
          offset: const Offset(-0.6, -0.6),
        ),
        Shadow(
          color: Colors.white.withValues(alpha: isDark ? 0.16 : 0.5),
          offset: const Offset(0.8, 0.8),
        ),
      ];

  Widget _wordmark(Color color, double height, {double alpha = 1}) {
    return ColorFiltered(
      colorFilter: ColorFilter.mode(color.withValues(alpha: alpha), BlendMode.srcIn),
      // The PNG has transparent padding; crop to the visible lettering so the
      // mark lines up with the card's margins.
      child: Align(
        widthFactor: 677 / 1216,
        heightFactor: 268 / 312,
        child: Image.asset(
          'assets/gabis_logo.png',
          height: height,
          fit: BoxFit.contain,
          semanticLabel: 'gabis',
        ),
      ),
    );
  }

  Widget _face(Color engrave, Color textColor, Color accent, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              width: 46,
              height: 34,
              child: CustomPaint(painter: _ChipPainter()),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Icon(Icons.contactless_rounded, size: 22, color: engrave.withValues(alpha: 0.85)),
            ),
          ],
        ),
        Text(
          '••••  ••••  ••••  $last4',
          style: TextStyle(
            color: isDark ? const Color(0xFFDCD3C4) : textColor,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 2.6,
            fontFeatures: const [FontFeature.tabularFigures()],
            shadows: _engraved(isDark),
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Engraved wordmark: a dark copy just above-left gives the cut edge.
                Stack(
                  children: [
                    Transform.translate(
                      offset: const Offset(-0.8, -0.8),
                      child: _wordmark(Colors.black, 40, alpha: isDark ? 0.6 : 0.2),
                    ),
                    _wordmark(engrave, 40, alpha: 0.92),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  holder.toUpperCase(),
                  style: TextStyle(
                    color: engrave.withValues(alpha: 0.8),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.4,
                    shadows: _engraved(isDark),
                  ),
                ),
              ],
            ),
            Text(
              isVisa ? 'VISA' : 'MC',
              style: TextStyle(
                color: isDark ? const Color(0xFFE9E2D6) : textColor,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
                letterSpacing: -0.5,
                shadows: _engraved(isDark),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Tilts its child in 3D toward the pointer / finger and reports where the
/// "light" sits, in -1..1 on both axes.
class _Tilt extends StatefulWidget {
  const _Tilt({required this.builder});
  final Widget Function(BuildContext context, Offset light) builder;

  @override
  State<_Tilt> createState() => _TiltState();
}

class _TiltState extends State<_Tilt> {
  static const _rest = Offset(-0.45, -0.55);
  Offset _p = _rest;

  void _move(Offset local, Size size) {
    if (size.isEmpty) return;
    setState(() {
      _p = Offset(
        ((local.dx / size.width) * 2 - 1).clamp(-1.0, 1.0),
        ((local.dy / size.height) * 2 - 1).clamp(-1.0, 1.0),
      );
    });
  }

  void _reset() => setState(() => _p = _rest);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final size = box.biggest;
        return MouseRegion(
          onHover: (e) => _move(e.localPosition, size),
          onExit: (_) => _reset(),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanUpdate: (d) => _move(d.localPosition, size),
            onPanEnd: (_) => _reset(),
            child: TweenAnimationBuilder<Offset>(
              tween: Tween<Offset>(end: _p),
              duration: const Duration(milliseconds: 140),
              curve: Curves.easeOut,
              builder: (context, p, _) => Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.0011)
                  ..rotateX(-(p.dy - _rest.dy) * 0.16)
                  ..rotateY((p.dx - _rest.dx) * 0.20),
                child: widget.builder(context, p),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Fine horizontal brushing: many faint light and dark hairlines.
class _GrainPainter extends CustomPainter {
  _GrainPainter(this.isDark);
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = Random(7);
    final paint = Paint()..strokeWidth = 0.7;
    for (double y = 0; y < size.height; y += 1.1) {
      final light = rnd.nextBool();
      final a = rnd.nextDouble() * (isDark ? 0.07 : 0.06);
      paint.color = (light ? Colors.white : Colors.black).withValues(alpha: a);
      final x0 = rnd.nextDouble() * size.width * 0.15;
      final x1 = size.width - rnd.nextDouble() * size.width * 0.15;
      canvas.drawLine(Offset(x0, y), Offset(x1, y), paint);
    }
    // Darken the corners a little, like the falloff on a real photo.
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = RadialGradient(
          center: Alignment.center,
          radius: 1.15,
          colors: [Colors.transparent, Colors.black.withValues(alpha: isDark ? 0.28 : 0.10)],
        ).createShader(Offset.zero & size),
    );
  }

  @override
  bool shouldRepaint(covariant _GrainPainter old) => old.isDark != isDark;
}

class _BevelPainter extends CustomPainter {
  _BevelPainter(this.radius);
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      (Offset.zero & size).deflate(0.75),
      Radius.circular(radius),
    );
    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.55),
            Colors.white.withValues(alpha: 0.05),
            Colors.black.withValues(alpha: 0.35),
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(Offset.zero & size),
    );
  }

  @override
  bool shouldRepaint(covariant _BevelPainter old) => old.radius != radius;
}

/// Champagne EMV chip with contact pads.
class _ChipPainter extends CustomPainter {
  const _ChipPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    final body = RRect.fromRectAndRadius(bounds, const Radius.circular(7));
    canvas.drawRRect(
      body,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEBDDBF), Color(0xFFB39F7A), Color(0xFFD8C7A2)],
          stops: [0.0, 0.55, 1.0],
        ).createShader(bounds),
    );
    final line = Paint()
      ..color = const Color(0xFF5E5039).withValues(alpha: 0.6)
      ..strokeWidth = 0.9
      ..style = PaintingStyle.stroke;
    final w = size.width, h = size.height;
    canvas.drawLine(Offset(w * 0.34, 0), Offset(w * 0.34, h), line);
    canvas.drawLine(Offset(w * 0.66, 0), Offset(w * 0.66, h), line);
    canvas.drawLine(Offset(0, h * 0.34), Offset(w * 0.34, h * 0.34), line);
    canvas.drawLine(Offset(0, h * 0.66), Offset(w * 0.34, h * 0.66), line);
    canvas.drawLine(Offset(w * 0.66, h * 0.34), Offset(w, h * 0.34), line);
    canvas.drawLine(Offset(w * 0.66, h * 0.66), Offset(w, h * 0.66), line);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.34, h * 0.24, w * 0.32, h * 0.52),
        const Radius.circular(4),
      ),
      line,
    );
    canvas.drawRRect(body, line);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
