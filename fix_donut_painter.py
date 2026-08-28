import re

filepath = "lib/features/home/home_screen.dart"
with open(filepath, 'r') as f:
    content = f.read()

pattern = r"class _DonutChartPainter extends CustomPainter \{.*?\n\}"
replacement = """class _DonutChartPainter extends CustomPainter {
  final Color centerColor;
  final Color textColor;
  final Color subTextColor;
  
  _DonutChartPainter({required this.centerColor, required this.textColor, required this.subTextColor});

  @override
  void paint(Canvas canvas, Size size) {
    import_math();
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
"""

with open("fix_donut_painter_temp.dart", "w") as f:
    f.write(content)
