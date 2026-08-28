import re

filepath = "lib/features/home/home_shell.dart"
with open(filepath, 'r') as f:
    content = f.read()

pattern = r"onTap: \(\) => setState\(\(\) => _index = index\),"
replacement = """onTap: () {
        if (index < _screens.length) {
          setState(() => _index = index);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${label} coming soon!')));
        }
      },"""

content = content.replace(pattern, replacement)

with open(filepath, 'w') as f:
    f.write(content)
