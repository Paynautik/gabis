filepath = "lib/features/landing/landing_screen.dart"
with open(filepath, 'r') as f:
    content = f.read()

# 1. Update Hero Subheading to focus on "Get paid without the chase" and automated robot calls
content = content.replace(
    "const Text(\n          'ElumoPay is a payment + receipt + refund + installment + reconciliation operating system. We help African sellers and service businesses manage the entire transaction lifecycle in one place.',",
    "const Text(\n          'With ElumoPay, you don\\'t have to chase customers for payments. We automatically reconcile your income, track outstanding balances, and send automated voice reminders (robot calls) to recover what you are owed.',"
)

# 2. Update Hero Title/Badge if needed
content = content.replace(
    "Get paid.\\nStay organized.\\nKnow your money.",
    "Get paid.\\nWithout\\nthe chase."
)

# 3. Update Copilot Preset query chip
content = content.replace(
    """                            _queryChip(
                              label: "Who has overdue installments?",
                              query: "Who has overdue installments?",
                              response: "📅 **Overdue Installment Status:**\\n- **Mwangi Kamau:** ₦50,000 due (3 days overdue) • *Service Cut-off Active*\\n- **Amara Diallo:** ₦30,000 due (1 day overdue)\\n\\n[Send Reminders] [Review Service Status]",
                            ),""",
    """                            _queryChip(
                              label: "Trigger robot calls for debt?",
                              query: "Trigger robot calls for debt?",
                              response: "🤖 **AI Voice Reminder Dispatch:**\\n- **Sarah Okafor** (₦50,000 overdue) • *Robot Call scheduled: 10:15 PM*\\n- **Mwangi Kamau** (KES 50,000 due) • *Safaricom SMS dispatched*\\n\\n[Trigger Voice Call Now]",
                            ),"""
)

# 4. Update Footer positioning
content = content.replace(
    "ElumoPay — From payment to proof, Elumo keeps your business on track.",
    "ElumoPay — Get paid without the chase."
)

with open(filepath, 'w') as f:
    f.write(content)

print("Landing page chase positioning updated successfully.")
