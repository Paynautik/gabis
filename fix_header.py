import re

filepath = "lib/features/home/home_screen.dart"
with open(filepath, 'r') as f:
    content = f.read()

# Fix Support Icon
content = content.replace("Icons.support_agent_rounded", "Icons.headset_mic_rounded")

# Fix Notification Badge positioning
content = content.replace("                    right: 8,\n                    top: 8,", "                    right: 6,\n                    top: 6,")

with open(filepath, 'w') as f:
    f.write(content)
