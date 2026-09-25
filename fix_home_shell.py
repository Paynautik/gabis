import re

with open('lib/features/home/home_shell.dart', 'r') as f:
    text = f.read()

# Add import
if 'community_screen.dart' not in text:
    text = text.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'package:gabis/features/community/community_screen.dart';")

# Add to _screens
screens_old = """    SettingsScreen(),
    SupportScreen(),
    CopilotScreen(),
  ];"""
screens_new = """    SettingsScreen(),
    SupportScreen(),
    CopilotScreen(),
    CommunityScreen(),
  ];"""
text = text.replace(screens_old, screens_new)

# Fix the sidebar item I added earlier
text = text.replace("_buildSidebarItem(3, Icons.diversity_3_rounded, 'Community & Trust'),", "_buildSidebarItem(10, Icons.diversity_3_rounded, 'Community & Trust'),")

with open('lib/features/home/home_shell.dart', 'w') as f:
    f.write(text)

