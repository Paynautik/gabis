import re
filepath = "lib/features/home/home_screen.dart"
with open(filepath, 'r') as f:
    content = f.read()
content = content.replace("painter: _DonutChartPainter(\n                    centerColor: context.colors.bgSoft,\n                  ),", "painter: _DonutChartPainter(\n                    centerColor: context.colors.bgSoft,\n                    textColor: context.colors.ink,\n                    subTextColor: context.colors.inkSoft,\n                  ),")
with open(filepath, 'w') as f:
    f.write(content)
