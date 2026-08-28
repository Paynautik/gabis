import os

files_to_update = [
    "lib/features/transfers/send_money_screen.dart",
    "lib/shared/providers/contacts_provider.dart",
    "lib/shared/models/app_contact.dart"
]

for filepath in files_to_update:
    with open(filepath, 'r') as f:
        content = f.read()
    
    content = content.replace("PayNautik", "NautikOne")
    content = content.replace("hasPayNautik", "hasNautikOne")
    content = content.replace("onPayNautik", "onNautikOne")
    content = content.replace("notOnPayNautik", "notOnNautikOne")

    with open(filepath, 'w') as f:
        f.write(content)
        
print("Updated references to NautikOne")
