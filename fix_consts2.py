import re
filepath = "lib/features/home/home_screen.dart"
with open(filepath, 'r') as f:
    content = f.read()

content = content.replace("const Icon(Icons.notifications_outlined, color: context.colors.ink, size: 22)", "Icon(Icons.notifications_outlined, color: context.colors.ink, size: 22)")
content = content.replace("const Text('Accounts', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: context.colors.ink))", "Text('Accounts', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: context.colors.ink))")

with open(filepath, 'w') as f:
    f.write(content)
