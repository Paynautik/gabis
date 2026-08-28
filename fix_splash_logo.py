filepath = "lib/features/auth/splash_screen.dart"
with open(filepath, 'r') as f:
    content = f.read()

old_column = """        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image(image: AssetImage('assets/logo_mark_white.png'), width: 72, height: 72),
              SizedBox(height: 16),
              Text(
                'Elumo',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),"""

new_column = """        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const NautikLogoMark(size: 80),
              const SizedBox(height: 20),
              const Text(
                'Elumo',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),"""

content = content.replace(old_column, new_column)

with open(filepath, 'w') as f:
    f.write(content)
