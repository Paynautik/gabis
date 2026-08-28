filepath = "lib/features/landing/landing_screen.dart"
with open(filepath, 'r') as f:
    content = f.read()

# Replace FontWeight.black with FontWeight.w900
content = content.replace("FontWeight.black", "FontWeight.w900")

with open(filepath, 'w') as f:
    f.write(content)

print("FontWeight.black replaced with FontWeight.w900.")
