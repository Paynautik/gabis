filepath = "lib/features/cards/cards_screen.dart"
with open(filepath, 'r') as f:
    content = f.read()

content = content.replace("    );\n  }\n)));\n\n}", "    ))));\n  }\n\n}")

with open(filepath, 'w') as f:
    f.write(content)
