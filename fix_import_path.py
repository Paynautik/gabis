filepath = "lib/features/home/home_screen.dart"
with open(filepath, 'r') as f:
    content = f.read()

content = content.replace("import 'package:url_launcher/url_launcher';", "import 'package:url_launcher/url_launcher.dart';")

with open(filepath, 'w') as f:
    f.write(content)
