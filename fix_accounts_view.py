import re

filepath = "lib/features/home/home_screen.dart"
with open(filepath, 'r') as f:
    content = f.read()

# Fix the Account name color
content = content.replace(
    "Text(name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: Colors.white)),",
    "Text(name, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: context.colors.ink)),"
)

# Fix the Account balance color
content = content.replace(
    "Text(a.balance.format(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Colors.white, letterSpacing: -0.5)),",
    "Text(a.balance.format(), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: context.colors.ink, letterSpacing: -0.5)),"
)

# Make the more_vert icon functional
old_icon = "Icon(Icons.more_vert_rounded, color: context.colors.inkSoft, size: 18),"
new_icon = """Theme(
                          data: Theme.of(context).copyWith(
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                          ),
                          child: PopupMenuButton<String>(
                            padding: EdgeInsets.zero,
                            icon: Icon(Icons.more_vert_rounded, color: context.colors.inkSoft, size: 18),
                            color: context.colors.bgSoft,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            onSelected: (value) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${value} coming soon')));
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(value: 'View Statement', child: Row(children: [Icon(Icons.receipt_long_rounded, size: 18), SizedBox(width: 8), Text('View Statement')])),
                              PopupMenuItem(value: 'Hide Balance', child: Row(children: [Icon(Icons.visibility_off_rounded, size: 18), SizedBox(width: 8), Text('Hide Balance')])),
                              PopupMenuItem(value: 'Account Details', child: Row(children: [Icon(Icons.info_outline_rounded, size: 18), SizedBox(width: 8), Text('Account Details')])),
                            ],
                          ),
                        ),"""

content = content.replace(old_icon, new_icon)

with open(filepath, 'w') as f:
    f.write(content)
