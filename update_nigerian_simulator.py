filepath = "lib/features/landing/landing_screen.dart"
with open(filepath, 'r') as f:
    content = f.read()

# Locate the _BusinessSectionState build method and replace it with a highly detailed, realistic, Nigerian-branded interface!
old_simulator_code = """                    // Invoice Panel
                    Expanded(
                      flex: mobile ? 0 : 4,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: brandSlate,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('INV-1024', style: TextStyle(color: brandCyan, fontWeight: FontWeight.bold, fontSize: 12)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _isReconciled ? brandGreen.withValues(alpha: 0.1) : Colors.amber.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _isReconciled ? 'PAID' : 'UNPAID',
                                    style: TextStyle(color: _isReconciled ? brandGreen : Colors.amber, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Text('Sarah Jenkins', style: TextStyle(color: brandText, fontWeight: FontWeight.bold, fontSize: 15)),
                            const Text('Logo Design & Brand Identity', style: TextStyle(color: brandMuted, fontSize: 12)),
                            const SizedBox(height: 20),
                            const Text('₦150,000.00', style: TextStyle(color: brandText, fontWeight: FontWeight.w900, fontSize: 18)),
                          ],
                        ),
                      ),
                    ),
                    
                    // Match Connector
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _isReconciled ? Icons.verified_user_rounded : Icons.psychology_rounded,
                            color: _isReconciled ? brandGreen : brandCyan,
                            size: 32,
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: brandSlate, borderRadius: BorderRadius.circular(10)),
                            child: Text(
                              _isReconciled ? '100% Match Link' : '98% Match Suggestion',
                              style: TextStyle(color: _isReconciled ? brandGreen : brandCyan, fontSize: 9.5, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Bank Statement Feed
                    Expanded(
                      flex: mobile ? 0 : 4,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: brandSlate,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('BANK FEED (Z-12)', style: TextStyle(color: brandMuted, fontWeight: FontWeight.bold, fontSize: 12)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _isReconciled ? brandGreen.withValues(alpha: 0.1) : Colors.amber.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _isReconciled ? 'LINKED' : 'UNMATCHED',
                                    style: TextStyle(color: _isReconciled ? brandGreen : Colors.amber, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Text('S. JENKINS TRANSFER', style: TextStyle(color: brandText, fontWeight: FontWeight.bold, fontSize: 15)),
                            const Text('Ref: FT/2026/08/982103', style: TextStyle(color: brandMuted, fontSize: 12)),
                            const SizedBox(height: 20),
                            const Text('₦150,000.00', style: TextStyle(color: brandText, fontWeight: FontWeight.w900, fontSize: 18)),
                          ],
                        ),
                      ),
                    ),"""

new_simulator_code = """                    // Invoice Panel (Funke Adebayo, Adebayo Retail)
                    Expanded(
                      flex: mobile ? 0 : 5,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: _isReconciled ? const Color(0xFFECFDF5) : brandSlate,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: _isReconciled ? brandGreen : Colors.black.withValues(alpha: 0.08),
                            width: _isReconciled ? 2.0 : 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _isReconciled ? brandGreen.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.02),
                              blurRadius: 16,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.receipt_long_rounded, color: brandCyan, size: 16),
                                    const SizedBox(width: 6),
                                    Text(
                                      'INV-1024',
                                      style: TextStyle(color: _isReconciled ? const Color(0xFF065F46) : brandText, fontWeight: FontWeight.w800, fontSize: 12.5),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: _isReconciled ? brandGreen : Colors.amber.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _isReconciled ? 'PAID' : 'UNPAID',
                                    style: TextStyle(color: _isReconciled ? Colors.white : Colors.amber.shade800, fontSize: 9.5, fontWeight: FontWeight.black),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(color: Colors.black12, height: 24),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(color: Color(0xFFE6F7F0), shape: BoxShape.circle),
                                  child: const Icon(Icons.storefront_rounded, color: brandGreen, size: 16),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Funke Adebayo', style: TextStyle(color: brandText, fontWeight: FontWeight.black, fontSize: 14.5)),
                                    Text('Adebayo Retail • Lagos, NG', style: TextStyle(color: _isReconciled ? const Color(0xFF047857) : brandMuted, fontSize: 11, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Text('1x Wholesale Flour Bags (Premium)', style: TextStyle(color: brandMuted, fontSize: 11.5, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 16),
                            Text(
                              '₦150,000.00',
                              style: TextStyle(color: _isReconciled ? const Color(0xFF065F46) : brandText, fontWeight: FontWeight.w900, fontSize: 20),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Match Connector Hub
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _isReconciled ? Icons.link_rounded : Icons.link_off_rounded,
                            color: _isReconciled ? brandGreen : brandCyan,
                            size: 34,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: _isReconciled ? brandGreen.withValues(alpha: 0.15) : brandCyan.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  _isReconciled ? '100% LINKED' : '98% SUGGESTION',
                                  style: TextStyle(color: _isReconciled ? brandGreen : brandCyan, fontSize: 9, fontWeight: FontWeight.black, letterSpacing: 0.5),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _isReconciled ? 'Verified' : 'Gemini Auto-Match',
                                  style: TextStyle(color: _isReconciled ? brandGreen : brandMuted, fontSize: 7.5, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Bank Statement Feed (Access Bank Plc, F. ADEBAYO TRANSFER)
                    Expanded(
                      flex: mobile ? 0 : 5,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: _isReconciled ? const Color(0xFFECFDF5) : brandSlate,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: _isReconciled ? brandGreen : Colors.black.withValues(alpha: 0.08),
                            width: _isReconciled ? 2.0 : 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _isReconciled ? brandGreen.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.02),
                              blurRadius: 16,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.account_balance_rounded, color: Colors.deepOrangeAccent, size: 16),
                                    const SizedBox(width: 6),
                                    Text(
                                      'BANK STATEMENT',
                                      style: TextStyle(color: _isReconciled ? const Color(0xFF065F46) : brandText, fontWeight: FontWeight.w800, fontSize: 11.5),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: _isReconciled ? brandGreen : Colors.amber.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _isReconciled ? 'RECONCILED' : 'UNMATCHED',
                                    style: TextStyle(color: _isReconciled ? Colors.white : Colors.amber.shade800, fontSize: 9.5, fontWeight: FontWeight.black),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(color: Colors.black12, height: 24),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(color: Colors.deepOrange.withValues(alpha: 0.1), shape: BoxShape.circle),
                                  child: const Icon(Icons.payments_rounded, color: Colors.deepOrange, size: 16),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('F. ADEBAYO TRANSFER', style: TextStyle(color: brandText, fontWeight: FontWeight.black, fontSize: 14.5)),
                                    Text('Access Bank • NIP Instant Transfer', style: TextStyle(color: _isReconciled ? const Color(0xFF047857) : brandMuted, fontSize: 11, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Text('Ref: AC-TX-890241B • Aug 28, 2026', style: TextStyle(color: brandMuted, fontSize: 11.5, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 16),
                            Text(
                              '₦150,000.00',
                              style: TextStyle(color: _isReconciled ? const Color(0xFF065F46) : brandText, fontWeight: FontWeight.w900, fontSize: 20),
                            ),
                          ],
                        ),
                      ),
                    ),"""

content = content.replace(old_simulator_code, new_simulator_code)

with open(filepath, 'w') as f:
    f.write(content)

print("Branded simulator update applied successfully.")
