import re

filepath = "lib/features/home/sidebar_screens.dart"
with open(filepath, 'r') as f:
    content = f.read()

old_screen = """// --- Beneficiaries Screen ---
class BeneficiariesScreen extends StatelessWidget {
  const BeneficiariesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final names = ['Alice Smith', 'Bob Johnson', 'Charlie Davis', 'Diana Evans', 'Evan Miller'];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Beneficiaries'),
        actions: [IconButton(icon: const Icon(Icons.add_rounded), onPressed: () {})],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(24),
        itemCount: names.length,
        separatorBuilder: (context, index) => Divider(height: 32, color: context.colors.border),
        itemBuilder: (context, index) {
          final name = names[index];
          final initials = name.split(' ').map((e) => e[0]).join('');
          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              radius: 24,
              backgroundColor: context.colors.bluePrimary.withValues(alpha: 0.1),
              child: Text(initials, style: TextStyle(color: context.colors.bluePrimary, fontSize: 16, fontWeight: FontWeight.w900)),
            ),
            title: Text(name, style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w800, fontSize: 16)),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text('Bank Account', style: TextStyle(color: context.colors.inkSoft, fontSize: 13)),
            ),
            trailing: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: context.colors.bluePrimary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.send_rounded, color: context.colors.bluePrimary, size: 18),
            ),
            onTap: () {},
          );
        },
      ),
    );
  }
}"""

new_screen = """// --- Beneficiaries Screen ---
class BeneficiariesScreen extends StatelessWidget {
  const BeneficiariesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final names = ['Alice Smith', 'Bob Johnson', 'Charlie Davis', 'Diana Evans', 'Evan Miller'];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Beneficiaries'),
        actions: [IconButton(icon: const Icon(Icons.add_rounded, color: context.colors.ink), onPressed: () => _showAddBeneficiary(context))],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(24),
        itemCount: names.length,
        separatorBuilder: (context, index) => Divider(height: 32, color: context.colors.border),
        itemBuilder: (context, index) {
          final name = names[index];
          final initials = name.split(' ').map((e) => e[0]).join('');
          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              radius: 24,
              backgroundColor: context.colors.bluePrimary.withValues(alpha: 0.1),
              child: Text(initials, style: TextStyle(color: context.colors.bluePrimary, fontSize: 16, fontWeight: FontWeight.w900)),
            ),
            title: Text(name, style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w800, fontSize: 16)),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text('Bank Account', style: TextStyle(color: context.colors.inkSoft, fontSize: 13)),
            ),
            trailing: IconButton(
              onPressed: () => _showSendToBeneficiary(context, name),
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: context.colors.bluePrimary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.send_rounded, color: context.colors.bluePrimary, size: 18),
              ),
            ),
            onTap: () => _showSendToBeneficiary(context, name),
          );
        },
      ),
    );
  }

  void _showSendToBeneficiary(BuildContext context, String name) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.bgSoft,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Send to $name', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: context.colors.ink)),
                  IconButton(icon: Icon(Icons.close_rounded, color: context.colors.inkSoft), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                keyboardType: TextInputType.number,
                style: TextStyle(color: context.colors.ink),
                decoration: InputDecoration(
                  labelText: 'Amount',
                  labelStyle: TextStyle(color: context.colors.inkSoft),
                  prefixText: '\$ ',
                  prefixStyle: TextStyle(color: context.colors.ink, fontWeight: FontWeight.bold),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: context.colors.border)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: context.colors.bluePrimary, width: 2)),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Money successfully sent to $name!')));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.bluePrimary,
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Send Now', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  void _showAddBeneficiary(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.bgSoft,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Add Beneficiary', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: context.colors.ink)),
                  IconButton(icon: Icon(Icons.close_rounded, color: context.colors.inkSoft), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                keyboardType: TextInputType.number,
                style: TextStyle(color: context.colors.ink),
                decoration: InputDecoration(
                  labelText: 'Account Number',
                  labelStyle: TextStyle(color: context.colors.inkSoft),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: context.colors.border)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: context.colors.bluePrimary, width: 2)),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('New Beneficiary added successfully!')));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.bluePrimary,
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Save Beneficiary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}"""

content = content.replace(old_screen, new_screen)

with open(filepath, 'w') as f:
    f.write(content)
