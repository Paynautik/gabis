import re

filepath = "lib/features/home/home_screen.dart"
with open(filepath, 'r') as f:
    content = f.read()

# Replace Background Color
content = content.replace("color: const Color(0xFF00B876), // Vibrant Fintech Green", "color: context.colors.bluePrimary,")
# Replace Shadow Color
content = content.replace("color: const Color(0xFF00B876).withValues(alpha: 0.3),", "color: context.colors.bluePrimary.withValues(alpha: 0.3),")
# Replace Button Text Color
content = content.replace("const Text('+ Add Money', style: TextStyle(color: Color(0xFF00B876), fontWeight: FontWeight.w900, fontSize: 13))", "Text('+ Add Money', style: TextStyle(color: context.colors.bluePrimary, fontWeight: FontWeight.w900, fontSize: 13))")

with open(filepath, 'w') as f:
    f.write(content)
