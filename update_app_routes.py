filepath = "lib/app/app.dart"
with open(filepath, 'r') as f:
    content = f.read()

# Add import for BillsScreen
content = "import '../features/bills/bills_screen.dart';\n" + content

# Add route
content = content.replace("'/fx': (_) => const FxScreen(),", "'/fx': (_) => const FxScreen(),\n        '/bills': (_) => const BillsScreen(),")

with open(filepath, 'w') as f:
    f.write(content)
