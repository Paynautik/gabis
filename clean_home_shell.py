filepath = "lib/features/home/home_shell.dart"
with open(filepath, 'r') as f:
    content = f.read()

content = content.replace("import 'sidebar_screens.dart';\nimport '../cards/cards_screen.dart';", "import 'sidebar_screens.dart';")

with open(filepath, 'w') as f:
    f.write(content)
