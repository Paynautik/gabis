filepath = "lib/features/home/home_screen.dart"
with open(filepath, 'r') as f:
    lines = f.readlines()

new_card = """  Widget _buildActionCard({
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
  }\n"""

# Find exact start and end
start_idx = -1
end_idx = -1
for i, line in enumerate(lines):
    if line.startswith("  Widget _buildActionCard({"):
        start_idx = i
        break

if start_idx != -1:
    # Find the end of the method (search for "  }" after start_idx)
    brace_count = 0
    in_method = False
    for i in range(start_idx, len(lines)):
        line = lines[i]
        if '{' in line:
            brace_count += line.count('{')
            in_method = True
        if '}' in line:
            brace_count -= line.count('}')
        if in_method and brace_count == 0:
            end_idx = i
            break
            
if start_idx != -1 and end_idx != -1:
    lines = lines[:start_idx] + [new_card] + lines[end_idx+1:]
    
with open(filepath, 'w') as f:
    f.writelines(lines)

# Also fix GridView.count spacing and aspect ratio
with open(filepath, 'r') as f:
    content = f.read()

content = content.replace(
"""        GridView.count(
          crossAxisCount: 5,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,""", 
"""        GridView.count(
          crossAxisCount: 5,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 8,
          mainAxisSpacing: 16,
          childAspectRatio: 0.75,"""
)
# In case it's still crossAxisCount: 4
content = content.replace(
"""        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,""", 
"""        GridView.count(
          crossAxisCount: 5,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 8,
          mainAxisSpacing: 16,
          childAspectRatio: 0.75,"""
)

content = content.replace("title: 'Pay Bills',", "title: 'Bills',")

with open(filepath, 'w') as f:
    f.write(content)
