import re
filepath = "lib/features/home/home_shell.dart"
with open(filepath, 'r') as f:
    content = f.read()

# Remove the 'Premium User' text block
pattern = r"                              SizedBox\(height: 2\),\n                              Text\(\n                                'Premium User',\n                                style: TextStyle\(color: context\.colors\.inkSoft, fontSize: 10, fontWeight: FontWeight\.w600\),\n                              \),"
content = re.sub(pattern, "", content)

with open(filepath, 'w') as f:
    f.write(content)
