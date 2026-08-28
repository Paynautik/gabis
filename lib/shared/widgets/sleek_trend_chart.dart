import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class SleekTrendChart extends StatefulWidget {
  const SleekTrendChart({super.key});

  @override
  State<SleekTrendChart> createState() => _SleekTrendChartState();
}

class _SleekTrendChartState extends State<SleekTrendChart> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 110,
          width: double.infinity,
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return CustomPaint(
                painter: _TrendChartPainter(
                  progress: _animation.value,
                  lineColor: context.colors.bluePrimary,
                  gridColor: context.colors.border,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        // Day labels at the bottom
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _DayLabel('MON'),
              _DayLabel('TUE'),
              _DayLabel('WED'),
              _DayLabel('THU'),
              _DayLabel('FRI'),
              _DayLabel('SAT'),
              _DayLabel('SUN'),
            ],
          ),
        ),
      ],
    );
  }
}

class _DayLabel extends StatelessWidget {
  final String text;
  const _DayLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: context.colors.inkSoft,
        fontSize: 9.5,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _TrendChartPainter extends CustomPainter {
  final double progress;
  final Color lineColor;
  final Color gridColor;

  _TrendChartPainter({required this.progress, required this.lineColor, required this.gridColor});

  @override
  void paint(Canvas canvas, Size size) {
    // Draw background grid lines (horizontal)
    final gridPaint = Paint()
      ..color = gridColor.withValues(alpha: 0.4)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    
    const gridLines = 3;
    final gridSpacing = size.height / (gridLines + 1);
    for (int i = 1; i <= gridLines; i++) {
      final y = i * gridSpacing;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final values = [0.15, 0.25, 0.22, 0.45, 0.40, 0.65, 0.60, 0.88]; // normalized coordinates
    if (values.isEmpty) return;

    final paintLine = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final fillPath = Path();

    final stepX = size.width / (values.length - 1);
    
    // Calculate control points for smooth Bezier curves
    double getX(int index) => index * stepX;
    double getY(int index) => size.height - (values[index] * size.height * 0.75 + size.height * 0.1);

    path.moveTo(getX(0), getY(0));
    fillPath.moveTo(0, size.height);
    fillPath.lineTo(getX(0), getY(0));

    for (int i = 0; i < values.length - 1; i++) {
      final x1 = getX(i);
      final y1 = getY(i);
      final x2 = getX(i + 1);
      final y2 = getY(i + 1);

      // Smooth cubic curve control points
      final controlX1 = x1 + (x2 - x1) / 2.0;
      final controlY1 = y1;
      final controlX2 = x1 + (x2 - x1) / 2.0;
      final controlY2 = y2;

      path.cubicTo(controlX1, controlY1, controlX2, controlY2, x2, y2);
      fillPath.cubicTo(controlX1, controlY1, controlX2, controlY2, x2, y2);
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    // Clip the path based on progress animation from left to right
    final clipRect = Rect.fromLTWH(0, 0, size.width * progress, size.height);
    canvas.save();
    canvas.clipRect(clipRect);

    // Draw area gradient fill
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        lineColor.withValues(alpha: 0.20),
        lineColor.withValues(alpha: 0.0),
      ],
    );
    final fillPaint = Paint()
      ..shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;
    
    canvas.drawPath(fillPath, fillPaint);

    // Draw main line
    canvas.drawPath(path, paintLine);

    // Draw active end dot with a subtle indicator line down to axis
    if (progress > 0.0) {
      final activeIndex = ((values.length - 1) * progress).floor();
      final dotX = size.width * progress;
      
      // Interpolate Y value at current X position
      final t = (progress * (values.length - 1)) - activeIndex;
      final currentY = activeIndex < values.length - 1
          ? getY(activeIndex) * (1 - t) + getY(activeIndex + 1) * t
          : getY(values.length - 1);

      // Draw dashed vertical indicator line to axis
      final indicatorPaint = Paint()
        ..color = lineColor.withValues(alpha: 0.15)
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke;
      canvas.drawLine(Offset(dotX, currentY), Offset(dotX, size.height), indicatorPaint);

      final dotPaint = Paint()
        ..color = lineColor
        ..style = PaintingStyle.fill;
      
      final glowPaint = Paint()
        ..color = lineColor.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(dotX, currentY), 10.0 * progress, glowPaint);
      canvas.drawCircle(Offset(dotX, currentY), 4.5 * progress, dotPaint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _TrendChartPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.lineColor != lineColor || oldDelegate.gridColor != gridColor;
  }
}
