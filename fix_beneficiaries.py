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
      body: GridView.builder(
        padding: const EdgeInsets.all(24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.85,
        ),
        itemCount: names.length,
        itemBuilder: (context, index) {
          final name = names[index];
          final initials = name.split(' ').map((e) => e[0]).join('');
          return Container(
            decoration: BoxDecoration(
              color: context.colors.bgSoft,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: context.colors.border),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: context.colors.bluePrimary.withValues(alpha: 0.1),
                  child: Text(initials, style: TextStyle(color: context.colors.bluePrimary, fontSize: 20, fontWeight: FontWeight.w900)),
                ),
                const SizedBox(height: 16),
                Text(name, style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w800, fontSize: 14)),
                const SizedBox(height: 4),
                Text('Bank Account', style: TextStyle(color: context.colors.inkSoft, fontSize: 11)),
              ],
            ),
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

content = content.replace(old_screen, new_screen)

with open(filepath, 'w') as f:
    f.write(content)
