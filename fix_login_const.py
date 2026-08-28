filepath = "lib/features/auth/login_screen.dart"
with open(filepath, 'r') as f:
    content = f.read()

content = content.replace("                  const Text(\n                    'Elumo',", "                  Text(\n                    'Elumo',")

with open(filepath, 'w') as f:
    f.write(content)
