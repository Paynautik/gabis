filepath = "lib/features/home/sidebar_screens.dart"
with open(filepath, 'r') as f:
    content = f.read()

content = content.replace("import '../../core/models/app_models.dart';", "import '../../shared/models/transaction.dart';\nimport '../../shared/models/money.dart';")
content = content.replace("import '../../core/providers/app_providers.dart';", "import '../../shared/providers/app_providers.dart';")

with open(filepath, 'w') as f:
    f.write(content)
