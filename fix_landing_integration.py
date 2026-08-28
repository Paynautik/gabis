# 1. Update landing logo to the official wave logo
with open("lib/features/landing/landing_screen.dart", 'r') as f:
    landing = f.read()

landing = "import '../../shared/widgets/nautik_logo.dart';\n" + landing

old_logo_box = """                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2563EB), Color(0xFF8B5CF6)],
                      ),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: const Icon(
                      Icons.bolt_rounded,
                      color: Colors.white,
                    ),
                  ),"""

new_logo_box = "const NautikLogoMark(size: 38),"

landing = landing.replace(old_logo_box, new_logo_box)

with open("lib/features/landing/landing_screen.dart", 'w') as f:
    f.write(landing)

# 2. Update app.dart routes and import
with open("lib/app/app.dart", 'r') as f:
    app = f.read()

app = "import '../features/landing/landing_screen.dart';\n" + app
app = app.replace("initialRoute: '/splash',", "initialRoute: '/splash',")
app = app.replace("'/splash': (_) => const SplashScreen(),", "'/splash': (_) => const SplashScreen(),\n        '/landing': (_) => const LandingScreen(),")

with open("lib/app/app.dart", 'w') as f:
    f.write(app)

# 3. Update splash_screen.dart navigation target to /landing
with open("lib/features/auth/splash_screen.dart", 'r') as f:
    splash = f.read()

splash = splash.replace("pushReplacementNamed('/login')", "pushReplacementNamed('/landing')")

with open("lib/features/auth/splash_screen.dart", 'w') as f:
    f.write(splash)

print("Landing page integration complete.")
