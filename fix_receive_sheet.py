import re

filepath = "lib/features/home/home_screen.dart"
with open(filepath, 'r') as f:
    content = f.read()

old_start = """      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,"""

new_start = """      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,"""

content = content.replace(old_start, new_start)

old_end = """              ),
            ],
          ),
        );
      },
    );
  }"""

new_end = """              ),
            ],
          ),
            ),
          ),
        );
      },
    );
  }"""

content = content.replace(old_end, new_end)

with open(filepath, 'w') as f:
    f.write(content)
