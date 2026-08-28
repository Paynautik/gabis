import re

filepath = "lib/features/home/home_screen.dart"

with open(filepath, 'r') as f:
    content = f.read()

content = content.replace("Icons.arrow_left_right_rounded", "Icons.swap_horiz_rounded")
content = content.replace("FontWeight.w950", "FontWeight.w900")
content = content.replace("const BoxConstraints(maxWidth: 300)", "BoxConstraints(maxWidth: 300)")

with open(filepath, 'w') as f:
    f.write(content)
