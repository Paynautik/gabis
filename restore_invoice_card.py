filepath = "lib/features/business/business_dashboard_screen.dart"
with open(filepath, 'r') as f:
    content = f.read()

# Invoice assistant card definition to inject
invoice_card_code = """  Widget _buildInvoiceAssistantCard() {
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
              Icon(Icons.history_edu_rounded, color: Color(0xFF22D3EE), size: 20),
              SizedBox(width: 8),
              Text('AI Invoice Assistant', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Type a sentence to automatically draft a completed invoice using Elumo\'s semantic parser.',
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, height: 1.35),
          ),
          const SizedBox(height: 20),
          _buildDarkField(
            label: 'Voice / Text Invoice Description',
            hint: 'e.g. Create an invoice for ABC Technologies...',
            controller: _invoicePromptController,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: _isDraftingInvoice ? null : _draftInvoice,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isDraftingInvoice
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Draft Invoice via Gemini', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
            ),
          ),
          if (_draftedInvoice != null) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_draftedInvoice!['ref'] ?? '', style: const TextStyle(color: Color(0xFF22D3EE), fontWeight: FontWeight.bold, fontSize: 12)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(8)),
                        child: Text(_draftedInvoice!['status'] ?? '', style: const TextStyle(color: Colors.yellow, fontSize: 9.5, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(_draftedInvoice!['recipient'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(_draftedInvoice!['desc'] ?? '', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12.5)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_draftedInvoice!['amount'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 17)),
                      ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: const Color(0xFF0F172A),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                              title: const Text('Payment Link Active', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              content: const Text(
                                'Payment request link generated: elumo.to/pay/abc-49821. Reconcile matching bank statement triggers instantly.',
                                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13, height: 1.45),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Copy Link', style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Review & Send Link', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }"""

# Inject below _buildInvoicingPayrollTab
old_target = """  Widget _buildInvoicingPayrollTab(bool isDesktop) {
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
  }"""

new_target = old_target + "\n\n" + invoice_card_code

content = content.replace(old_target, new_target)

with open(filepath, 'w') as f:
    f.write(content)

print("Invoice assistant card restored successfully.")
