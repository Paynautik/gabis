filepath = "lib/features/home/home_shell.dart"
with open(filepath, 'r') as f:
    content = f.read()

old_string = """                    ),
                  ),
                  
                  // User Details Box (Collapsible)"""

new_string = """                    ),
                  ),
                  const SizedBox(height: 16),
                  // User Details Box (Collapsible)"""

content = content.replace(old_string, new_string)

with open(filepath, 'w') as f:
    f.write(content)
