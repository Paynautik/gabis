filepath = "lib/features/landing/landing_screen.dart"
with open(filepath, 'r') as f:
    content = f.read()

# 1. Fix line 346 text string (use double quotes and remove const if needed)
content = content.replace(
    "child: const Text(\n                      'Interact with Elumo's core consumer tools instantly. Tap the modules below to test our dynamic prototypes.',",
    'child: const Text(\n                      "Interact with Elumo\'s core consumer tools instantly. Tap the modules below to test our dynamic prototypes.",'
)

# 2. Remove const from const Column in BusinessSection build (around line 777)
content = content.replace(
    "              const Column(\n                children: [\n                  Text(\n                    'ELUMOPAY BUSINESS',",
    "              Column(\n                children: [\n                  const Text(\n                    'ELUMOPAY BUSINESS',"
)

# 3. Clean up the subtitle inside that column
content = content.replace(
    "                  Text(\n                    'Reconcile, manage and understand your money.',\n                    textAlign: TextAlign.center,\n                    style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900),\n                  ),\n                  const SizedBox(height: 16),\n                  ConstrainedBox(\n                    constraints: const BoxConstraints(maxWidth: 600),\n                    child: Text(\n                      'Automate collections and reconciliations from multiple payment channels. Stop manually reviewing accounts.',\n                      textAlign: TextAlign.center,\n                      style: TextStyle(color: brandMuted, fontSize: 15, height: 1.5),\n                    ),\n                  ),",
    "                  const Text(\n                    'Reconcile, manage and understand your money.',\n                    textAlign: TextAlign.center,\n                    style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900),\n                  ),\n                  const SizedBox(height: 16),\n                  ConstrainedBox(\n                    constraints: const BoxConstraints(maxWidth: 600),\n                    child: const Text(\n                      'Automate collections and reconciliations from multiple payment channels. Stop manually reviewing accounts.',\n                      textAlign: TextAlign.center,\n                      style: TextStyle(color: brandMuted, fontSize: 15, height: 1.5),\n                    ),\n                  ),"
)

with open(filepath, 'w') as f:
    f.write(content)

print("Landing page const fixes applied.")
