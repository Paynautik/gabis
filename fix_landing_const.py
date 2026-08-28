filepath = "lib/features/landing/landing_screen.dart"
with open(filepath, 'r') as f:
    content = f.read()

content = content.replace("          const Text(\n            change,", "          Text(\n            change,")

with open(filepath, 'w') as f:
    f.write(content)
