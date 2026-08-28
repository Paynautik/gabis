import re

filepath = "lib/features/home/home_screen.dart"

with open(filepath, 'r') as f:
    content = f.read()

content = content.replace("                maxWidth: 300,", "                constraints: BoxConstraints(maxWidth: 300),")

with open(filepath, 'w') as f:
    f.write(content)
