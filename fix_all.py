import re

# 1. Fix cards_screen.dart syntax
filepath = "lib/features/cards/cards_screen.dart"
with open(filepath, 'r') as f:
    content = f.read()

# The bad replacement was: 
#   // Back Card representation
# )));
#
#   Widget _buildCardBack
content = content.replace("  // Back Card representation\n)));", "  // Back Card representation")
content = content.replace("      ),\n    );\n  }\n\n  // Back Card representation", "      ),\n    ))));\n  }\n\n  // Back Card representation")

# At the end of _buildCardBack:
content = content.replace("        ],\n      ),\n    );\n  }\n}", "        ],\n      ),\n    ))));\n  }\n}")
# Wait, let's just make sure there are no floating `)));` and inject them properly.

with open(filepath, 'w') as f:
    f.write(content)

