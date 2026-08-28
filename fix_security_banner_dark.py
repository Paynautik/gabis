import re

filepath = "lib/features/home/home_screen.dart"
with open(filepath, 'r') as f:
    content = f.read()

# Change the background of the security banner to a sleek dark color
content = content.replace("color: context.colors.bgSoft,\n        borderRadius: BorderRadius.circular(22),\n        border: Border.all(color: const Color(0xFF1E283F)),", "color: const Color(0xFF0F172A),\n        borderRadius: BorderRadius.circular(22),\n        border: Border.all(color: const Color(0xFF1E283F)),")

# Change the close icon color to be visible on dark
content = content.replace("icon: Icon(Icons.close_rounded, color: context.colors.inkSoft, size: 18),", "icon: Icon(Icons.close_rounded, color: const Color(0xFF94A3B8), size: 18),")

# Change the text color of the description to be visible on dark
content = content.replace("style: TextStyle(color: context.colors.inkSoft, fontSize: 11.5, fontWeight: FontWeight.w600),", "style: TextStyle(color: const Color(0xFF94A3B8), fontSize: 11.5, fontWeight: FontWeight.w600),")

with open(filepath, 'w') as f:
    f.write(content)
