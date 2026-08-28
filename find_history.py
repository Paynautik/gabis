import os
import glob

history_dir = "/Users/raphaelgab-momoh/Library/Application Support/Code/User/History"
matches = []

for filepath in glob.glob(f"{history_dir}/*/*"):
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
            if "_buildNetWorthCard(Money balance)" in content and "Widget _buildAccountsSection" in content:
                stat = os.stat(filepath)
                matches.append((stat.st_mtime, filepath))
    except Exception as e:
        pass

matches.sort(reverse=True)
print("Found matching history files:")
for mtime, f in matches[:5]:
    print(f"Time: {mtime} - {f}")
