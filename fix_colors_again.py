import re

filepath = "lib/features/home/home_screen.dart"
with open(filepath, 'r') as f:
    content = f.read()

content = content.replace("subTextColor", "context.colors.inkSoft")
content = content.replace("textColor", "context.colors.ink")

# But wait, now _DonutChartPainter has:
# final Color context.colors.ink;
# final Color context.colors.inkSoft;
# _DonutChartPainter({required this.context.colors.ink, ...})
# I need to fix that manually using Regex.

painter_pattern = r"class _DonutChartPainter extends CustomPainter \{\n  final Color context\.colors\.ink;\n  final Color context\.colors\.inkSoft;\n  final Color bluePrimary;\n\n  _DonutChartPainter\(\{required this\.context\.colors\.ink, required this\.context\.colors\.inkSoft, required this\.bluePrimary\}\);\n\n  @override\n  void paint\(Canvas canvas, Size size\) \{"
new_painter = """class _DonutChartPainter extends CustomPainter {
  final Color textColor;
  final Color subTextColor;
  final Color bluePrimary;

  _DonutChartPainter({required this.textColor, required this.subTextColor, required this.bluePrimary});

  @override
  void paint(Canvas canvas, Size size) {"""
content = re.sub(painter_pattern, new_painter, content)

# Now fix the variables inside paint method
# Find paint method of _DonutChartPainter
paint_pattern = r"(void paint\(Canvas canvas, Size size\) \{.*?)(\}\n\nclass _SvgTrendLinePainter)"
match = re.search(paint_pattern, content, flags=re.DOTALL)
if match:
    paint_code = match.group(1)
    paint_code = paint_code.replace("context.colors.inkSoft", "subTextColor")
    paint_code = paint_code.replace("context.colors.ink", "textColor")
    content = content[:match.start(1)] + paint_code + content[match.end(1):]
    
# Fix the constructor call: _DonutChartPainter(textColor: context.colors.ink...) was turned into context.colors.ink: context.colors.ink
content = content.replace("_DonutChartPainter(context.colors.ink: context.colors.ink, context.colors.inkSoft: context.colors.inkSoft, bluePrimary: context.colors.bluePrimary)", "_DonutChartPainter(textColor: context.colors.ink, subTextColor: context.colors.inkSoft, bluePrimary: context.colors.bluePrimary)")

with open(filepath, 'w') as f:
    f.write(content)
