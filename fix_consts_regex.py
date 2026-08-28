import os, re

lib_dir = "lib"

def process_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    # Find `const Something( ... context.colors ... )`
    # We replace `const ` with nothing if it precedes an expression containing `context.colors` inside its parens.
    # This regex looks for `const ` followed by an identifier, an open paren, any chars non-greedy, `context.colors`.
    new_content = re.sub(r'const\s+([A-Za-z0-9_]+\s*\([^)]*?context\.colors)', r'\1', content, flags=re.DOTALL|re.MULTILINE)
    
    if new_content != content:
        with open(filepath, 'w') as f:
            f.write(new_content)
        print(f"Regex fixed {filepath}")

for root, _, files in os.walk(lib_dir):
    for file in files:
        if file.endswith('.dart'):
            process_file(os.path.join(root, file))

