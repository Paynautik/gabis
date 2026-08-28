import re

filepath = "lib/features/home/home_screen.dart"
with open(filepath, 'r') as f:
    content = f.read()

# Replace _buildActionCard entirely using regex
pattern = r"Widget _buildActionCard\(\{.*?\}\) \{.*?return InkWell\(.*?\}\s*\)\s*;\s*\}"

new_card = """Widget _buildActionCard({
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
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5, color: context.colors.ink, letterSpacing: -0.2),
          ),
        ],
      ),
    );
  }"""

content = re.sub(pattern, new_card, content, flags=re.DOTALL)

# Fix GridView count to 5 and aspect ratio
grid_pattern = r"GridView\.count\(\s*crossAxisCount:\s*4,\s*shrinkWrap:\s*true,\s*physics:\s*const NeverScrollableScrollPhysics\(\),\s*crossAxisSpacing:\s*16,\s*mainAxisSpacing:\s*16,\s*childAspectRatio:\s*1\.2,"
new_grid = """GridView.count(
          crossAxisCount: 5,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 8,
          mainAxisSpacing: 16,
          childAspectRatio: 0.75,"""

# If crossAxisCount is already 5 from a previous attempt:
grid_pattern_5 = r"GridView\.count\(\s*crossAxisCount:\s*5,\s*shrinkWrap:\s*true,\s*physics:\s*const NeverScrollableScrollPhysics\(\),\s*crossAxisSpacing:\s*16,\s*mainAxisSpacing:\s*16,\s*childAspectRatio:\s*1\.2,"

content = re.sub(grid_pattern, new_grid, content)
content = re.sub(grid_pattern_5, new_grid, content)


# Make sure the label is 'Bills' instead of 'Pay Bills'
content = content.replace("title: 'Pay Bills',", "title: 'Bills',")

with open(filepath, 'w') as f:
    f.write(content)
