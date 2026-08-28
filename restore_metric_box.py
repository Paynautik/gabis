filepath = "lib/features/business/business_dashboard_screen.dart"
with open(filepath, 'r') as f:
    content = f.read()

metric_box_code = """  Widget _buildMetricBox({
    required String title,
    required String value,
    required String change,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13, fontWeight: FontWeight.bold)),
              Icon(icon, color: color, size: 18),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5),
          ),
          const SizedBox(height: 6),
          Text(
            change,
            style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }"""

# Inject right below _buildMetricsGrid method
content = content.replace(
    "  Widget _buildMetricsGrid() {",
    metric_box_code + "\\n\\n  Widget _buildMetricsGrid() {"
)

with open(filepath, 'w') as f:
    f.write(content)

print("Metric box method restored successfully.")
