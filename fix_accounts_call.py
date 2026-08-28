filepath = "lib/features/accounts/accounts_screen.dart"
with open(filepath, 'r') as f:
    content = f.read()

content = content.replace("ref.read(accountsProvider.notifier).state = [\n                  ...ref.read(accountsProvider),\n                  Account(\n                    id: 'acc_gbp',\n                    currency: 'GBP',\n                    balance: const Money(minorUnits: 0, currency: 'GBP'),\n                    type: AccountType.personal,\n                  ),\n                ];",
"""ref.read(accountsProvider.notifier).addAccount(
                  Account(
                    id: 'acc_gbp',
                    currency: 'GBP',
                    balance: const Money(minorUnits: 0, currency: 'GBP'),
                    type: AccountType.personal,
                  ),
                );""")

content = content.replace("ref.read(accountsProvider.notifier).state = [\n                  ...ref.read(accountsProvider),\n                  Account(\n                    id: 'acc_eur',\n                    currency: 'EUR',\n                    balance: const Money(minorUnits: 0, currency: 'EUR'),\n                    type: AccountType.personal,\n                  ),\n                ];",
"""ref.read(accountsProvider.notifier).addAccount(
                  Account(
                    id: 'acc_eur',
                    currency: 'EUR',
                    balance: const Money(minorUnits: 0, currency: 'EUR'),
                    type: AccountType.personal,
                  ),
                );""")

with open(filepath, 'w') as f:
    f.write(content)
