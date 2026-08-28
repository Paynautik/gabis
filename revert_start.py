import re
filepath = "lib/features/home/home_screen.dart"
with open(filepath, 'r') as f:
    content = f.read()

new_start = """      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,"""
old_start = """      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,"""
content = content.replace(new_start, old_start)

# Add isScrollControlled: true
content = content.replace(
    "void _showReceiveSheet(BuildContext context) {\n    showModalBottomSheet(\n      context: context,\n      backgroundColor: Colors.white,\n      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),",
    "void _showReceiveSheet(BuildContext context) {\n    showModalBottomSheet(\n      context: context,\n      isScrollControlled: true,\n      backgroundColor: Colors.white,\n      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),"
)

with open(filepath, 'w') as f:
    f.write(content)
