import re

def process_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    # Fix static access: AppColors.something -> context.colors.something
    content = re.sub(r'AppColors\.([a-zA-Z0-9_]+)', r'context.colors.\1', content)
    
    # Remove const from Text widgets that now use context.colors
    content = re.sub(r'const Text\(([^)]*context\.colors\.[^)]*)\)', r'Text(\1)', content)
    
    # Remove const from Icon widgets that now use context.colors
    content = re.sub(r'const Icon\(([^)]*context\.colors\.[^)]*)\)', r'Icon(\1)', content)

    # Remove const from container decoration and border side
    content = re.sub(r'const BoxDecoration\(([^)]*context\.colors\.[^)]*)\)', r'BoxDecoration(\1)', content)
    content = re.sub(r'const BorderSide\(([^)]*context\.colors\.[^)]*)\)', r'BorderSide(\1)', content)
    
    # Specifically for FontWeight.w950 -> FontWeight.w900
    content = content.replace("FontWeight.w950", "FontWeight.w900")
    
    # Remove const from BoxConstraints if anything is dynamic
    content = content.replace("const BoxConstraints", "BoxConstraints")
    
    # Fix the undefined parameter in home_screen.dart
    content = content.replace("maxWidth: 600", "minWidth: 0") 
    
    # Fix arrow_left_right_rounded
    content = content.replace("Icons.arrow_left_right_rounded", "Icons.swap_horiz_rounded")

    # Fix undefined obsidianBg -> bgSoft or scaffoldBg
    content = content.replace("context.colors.obsidianBg", "context.colors.bgSoft")

    # Fix showAddMoneySheet missing ref
    content = content.replace("onTap: () => _showAddMoneySheet(context),", "onTap: () => _showAddMoneySheet(context, ref),")

    with open(filepath, 'w') as f:
        f.write(content)

process_file("lib/features/home/home_screen.dart")
process_file("lib/features/home/home_shell.dart")
