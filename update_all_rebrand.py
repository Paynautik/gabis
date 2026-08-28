import re

# 1. Global Replacement of "NautikOne" and "Nautik" to "Elumo" in Dart files
import os

files_to_update = [
    "lib/app/app.dart",
    "lib/features/home/home_shell.dart",
    "lib/features/home/sidebar_screens.dart",
    "lib/features/home/home_screen.dart",
    "lib/features/auth/login_screen.dart",
    "lib/features/auth/splash_screen.dart",
    "lib/features/fx/fx_screen.dart",
    "lib/features/cards/cards_screen.dart",
    "lib/features/transfers/send_money_screen.dart",
    "lib/features/transfers/send_success_screen.dart",
    "lib/features/transfers/send_confirm_screen.dart",
    "lib/features/profile/profile_screen.dart",
    "lib/features/accounts/accounts_screen.dart",
    "lib/shared/providers/app_providers.dart",
    "lib/shared/widgets/gradient_balance_card.dart",
    "lib/shared/widgets/sleek_trend_chart.dart",
    "lib/shared/widgets/animated_balance_text.dart",
    "lib/shared/widgets/glowing_background.dart",
    "lib/shared/widgets/in_app_notification.dart",
    "lib/shared/widgets/coming_soon.dart",
    "lib/shared/widgets/transaction_tile.dart",
    "test/widget_test.dart",
    "web/index.html"
]

for filepath in files_to_update:
    if not os.path.exists(filepath):
        continue
    with open(filepath, 'r') as f:
        content = f.read()
    
    # Replace NautikOne and NautikOne.com
    content = content.replace("NautikOne.com", "Elumo.com")
    content = content.replace("NautikOne", "Elumo")
    content = content.replace("NAUTIKONE", "ELUMO")
    
    # Replace Nautik (but NOT PayNautik or paynautik.com)
    # Using regex to match 'Nautik' only if not preceded by 'Pay'
    content = re.sub(r'(?<!Pay)Nautik(?![\w\.\-])', 'Elumo', content)
    content = re.sub(r'(?<!Pay)Nautik (?![\w\.\-])', 'Elumo ', content)
    
    # Special replacements
    content = content.replace("Nautik Partner Bank", "Elumo Partner Bank")
    content = content.replace("Nautik US", "Elumo US")
    content = content.replace("Nautik Support Bot", "Elumo Support Bot")
    
    with open(filepath, 'w') as f:
        f.write(content)

print("Global rebrand to Elumo completed.")
