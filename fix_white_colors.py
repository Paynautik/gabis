import os

filepath = "lib/features/home/home_screen.dart"

with open(filepath, 'r') as f:
    lines = f.readlines()

def replace_line(line_index, old, new):
    if old in lines[line_index]:
        lines[line_index] = lines[line_index].replace(old, new)

# 137: Icon(Icons.notifications_outlined, color: Colors.white
replace_line(136, 'color: Colors.white', 'color: context.colors.ink')

# 230: style: const TextStyle(color: Colors.white, fontSize: 32
replace_line(229, 'const TextStyle(color: Colors.white', 'TextStyle(color: context.colors.ink')

# 283: Text('Accounts', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: Colors.white)
replace_line(282, 'color: Colors.white', 'color: context.colors.ink')

# 319: Text(name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: Colors.white))
replace_line(318, 'const TextStyle', 'TextStyle')
replace_line(318, 'color: Colors.white', 'color: context.colors.ink')

# 333: Text(a.balance.format(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Colors.white
replace_line(332, 'const TextStyle', 'TextStyle')
replace_line(332, 'color: Colors.white', 'color: context.colors.ink')

# 448: Text('Quick Actions', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: Colors.white))
replace_line(447, 'color: Colors.white', 'color: context.colors.ink')

# 528: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Colors.white))
replace_line(527, 'const TextStyle', 'TextStyle')
replace_line(527, 'color: Colors.white', 'color: context.colors.ink')

# 615: Text('Recent Transactions', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Colors.white))
replace_line(614, 'color: Colors.white', 'color: context.colors.ink')

# 644: Text('Spending Insights', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Colors.white))
replace_line(643, 'color: Colors.white', 'color: context.colors.ink')

# 698: backgroundColor: Colors.white,
replace_line(697, 'backgroundColor: Colors.white', 'backgroundColor: context.colors.scaffoldBg')

# 789: backgroundColor: Colors.white,
replace_line(788, 'backgroundColor: Colors.white', 'backgroundColor: context.colors.scaffoldBg')

# 941: Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800))
replace_line(940, 'const TextStyle', 'TextStyle')
replace_line(940, 'color: Colors.white', 'color: context.colors.ink')

with open(filepath, 'w') as f:
    f.writelines(lines)
print("Done fixing white colors!")
