filepath = "lib/features/home/sidebar_screens.dart"
with open(filepath, 'r') as f:
    content = f.read()

content = content.replace("title: Text(tx.counterparty,", "title: Text(tx.counterparty ?? 'Unknown',")
content = content.replace("subtitle: Text(tx.description,", "subtitle: Text(tx.description ?? '',")

with open(filepath, 'w') as f:
    f.write(content)
