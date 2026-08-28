import re

filepath = "lib/features/cards/cards_screen.dart"
with open(filepath, 'r') as f:
    content = f.read()

# I will just write a regex to clean up the broken Center(ConstrainedBox(AspectRatio(Container(...)))))
# Basically I added 3 layers of nesting, so I need to make sure I add ')));' at the end of the return statement.
# But it's already broken. Let's look at the file.
