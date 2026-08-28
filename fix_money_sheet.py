import re
filepath = "lib/features/home/home_screen.dart"
with open(filepath, 'r') as f:
    content = f.read()

content = content.replace("_showAddMoneySheet(context)", "_showAddMoneySheet(context, ref)")
content = content.replace("Money.zero().format()", "'₦0.00'")

with open(filepath, 'w') as f:
    f.write(content)
