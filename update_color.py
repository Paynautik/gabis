import re

filepath = "lib/core/theme/app_theme.dart"
with open(filepath, 'r') as f:
    content = f.read()

# Change bluePrimary to the OPay Fintech Green
content = content.replace("Color(0xFF1858F2); // Royal Electric Blue", "Color(0xFF00B876); // Fintech Green")
# Update the blueGradient to a green gradient if possible
content = content.replace("Color(0xFF3395FF)", "Color(0xFF10B981)")
content = content.replace("Color(0xFF1858F2)", "Color(0xFF00B876)")

with open(filepath, 'w') as f:
    f.write(content)
