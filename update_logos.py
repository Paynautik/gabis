# 1. Update splash screen
splash_path = "lib/features/auth/splash_screen.dart"
with open(splash_path, 'r') as f:
    splash = f.read()

splash = "import '../../shared/widgets/nautik_logo.dart';\n" + splash
splash = splash.replace("const Image(image: AssetImage('assets/logo_mark_white.png'), width: 72, height: 72),", "const NautikLogoMark(size: 80),")
with open(splash_path, 'w') as f:
    f.write(splash)

# 2. Update login screen
login_path = "lib/features/auth/login_screen.dart"
with open(login_path, 'r') as f:
    login = f.read()

login = "import '../../shared/widgets/nautik_logo.dart';\n" + login
login = login.replace("const Image(image: AssetImage('assets/logo_mark.png'), width: 36, height: 36),", "const NautikLogoMark(size: 36),")
with open(login_path, 'w') as f:
    f.write(login)

# 3. Update home shell
shell_path = "lib/features/home/home_shell.dart"
with open(shell_path, 'r') as f:
    shell = f.read()

shell = "import '../../shared/widgets/nautik_logo.dart';\n" + shell
old_logo = """                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: context.colors.bluePrimary,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: const Icon(Icons.bubble_chart_rounded, color: Colors.white, size: 20),
                        ),"""

new_logo = """                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        const NautikLogoMark(size: 32),"""

shell = shell.replace(old_logo, new_logo)
with open(shell_path, 'w') as f:
    f.write(shell)

