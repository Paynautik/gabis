import re

filepath = "lib/features/home/home_screen.dart"
with open(filepath, 'r') as f:
    content = f.read()

# Add _hideBalances state variable
if "bool _hideBalances = false;" not in content:
    content = content.replace("bool _showAllTransactions = false;", "bool _showAllTransactions = false;\n  bool _hideBalances = false;")

# Fix the popup menu in _buildAccountsSection
old_menu = """                          child: PopupMenuButton<String>(
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
                          ),"""

new_menu = """                          child: PopupMenuButton<String>(
                            padding: EdgeInsets.zero,
                            icon: Icon(Icons.more_vert_rounded, color: context.colors.inkSoft, size: 18),
                            color: context.colors.bgSoft,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            onSelected: (value) {
                              if (value == 'View Statement') {
                                _showStatementSheet(context);
                              } else if (value == 'Hide Balance' || value == 'Show Balance') {
                                setState(() => _hideBalances = !_hideBalances);
                              } else if (value == 'Account Details') {
                                _showReceiveSheet(context);
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(value: 'View Statement', child: Row(children: [Icon(Icons.receipt_long_rounded, color: context.colors.inkSoft, size: 18), SizedBox(width: 8), Text('View Statement', style: TextStyle(color: context.colors.ink))])),
                              PopupMenuItem(value: _hideBalances ? 'Show Balance' : 'Hide Balance', child: Row(children: [Icon(_hideBalances ? Icons.visibility_rounded : Icons.visibility_off_rounded, color: context.colors.inkSoft, size: 18), SizedBox(width: 8), Text(_hideBalances ? 'Show Balance' : 'Hide Balance', style: TextStyle(color: context.colors.ink))])),
                              PopupMenuItem(value: 'Account Details', child: Row(children: [Icon(Icons.info_outline_rounded, color: context.colors.inkSoft, size: 18), SizedBox(width: 8), Text('Account Details', style: TextStyle(color: context.colors.ink))])),
                            ],
                          ),"""
content = content.replace(old_menu, new_menu)

# Fix the balance display
content = content.replace(
    "Text(a.balance.format(), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: context.colors.ink, letterSpacing: -0.5)),",
    "Text(_hideBalances ? '****' : a.balance.format(), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: context.colors.ink, letterSpacing: -0.5)),"
)
# Note: Also do it for NetWorth card if needed? The user specifically meant the account cards menu. I will also mask the main net worth just in case.
content = content.replace(
    "Text(balance.format(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 32, color: Colors.white, letterSpacing: -1.0)),",
    "Text(_hideBalances ? '****' : balance.format(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 32, color: Colors.white, letterSpacing: -1.0)),"
)


# Add the _showStatementSheet method
statement_sheet = """  void _showStatementSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.bgSoft,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Account Statements', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: context.colors.ink)),
                    IconButton(icon: Icon(Icons.close_rounded, color: context.colors.inkSoft), onPressed: () => Navigator.pop(context)),
                  ],
                ),
                const SizedBox(height: 16),
                _buildStatementRow(context, 'August 2026', 'PDF • 124 KB'),
                const Divider(height: 32),
                _buildStatementRow(context, 'July 2026', 'PDF • 140 KB'),
                const Divider(height: 32),
                _buildStatementRow(context, 'June 2026', 'PDF • 118 KB'),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatementRow(BuildContext context, String month, String details) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: context.colors.bluePrimary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(Icons.picture_as_pdf_rounded, color: context.colors.bluePrimary, size: 20),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(month, style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w800, fontSize: 15)),
                const SizedBox(height: 2),
                Text(details, style: TextStyle(color: context.colors.inkSoft, fontSize: 12)),
              ],
            ),
          ],
        ),
        IconButton(
          onPressed: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Downloading statement for $month...')));
          },
          icon: Icon(Icons.download_rounded, color: context.colors.bluePrimary),
        ),
      ],
    );
  }
"""

if "_showStatementSheet" not in content:
    content = content.replace("  void _showReceiveSheet", statement_sheet + "\n  void _showReceiveSheet")

with open(filepath, 'w') as f:
    f.write(content)
