import re
filepath = "lib/features/home/home_screen.dart"
with open(filepath, 'r') as f:
    content = f.read()

new_end = """              ),
            ],
          ),
            ),
          ),
        );
      },
    );
  }"""
old_end = """              ),
            ],
          ),
        );
      },
    );
  }"""
content = content.replace(new_end, old_end)
with open(filepath, 'w') as f:
    f.write(content)
