filepath = "lib/features/home/home_shell.dart"
with open(filepath, 'r') as f:
    content = f.read()

old_invite = """                          decoration: BoxDecoration(
                            color: const Color(0xFF1E283F),
                            borderRadius: BorderRadius.circular(20),
                          ),"""
new_invite = """                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1E283F), Color(0xFF0F172A)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),"""
content = content.replace(old_invite, new_invite)

with open(filepath, 'w') as f:
    f.write(content)
