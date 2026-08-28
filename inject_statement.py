filepath = "lib/features/home/home_screen.dart"
with open(filepath, 'r') as f:
    content = f.read()

statement_sheet = """void _showStatementSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
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
                    const Text('Account Statements', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.black)),
                    IconButton(icon: const Icon(Icons.close_rounded, color: Colors.grey), onPressed: () => Navigator.pop(context)),
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
              decoration: BoxDecoration(color: const Color(0x1A1858F2), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFF1858F2), size: 20),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(month, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 15)),
                const SizedBox(height: 2),
                Text(details, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ],
        ),
        IconButton(
          onPressed: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Downloading statement for ' + month + '...')));
          },
          icon: const Icon(Icons.download_rounded, color: Color(0xFF1858F2)),
        ),
      ],
    );
  }
"""

content = content.replace("void _showReceiveSheet", statement_sheet + "\nvoid _showReceiveSheet")

with open(filepath, 'w') as f:
    f.write(content)
