import re

filepath = "lib/features/home/home_screen.dart"
with open(filepath, 'r') as f:
    content = f.read()

content = content.replace("maxWidth: 300,", "constraints: const BoxConstraints(maxWidth: 300),")

painter_pattern = r"class _DonutChartPainter extends CustomPainter \{\n  @override\n  void paint\(Canvas canvas, Size size\) \{"
new_painter = """class _DonutChartPainter extends CustomPainter {
  final Color textColor;
  final Color subTextColor;
  final Color bluePrimary;

  _DonutChartPainter({required this.textColor, required this.subTextColor, required this.bluePrimary});

  @override
  void paint(Canvas canvas, Size size) {"""

content = re.sub(painter_pattern, new_painter, content)

content = content.replace("paint.color = context.colors.bluePrimary;", "paint.color = bluePrimary;")
content = content.replace("color: context.colors.inkSoft", "color: subTextColor")
content = content.replace("style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900),", "style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.w900),")
content = content.replace("_DonutChartPainter(),", "_DonutChartPainter(textColor: context.colors.ink, subTextColor: context.colors.inkSoft, bluePrimary: context.colors.bluePrimary),")

with open(filepath, 'w') as f:
    f.write(content)

filepath = "lib/features/home/home_shell.dart"
with open(filepath, 'r') as f:
    content = f.read()

content = content.replace("const Text(\n                                'Premium User',", "Text(\n                                'Premium User',")
content = content.replace("const Icon(Icons.keyboard_arrow_down_rounded", "Icon(Icons.keyboard_arrow_down_rounded")

with open(filepath, 'w') as f:
    f.write(content)
