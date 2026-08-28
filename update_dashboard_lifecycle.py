filepath = "lib/features/business/business_dashboard_screen.dart"
with open(filepath, 'r') as f:
    content = f.read()

# 1. Update the Tab title from "Invoicing & Payroll" to "Invoices & Installments"
content = content.replace("Tab(text: 'Invoicing & Payroll'),", "Tab(text: 'Invoices & Installments'),")

# 2. Overwrite the _buildInvoicingPayrollTab method and the cards
lifecycle_methods = """
  // ============================================================
  // TAB 3: INVOICES & INSTALLMENTS lifecycle operations
  // ============================================================
  Widget _buildInvoicingPayrollTab(bool isDesktop) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 5, child: _buildInvoiceAssistantCard()),
                const SizedBox(width: 24),
                Expanded(flex: 5, child: Column(
                  children: [
                    _buildInstallmentLedgerCard(),
                    const SizedBox(height: 24),
                    _buildRefundManagerCard(),
                  ],
                )),
              ],
            )
          else ...[
            _buildInvoiceAssistantCard(),
            const SizedBox(height: 24),
            _buildInstallmentLedgerCard(),
            const SizedBox(height: 24),
            _buildRefundManagerCard(),
          ],
        ],
      ),
    );
  }

  Widget _buildInstallmentLedgerCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.payment_rounded, color: Color(0xFF22D3EE), size: 20),
              SizedBox(width: 8),
              Text('Installment & Receivables Ledger', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Track customer installment milestones, outstanding balances, payment deadlines, and service cut-offs.',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 11.5, height: 1.35),
          ),
          const SizedBox(height: 20),
          
          _installmentRow(
            name: 'Mwangi Kamau',
            service: 'Photography Consulting',
            amountPaid: 'KES 100,000',
            amountRemaining: 'KES 50,000',
            deadline: '3 days remaining',
            color: const Color(0xFF22D3EE),
            actionText: 'Send Reminder',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Payment reminder dispatched to Mwangi Kamau: "Sarah\\'s KES 50,000 installment is due in 3 days."')),
              );
            },
          ),
          const Divider(color: Colors.white10, height: 24),
          _installmentRow(
            name: 'Sarah Okafor',
            service: 'E-commerce Audit',
            amountPaid: '₦50,000',
            amountRemaining: '₦50,000',
            deadline: 'OVERDUE (1d)',
            color: Colors.redAccent,
            actionText: 'Review Service Status',
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: const Color(0xFF0F172A),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  title: const Text('Review Service Status', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  content: const Text(
                    'Sarah Okafor\\'s installment deadline has passed. Review the customer\\'s service status.',
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13.5, height: 1.4),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Restrict Client Access', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Extend Deadline', style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _installmentRow({
    required String name,
    required String service,
    required String amountPaid,
    required String amountRemaining,
    required String deadline,
    required Color color,
    required String actionText,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(name, style: const TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.bold)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
              child: Text(deadline, style: TextStyle(color: color, fontSize: 9.5, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(service, style: const TextStyle(color: Color(0xFF64748B), fontSize: 11)),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('PAID TO DATE', style: TextStyle(color: Color(0xFF475569), fontSize: 8.5, fontWeight: FontWeight.bold)),
                Text(amountPaid, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('REMAINING DUE', style: TextStyle(color: Color(0xFF475569), fontSize: 8.5, fontWeight: FontWeight.bold)),
                Text(amountRemaining, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
            ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: color.withValues(alpha: 0.15),
                foregroundColor: color,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(actionText, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRefundManagerCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.assignment_return_rounded, color: Color(0xFF10B981), size: 20),
              SizedBox(width: 8),
              Text('Refund Policy & Deadline Tracker', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Monitor refund windows and return policies. Receive alerts before customer refund deadlines expire.',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 11.5, height: 1.35),
          ),
          const SizedBox(height: 20),
          
          _refundRow(
            customer: 'Funke Adebayo',
            policy: '14-day full return policy',
            timeRemaining: '2 days remaining',
            color: const Color(0xFF10B981),
            amount: '₦150,000.00',
            actionText: 'Send e-Receipt',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('e-Receipt dispatch completed. Reference locked under transaction ledger.')),
              );
            },
          ),
          const Divider(color: Colors.white10, height: 24),
          _refundRow(
            customer: 'Amara Diallo',
            policy: '7-day cancellation policy',
            timeRemaining: '4 days remaining',
            color: const Color(0xFF22D3EE),
            amount: 'GHS 420.00',
            actionText: 'Process Refund',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Refund request initiated. Settlement scheduled instantly.')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _refundRow({
    required String customer,
    required String policy,
    required String timeRemaining,
    required Color color,
    required String amount,
    required String actionText,
    required VoidCallback onTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(customer, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(policy, style: const TextStyle(color: Color(0xFF64748B), fontSize: 10.5)),
            const SizedBox(height: 6),
            Text(amount, style: const TextStyle(color: Colors.white70, fontSize: 12.5, fontWeight: FontWeight.bold)),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
              child: Text(timeRemaining, style: TextStyle(color: color, fontSize: 9.5, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: color.withValues(alpha: 0.15),
                foregroundColor: color,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(actionText, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ],
    );
  }
"""

# Let's overwrite from Widget _buildInvoicingPayrollTab down to widget _buildPayrollRunnerCard
# We search for:
#   Widget _buildInvoicingPayrollTab(bool isDesktop) {
# Up to the start of TAB 4: TAX & PAN-AFRICAN COMPLIANCE HUB

start_tag = "  Widget _buildInvoicingPayrollTab(bool isDesktop) {"
end_tag = "  // ============================================================\n  // TAB 4: TAX & PAN-AFRICAN COMPLIANCE HUB"

start_idx = content.find(start_tag)
end_idx = content.find(end_tag)

if start_idx != -1 and end_idx != -1:
    content = content[:start_idx] + lifecycle_methods + "\n\n" + content[end_idx:]

with open(filepath, 'w') as f:
    f.write(content)

print("Dashboard payment lifecycle updates completed successfully.")
