filepath = "lib/features/home/home_screen.dart"
with open(filepath, 'r') as f:
    content = f.read()

# Replace the Add Money button behavior
content = content.replace("onTap: () => _showAddMoneySheet(context, ref),", "onTap: () => _showReceiveSheet(context),")
content = content.replace("onTap: () => _showAddMoneySheet(context),", "onTap: () => _showReceiveSheet(context),")

with open(filepath, 'w') as f:
    f.write(content)
