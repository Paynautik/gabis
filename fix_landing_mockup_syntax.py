filepath = "lib/features/landing/landing_screen.dart"
with open(filepath, 'r') as f:
    content = f.read()

# 1. Replace FontWeight.w950 with FontWeight.w900
content = content.replace("FontWeight.w950", "FontWeight.w900")

# 2. Replace Colors.white64 with Colors.white70
content = content.replace("Colors.white64", "Colors.white70")

with open(filepath, 'w') as f:
    f.write(content)

print("Syntactical fixes applied to Mockups.")
