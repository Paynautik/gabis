import re

filepath = "lib/features/home/home_screen.dart"
with open(filepath, 'r') as f:
    content = f.read()
    
# Fix context inside _DonutChartPainter
content = content.replace("style: TextStyle(color: context.colors.inkSoft,", "style: TextStyle(color: subTextColor,")
content = content.replace("style: TextStyle(color: context.colors.ink,", "style: TextStyle(color: textColor,")

with open(filepath, 'w') as f:
    f.write(content)

filepath = "lib/features/home/home_shell.dart"
with open(filepath, 'r') as f:
    content = f.read()

content = content.replace("const Expanded(\n                          child: Column(", "Expanded(\n                          child: Column(")

with open(filepath, 'w') as f:
    f.write(content)
