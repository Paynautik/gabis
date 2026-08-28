import re

filepath = "lib/features/home/home_screen.dart"
with open(filepath, 'r') as f:
    content = f.read()

# Extract the method from the bottom of the file
method_pattern = r"  void _showBusinessInsights\(BuildContext context\) \{.*?\n  \}\n\}"
match = re.search(method_pattern, content, flags=re.DOTALL)

if match:
    method_code = match.group(0)
    # Remove it from the bottom
    content = content.replace(method_code, "\n}")
    
    # Insert it right before the closing brace of _HomeScreenState.
    # Actually, let's find the `_showAddMoneySheet` method and place it after that.
    add_money_pattern = r"  void _showAddMoneySheet\(BuildContext context, WidgetRef ref\) \{.*?\n  \}"
    add_money_match = re.search(add_money_pattern, content, flags=re.DOTALL)
    
    if add_money_match:
        full_add_money = add_money_match.group(0)
        # We need to extract just the method code (remove the trailing brace that matched)
        method_code = method_code.replace("}\n}", "}") 
        new_combined = full_add_money + "\n\n" + method_code
        content = content.replace(full_add_money, new_combined)

    with open(filepath, 'w') as f:
        f.write(content)
    print("Method moved successfully")
else:
    print("Could not find method at the bottom")
