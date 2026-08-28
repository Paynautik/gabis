import re

filepath = "lib/features/home/home_screen.dart"
with open(filepath, 'r') as f:
    content = f.read()

content = content.replace("subTextColor", "context.colors.inkSoft")
content = content.replace("textColor", "context.colors.ink")
content = content.replace("paint.color = bluePrimary;", "paint.color = context.colors.bluePrimary;")

painter_pattern = r"class _DonutChartPainter extends CustomPainter \{.*?\n\n  @override\n  void paint\(Canvas canvas, Size size\) \{"
new_painter = """class _DonutChartPainter extends CustomPainter {
  final BuildContext context;
  _DonutChartPainter(this.context);

  @override
  void paint(Canvas canvas, Size size) {"""

content = re.sub(painter_pattern, new_painter, content, flags=re.DOTALL)

# Update constructor call
content = content.replace("_DonutChartPainter(context.colors.ink: context.colors.ink, context.colors.inkSoft: context.colors.inkSoft, bluePrimary: context.colors.bluePrimary)", "_DonutChartPainter(context)")
content = content.replace("_DonutChartPainter(context.colors.ink: context.colors.ink, context.colors.inkSoft: context.colors.inkSoft, context.colors.bluePrimary: context.colors.bluePrimary)", "_DonutChartPainter(context)")
content = content.replace("_DonutChartPainter()", "_DonutChartPainter(context)")

# Since I added BuildContext, we don't need to pass colors manually.
# But wait, there might be other places where _DonutChartPainter is called.
content = re.sub(r'_DonutChartPainter\([^)]*\)', '_DonutChartPainter(context)', content)

# Remove const from text spans that use context.colors.ink
content = content.replace("const TextSpan(\n        text: '₦320,000',\n        style: TextStyle(color: context.colors.ink", "TextSpan(\n        text: '₦320,000',\n        style: TextStyle(color: context.colors.ink")

with open(filepath, 'w') as f:
    f.write(content)
