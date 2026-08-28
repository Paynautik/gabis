import re

filepath = "lib/features/home/home_screen.dart"
with open(filepath, 'r') as f:
    content = f.read()

# Replace in _buildSecurityBanner
# The shield background
content = content.replace("decoration: BoxDecoration(color: context.colors.blueHighlight, borderRadius: BorderRadius.circular(16)),", "decoration: BoxDecoration(color: const Color(0xFFEDF4FF), borderRadius: BorderRadius.circular(16)),")

# The shield icon
content = content.replace("child: Icon(Icons.security_rounded, color: context.colors.bluePrimary, size: 24),", "child: Icon(Icons.security_rounded, color: const Color(0xFF1858F2), size: 24),")

# The Learn more text
content = content.replace("Text('Learn more', style: TextStyle(color: context.colors.bluePrimary,", "Text('Learn more', style: TextStyle(color: const Color(0xFF1858F2),")

# The Learn more arrow
content = content.replace("Icon(Icons.arrow_outward_rounded, color: context.colors.bluePrimary, size: 14)", "Icon(Icons.arrow_outward_rounded, color: const Color(0xFF1858F2), size: 14)")

with open(filepath, 'w') as f:
    f.write(content)
