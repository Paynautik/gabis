import re

filepath = "lib/features/home/home_screen.dart"
with open(filepath, 'r') as f:
    content = f.read()

modals_code = """
  // --- Header Modals ---
  void _showHelpSupportSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Help & Support', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF101828))),
              const SizedBox(height: 24),
              ListTile(
                leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFF1858F2).withValues(alpha: 0.1), shape: BoxShape.circle), child: const Icon(Icons.chat_bubble_rounded, color: Color(0xFF1858F2))),
                title: const Text('Live Chat', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                subtitle: const Text('Typically replies in 2 mins', style: TextStyle(fontSize: 11)),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFF16A34A).withValues(alpha: 0.1), shape: BoxShape.circle), child: const Icon(Icons.article_rounded, color: Color(0xFF16A34A))),
                title: const Text('FAQs', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                subtitle: const Text('Read our help articles', style: TextStyle(fontSize: 11)),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.pop(context),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showScannerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: Colors.black87,
          child: Container(
            height: 400,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Scan QR Code', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 24),
                Container(
                  height: 200,
                  width: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF00B876), width: 3),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Center(
                    child: Icon(Icons.qr_code_scanner_rounded, color: Colors.white54, size: 64),
                  ),
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Colors.white, fontSize: 14)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showNotificationsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Notifications', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF101828))),
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Mark all as read')),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    ListTile(
                      leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFF00B876).withValues(alpha: 0.1), shape: BoxShape.circle), child: const Icon(Icons.download_rounded, color: Color(0xFF00B876))),
                      title: const Text('Money Received', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                      subtitle: const Text('You received ₦50,000 from John Doe.', style: TextStyle(fontSize: 12)),
                      trailing: const Text('2m ago', style: TextStyle(fontSize: 10, color: Colors.grey)),
                    ),
                    ListTile(
                      leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFF1858F2).withValues(alpha: 0.1), shape: BoxShape.circle), child: const Icon(Icons.security_rounded, color: Color(0xFF1858F2))),
                      title: const Text('New Login', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                      subtitle: const Text('New login from Mac OS on Chrome.', style: TextStyle(fontSize: 12)),
                      trailing: const Text('1h ago', style: TextStyle(fontSize: 10, color: Colors.grey)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
"""

content = content.replace("showComingSoon(context, 'Help & Support')", "_showHelpSupportSheet(context)")
content = content.replace("showComingSoon(context, 'Scan QR')", "_showScannerDialog(context)")
content = content.replace("showComingSoon(context, 'Notifications')", "_showNotificationsSheet(context)")

# Inject before the final brace
content = content.replace("}\n}", modals_code + "\n}\n}")

with open(filepath, 'w') as f:
    f.write(content)
