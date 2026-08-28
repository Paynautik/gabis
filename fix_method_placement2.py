with open("lib/features/home/home_screen.dart", 'r') as f:
    lines = f.readlines()

method_start = -1
for i, line in enumerate(lines):
    if "void _showBusinessInsights" in line:
        method_start = i
        break

if method_start != -1:
    method_lines = lines[method_start:-1] # get up to the last brace
    lines = lines[:method_start]
    
    # find where _showAddMoneySheet ends
    add_money_start = -1
    for i, line in enumerate(lines):
        if "void _showAddMoneySheet" in line:
            add_money_start = i
            break
            
    insert_idx = add_money_start
    for i in range(add_money_start, len(lines)):
        if lines[i].startswith("  }"):
            insert_idx = i + 1
            break
            
    lines = lines[:insert_idx] + ["\n"] + method_lines + lines[insert_idx:]
    with open("lib/features/home/home_screen.dart", 'w') as f:
        f.writelines(lines)
    print("Method moved")
