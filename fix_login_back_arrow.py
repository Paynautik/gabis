filepath = "lib/features/auth/login_screen.dart"
with open(filepath, 'r') as f:
    content = f.read()

old_logo_row = """              Row(
                children: [
                  const NautikLogoMark(size: 36),
                  const SizedBox(width: 12),
                  const Text(
                    'Elumo',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                ],
              ),"""

new_logo_row = """              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios_new_rounded, color: context.colors.ink, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 8),
                  const NautikLogoMark(size: 36),
                  const SizedBox(width: 12),
                  const Text(
                    'Elumo',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: context.colors.ink),
                  ),
                ],
              ),"""

content = content.replace(old_logo_row, new_logo_row)

with open(filepath, 'w') as f:
    f.write(content)
