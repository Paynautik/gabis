import subprocess
import re

def fix_errors():
    for _ in range(5):
        print("Running flutter analyze...")
        result = subprocess.run(["flutter", "analyze"], capture_output=True, text=True)
        if result.returncode == 0:
            print("No errors!")
            break
            
        errors = result.stdout.splitlines()
        changed = False
        
        for line in errors:
            # error • Invalid constant value • lib/features/accounts/accounts_screen.dart:27:82 • invalid_constant
            if "invalid_constant" in line:
                match = re.search(r'lib/.*?\.dart:\d+', line)
                if match:
                    filepath, linenum = match.group().split(':')
                    linenum = int(linenum) - 1 # 0-indexed
                    
                    with open(filepath, 'r') as f:
                        file_lines = f.readlines()
                        
                    if 'const ' in file_lines[linenum]:
                        file_lines[linenum] = file_lines[linenum].replace('const ', '')
                        with open(filepath, 'w') as f:
                            f.writelines(file_lines)
                        print(f"Fixed {filepath}:{linenum+1}")
                        changed = True
                        
        if not changed:
            print("No more simple const fixes possible.")
            break

fix_errors()
