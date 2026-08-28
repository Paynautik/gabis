filepath = "lib/features/home/home_screen.dart"
with open(filepath, 'r') as f:
    content = f.read()

custom_widgets = """
class _CurrencyBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _CurrencyBadge(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 0.5),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.w900),
      ),
    );
  }
}

class _PayrollNodesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = const Color(0xFF10B981).withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    // Draw grid nodes
    canvas.drawLine(Offset(0, size.height * 0.3), Offset(size.width, size.height * 0.3), paint);
    canvas.drawLine(Offset(0, size.height * 0.7), Offset(size.width, size.height * 0.7), paint);
    canvas.drawLine(Offset(size.width * 0.3, 0), Offset(size.width * 0.3, size.height), paint);
    canvas.drawLine(Offset(size.width * 0.7, 0), Offset(size.width * 0.7, size.height), paint);

    canvas.drawCircle(Offset(size.width * 0.3, size.height * 0.3), 3, dotPaint);
    canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.3), 3, dotPaint);
    canvas.drawCircle(Offset(size.width * 0.3, size.height * 0.7), 3, dotPaint);
    canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.7), 3, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
"""

if "_PayrollNodesPainter" not in content:
    content += custom_widgets

with open(filepath, 'w') as f:
    f.write(content)
