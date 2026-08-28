import re

filepath = "lib/shared/providers/app_providers.dart"
with open(filepath, 'r') as f:
    content = f.read()

new_method = """  void addAccount(Account account) {
    if (!state.any((a) => a.currency == account.currency)) {
      state = [...state, account];
    }
  }

  void addBalance(String currency, int amountMinor) {"""

content = content.replace("  void addBalance(String currency, int amountMinor) {", new_method)

with open(filepath, 'w') as f:
    f.write(content)
