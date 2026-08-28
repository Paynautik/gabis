import re

filepath = "lib/features/home/home_screen.dart"
with open(filepath, 'r') as f:
    content = f.read()

# Change Quick Actions layout from a Grid to a Row of vertical items

old_action_card = """  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required Color bg,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.colors.bgSoft,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: context.colors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: context.colors.ink)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(color: context.colors.inkSoft, fontSize: 10.5, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: context.colors.inkSoft, size: 16),
          ],
        ),
      ),
    );
  }"""

new_action_card = """  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required Color bg,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.visible,
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5, color: context.colors.ink, letterSpacing: -0.2),
          ),
        ],
      ),
    );
  }"""

content = content.replace(old_action_card, new_action_card)

# Now fix the GridView to be a Row
old_grid = """        GridView.count(
          crossAxisCount: 5,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,"""

new_grid = """        GridView.count(
          crossAxisCount: 5,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 8,
          mainAxisSpacing: 16,
          childAspectRatio: 0.8,"""

content = content.replace(old_grid, new_grid)

# Change the Pay Bills text to just "Bills" so it fits perfectly on tiny screens too
content = content.replace("title: 'Pay Bills',", "title: 'Bills',")

with open(filepath, 'w') as f:
    f.write(content)
