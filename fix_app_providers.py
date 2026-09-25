with open('lib/shared/providers/app_providers.dart', 'r') as f:
    text = f.read()

text = text.replace("static const copilot = 9;", "static const copilot = 9;\n  static const community = 10;")

with open('lib/shared/providers/app_providers.dart', 'w') as f:
    f.write(text)

