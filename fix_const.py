filepath = "lib/features/home/sidebar_screens.dart"
with open(filepath, 'r') as f:
    content = f.read()

content = content.replace("const Icon(Icons.add_rounded, color: context.colors.ink)", "Icon(Icons.add_rounded, color: context.colors.ink)")

with open(filepath, 'w') as f:
    f.write(content)
