filepath = "lib/features/landing/landing_screen.dart"
with open(filepath, 'r') as f:
    content = f.read()

# 1. Update Hero Title to "Get paid. Stay organized. Know your money."
content = content.replace(
    "        const Text(\n          'Your business\\nhas the data.\\nElumo gives it\\nintelligence.',",
    """        const Text(
          'Get paid.\\nStay organized.\\nKnow your money.',"""
)

# 2. Update Hero Subheading to the new lifecycle description
content = content.replace(
    "const Text(\n          'ElumoPay is an AI-powered financial super app. Send money across borders, spend globally with virtual debit cards, pay bills, and automate business collections and reconciliations in one platform.',",
    "const Text(\n          'ElumoPay is a payment + receipt + refund + installment + reconciliation operating system. We help African sellers and service businesses manage the entire transaction lifecycle in one place.',"
)

# 3. Update Copilot Presets to showcase refunds, installments, and reconciled income
old_copilot_chips = """                            _queryChip(
                              label: "Who hasn't paid?",
                              query: "Who hasn't paid?",
                              response: "Outstanding invoices (₦2.8M total):\\n- **Sarah Designs:** ₦150k (34d overdue)\\n- **Emma Watson:** ₦90k (31d overdue)\\n\\n[Send reminder link]",
                            ),
                            const SizedBox(width: 6),
                            _queryChip(
                              label: "Reconciliation review",
                              query: "Reconciliation review",
                              response: "Reconciliation health: **100%**\\n\\nGemini matched INV-1024 with a bank transfer from S. Jenkins automatically.",
                            ),
                            const SizedBox(width: 6),
                            _queryChip(
                              label: "Cash-flow projection",
                              query: "Cash-flow projection",
                              response: "Expected cash in 30 days: **₦14.2M**\\n\\nBased on outstanding invoices + seasonal revenue patterns.",
                            ),"""

new_copilot_chips = """                            _queryChip(
                              label: "Who has overdue installments?",
                              query: "Who has overdue installments?",
                              response: "📅 **Overdue Installment Status:**\\n- **Mwangi Kamau:** ₦50,000 due (3 days overdue) • *Service Cut-off Active*\\n- **Amara Diallo:** ₦30,000 due (1 day overdue)\\n\\n[Send Reminders] [Review Service Status]",
                            ),
                            const SizedBox(width: 6),
                            _queryChip(
                              label: "Which refunds are approaching?",
                              query: "Which refunds are approaching?",
                              response: "⚠️ **Refund Deadlines Approaching:**\\n1. **Sarah Okafor** • ₦45,000 (Refund window closes in 2 days)\\n2. **Kofi Mensah** • ₦60,000 (Cancellation period closes in 4 days)",
                            ),
                            const SizedBox(width: 6),
                            _queryChip(
                              label: "Income from photography?",
                              query: "Income from photography?",
                              response: "📊 **Photography & Consulting: ₦1,250,000 collected.**\\n- **Reconciled Paid:** ₦1,050,000 (8 Invoices)\\n- **Installments Pending:** ₦200,000 (3 Customers)",
                            ),"""

content = content.replace(old_copilot_chips, new_copilot_chips)

# 4. Update Footer to include the strong one-line positioning
content = content.replace(
    "          const Text(\n            'AI-Powered Financial Operating System for African Businesses.',",
    "          const Text(\n            'ElumoPay — From payment to proof, Elumo keeps your business on track.',"
)

with open(filepath, 'w') as f:
    f.write(content)

print("Landing page lifecycle updates completed successfully.")
