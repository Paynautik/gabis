import re

filepath = "lib/features/home/home_screen.dart"
with open(filepath, 'r') as f:
    content = f.read()

# Fix maxWidth undefined parameter? Let's check what it is
content = content.replace("maxWidth: 500", "minWidth: 0")

content = re.sub(r'const\s+([^)]*context\.colors[^)]*)', r'\1', content)

with open(filepath, 'w') as f:
    f.write(content)

filepath = "lib/features/home/home_shell.dart"
with open(filepath, 'r') as f:
    content = f.read()
content = re.sub(r'const\s+([^)]*context\.colors[^)]*)', r'\1', content)
with open(filepath, 'w') as f:
    f.write(content)

