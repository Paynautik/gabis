import re

# --- 1. Fix Virtual Card ---
filepath = "lib/features/cards/cards_screen.dart"
with open(filepath, 'r') as f:
    content = f.read()

def wrap_container(match):
    body = match.group(0)
    # Remove height: 220,
    body = body.replace("height: 220,\n", "")
    body = body.replace("height: 220,", "")
    return "return Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 400), child: AspectRatio(aspectRatio: 1.586, child: " + body[7:] + ")));"

# Replace return Container(...) for both methods.
content = re.sub(r'return Container\(\s+height: 220,.*?(?=^  Widget|^\}$)', 
                 lambda m: wrap_container(m)[:-4] + ")));\n\n", 
                 content, flags=re.MULTILINE|re.DOTALL)

with open(filepath, 'w') as f:
    f.write(content)

# --- 2. Fix View All Transactions ---
filepath = "lib/features/home/home_screen.dart"
with open(filepath, 'r') as f:
    content = f.read()

if "bool _showAllTransactions = false;" not in content:
    content = content.replace(
        "bool _showPromoBanner = true;",
        "bool _showPromoBanner = true;\n  bool _showAllTransactions = false;"
    )

content = content.replace(
    "TextButton(\n                onPressed: () {},",
    "TextButton(\n                onPressed: () => setState(() => _showAllTransactions = !_showAllTransactions),"
)
content = content.replace(
    "child: Text('View all', style: TextStyle(color: context.colors.bluePrimary",
    "child: Text(_showAllTransactions ? 'View less' : 'View all', style: TextStyle(color: context.colors.bluePrimary"
)
content = content.replace(
    "...transactions.take(3).map((tx) => TransactionTile(transaction: tx)),",
    "...transactions.take(_showAllTransactions ? transactions.length : 3).map((tx) => TransactionTile(transaction: tx)),"
)

with open(filepath, 'w') as f:
    f.write(content)

# --- 3. Fix Sidebar Profile Block (Collapsible + Remove Premium User) ---
filepath = "lib/features/home/home_shell.dart"
with open(filepath, 'r') as f:
    content = f.read()

# Replace the User Details Box with a PopupMenuButton
old_user_box = r"                  // User Details Box\n                  Container\(.*?Icon\(Icons\.keyboard_arrow_down_rounded, color: context\.colors\.inkSoft, size: 18\),\n                      \],\n                    \),\n                  \),"

new_user_box = """                  // User Details Box (Collapsible)
                  Theme(
                    data: Theme.of(context).copyWith(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                    ),
                    child: PopupMenuButton<String>(
                      offset: const Offset(0, -100),
                      color: const Color(0xFF1E283F),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      onSelected: (value) {
                        if (value == 'settings') {
                          _showSettingsDialog(context);
                        }
                      },
                      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                        PopupMenuItem<String>(
                          value: 'settings',
                          child: Row(
                            children: [
                              Icon(Icons.settings_rounded, color: Colors.white, size: 18),
                              SizedBox(width: 8),
                              Text('Settings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                        const PopupMenuDivider(height: 1),
                        PopupMenuItem<String>(
                          value: 'logout',
                          child: Row(
                            children: [
                              Icon(Icons.logout_rounded, color: Colors.redAccent, size: 18),
                              SizedBox(width: 8),
                              Text('Log Out', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ],
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E283F),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: context.colors.bluePrimary.withValues(alpha: 0.2),
                              child: const Text('R', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Raphael Momoh',
                                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Colors.white),
                                  ),
                                  // Premium user removed and hidden in settings per request
                                ],
                              ),
                            ),
                            Icon(Icons.keyboard_arrow_up_rounded, color: const Color(0xFF94A3B8), size: 18),
                          ],
                        ),
                      ),
                    ),
                  ),"""

content = re.sub(old_user_box, new_user_box, content, flags=re.DOTALL)

with open(filepath, 'w') as f:
    f.write(content)

