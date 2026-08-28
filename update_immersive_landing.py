filepath = "lib/features/landing/landing_screen.dart"
with open(filepath, 'r') as f:
    content = f.read()

# Let's completely rewrite landing_screen.dart with an ultra-premium, dark-themed, immersive AI OS landing page.
# It will have:
# - Premium dark gradients & electric cyan/green accents
# - Responsive navbar with brand wave logo
# - Hero section with smartphone Copilot mockup
# - NEW Interactive Product Feature Showcase (Virtual Card Freeze simulator, Wallets Exchange converter, Quick Bills purchase)
# - Unified B2B dashboard preview
# - Developer sandbox
# - Fintech trust badges and clear regulatory compliance footer

new_landing_code = """import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../shared/widgets/nautik_logo.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/providers/app_providers.dart';

// ============================================================
// BRAND COLOR PALETTE (PREMIUM DARK HYBRID)
// ============================================================
const Color brandNavy = Color(0xFF030712); // Obsidian Black
const Color brandSlate = Color(0xFF0F172A); // Dark Slate container
const Color brandGreen = Color(0xFF10B981); // Emerald Green accent
const Color brandCyan = Color(0xFF22D3EE); // Neon Cyan highlight
const Color brandBlue = Color(0xFF2563EB); // Royal Blue brand
const Color brandMuted = Color(0xFF94A3B8); // Muted grey text

// ============================================================
// LANDING SCREEN ENTRY
// ============================================================
class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 850;

    return Scaffold(
      backgroundColor: brandNavy,
      body: SingleChildScrollView(
        child: Column(
          children: const [
            Navbar(),
            HeroSection(),
            ProductShowcaseSection(),
            BusinessSection(),
            DeveloperSection(),
            TrustSection(),
            CTASection(),
            Footer(),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// NAVBAR
// ============================================================
class Navbar extends StatelessWidget {
  const Navbar({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final mobile = constraints.maxWidth < 850;

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: mobile ? 24 : 70,
            vertical: 20,
          ),
          color: brandNavy,
          child: Row(
            children: [
              Row(
                children: [
                  const NautikLogoMark(size: 34),
                  const SizedBox(width: 10),
                  const Text(
                    'ElumoPay',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.8,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              if (!mobile) ...[
                _navItem('Products'),
                _navItem('AI Intelligence'),
                _navItem('Developers'),
                _navItem('Company'),
                const SizedBox(width: 25),
              ],
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                child: const Text('Log in', style: TextStyle(color: brandCyan, fontWeight: FontWeight.w800)),
              ),
              const SizedBox(width: 10),
              FilledButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                style: FilledButton.styleFrom(
                  backgroundColor: brandGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Get started', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _navItem(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Text(
        title,
        style: const TextStyle(
          color: brandMuted,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ============================================================
// HERO
// ============================================================
class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: brandNavy,
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 80,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final mobile = constraints.maxWidth < 850;

              if (mobile) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _heroText(context),
                    const SizedBox(height: 50),
                    const BusinessCopilotTerminal(),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(
                    child: _heroText(context),
                  ),
                  const SizedBox(width: 60),
                  const Expanded(
                    child: BusinessCopilotTerminal(),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _heroText(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: brandGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: brandGreen.withValues(alpha: 0.25)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.auto_awesome_rounded, color: brandGreen, size: 12),
              SizedBox(width: 6),
              Text(
                'AI FINANCIAL OPERATING SYSTEM',
                style: TextStyle(
                  color: brandGreen,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 25),
        const Text(
          'Your business\\nhas the data.\\nElumo gives it\\nintelligence.',
          style: TextStyle(
            fontSize: 54,
            height: 1.05,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: -1.2,
          ),
        ),
        const SizedBox(height: 25),
        const Text(
          'ElumoPay turns fragmented payment activity into a unified, intelligent financial layer—helping businesses collect, reconcile, and predict cash flow automatically.',
          style: TextStyle(
            fontSize: 18,
            height: 1.6,
            color: brandMuted,
          ),
        ),
        const SizedBox(height: 35),
        Wrap(
          spacing: 15,
          runSpacing: 15,
          children: [
            FilledButton(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              style: FilledButton.styleFrom(
                backgroundColor: brandGreen,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 18,
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Get started', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.play_circle_outline_rounded, color: brandCyan, size: 18),
              label: const Text('Try Elumo Copilot', style: TextStyle(color: brandCyan, fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: brandCyan),
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 18,
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),
        Row(
          children: [
            Icon(
              Icons.verified_user_rounded,
              size: 18,
              color: brandGreen.withValues(alpha: 0.8),
            ),
            const SizedBox(width: 8),
            const Text(
              'NDIC Insured Partner Banks • CBN Licensed Remittances',
              style: TextStyle(
                color: brandMuted,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ============================================================
// INTERACTIVE PRODUCT SHOWCASE SECTION
// ============================================================
class ProductShowcaseSection extends StatefulWidget {
  const ProductShowcaseSection({super.key});

  @override
  State<ProductShowcaseSection> createState() => _ProductShowcaseSectionState();
}

class _ProductShowcaseSectionState extends State<ProductShowcaseSection> {
  String _activeTab = 'cards'; // options: 'cards', 'wallets', 'bills'
  
  // Card Tab state
  bool _isCardFrozen = false;
  
  // Wallet Tab state
  double _usdBalance = 2500.00;
  bool _isConverted = false;

  // Bills Tab state
  String _billCategory = 'Airtime';
  bool _isBillPaid = false;
  String _mockPhoneNumber = '';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: brandNavy,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            children: [
              // Section Heading
              Column(
                children: [
                  const Text(
                    'PRODUCT EXPERIENCE',
                    style: TextStyle(color: brandCyan, fontWeight: FontWeight.w800, letterSpacing: 2, fontSize: 11),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'Built for cash. Scaled with speed.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 16),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: const Text(
                      'Interact with Elumo\'s core consumer tools instantly. Tap the modules below to test our dynamic prototypes.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: brandMuted, fontSize: 15, height: 1.5),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // Segment Selectors
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _showcaseSelector('cards', Icons.credit_card_rounded, 'Virtual Cards'),
                  const SizedBox(width: 12),
                  _showcaseSelector('wallets', Icons.account_balance_wallet_rounded, 'Global Wallets'),
                  const SizedBox(width: 12),
                  _showcaseSelector('bills', Icons.bolt_rounded, 'Utility Bills'),
                ],
              ),
              const SizedBox(height: 35),

              // Active Showcase Area
              Container(
                width: double.infinity,
                height: 340,
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: brandSlate,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10)),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: _buildShowcaseInfo(),
                    ),
                    const VerticalDivider(color: Colors.white10, width: 40),
                    Expanded(
                      flex: 5,
                      child: Center(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: _buildShowcaseInteractiveArea(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _showcaseSelector(String tab, IconData icon, String title) {
    final isSelected = _activeTab == tab;
    return GestureDetector(
      onTap: () => setState(() => _activeTab = tab),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? brandGreen.withValues(alpha: 0.15) : brandSlate,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? brandGreen : Colors.white10),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? brandGreen : brandMuted, size: 16),
            const SizedBox(width: 8),
            Text(title, style: TextStyle(color: isSelected ? Colors.white : brandMuted, fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildShowcaseInfo() {
    if (_activeTab == 'cards') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('GLOBAL DEBIT CARDS', style: TextStyle(color: brandGreen, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.0)),
          const SizedBox(height: 8),
          const Text('Visa Platinum cards with instant freeze', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          const Text(
            'Create virtual cards for international shopping. Lock, unlock, and manage online spending limits instantly in real-time.',
            style: TextStyle(color: brandMuted, fontSize: 13, height: 1.45),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Text('Card Status:', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _isCardFrozen ? Colors.redAccent.withValues(alpha: 0.15) : brandGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _isCardFrozen ? 'FROZEN / LOCKED' : 'ACTIVE / SAFE',
                  style: TextStyle(color: _isCardFrozen ? Colors.redAccent : brandGreen, fontSize: 11, fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
        ],
      );
    } else if (_activeTab == 'wallets') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('MULTI-CURRENCY LEDGER', style: TextStyle(color: brandGreen, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.0)),
          const SizedBox(height: 8),
          const Text('Instant multi-currency exchange conversion', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          const Text(
            'Toggle between NGN, USD, GBP, and EUR. Perform swaps at competitive interbank FX rates with zero hidden markups.',
            style: TextStyle(color: brandMuted, fontSize: 13, height: 1.45),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Text('FX Rate:', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              Text('\$1.00 = ₦1,524.00', style: TextStyle(color: brandCyan, fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('UTILITY PAYMENTS', style: TextStyle(color: brandGreen, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.0)),
          const SizedBox(height: 8),
          const Text('Frictionless, instant bill settlements', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          const Text(
            'Settling bills should take seconds. Purchase data bundles, TV subscriptions, and power meters immediately.',
            style: TextStyle(color: brandMuted, fontSize: 13, height: 1.45),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Text('Processing Time:', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              const Text('Instant (2 seconds)', style: TextStyle(color: brandGreen, fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      );
    }
  }

  Widget _buildShowcaseInteractiveArea() {
    if (_activeTab == 'cards') {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Visual Card
          Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(-0.06)
              ..rotateZ(-0.02),
            alignment: Alignment.center,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 250,
              height: 150,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _isCardFrozen
                      ? [const Color(0xFF334155), const Color(0xFF1E293B)] // Grey frozen card
                      : [const Color(0xFF1E293B), const Color(0xFF090D16)], // Neon card
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isCardFrozen ? Colors.white.withValues(alpha: 0.1) : brandCyan.withValues(alpha: 0.25),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _isCardFrozen ? Colors.black.withValues(alpha: 0.3) : brandCyan.withValues(alpha: 0.15),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 24,
                        height: 18,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFFFFDF79), Color(0xFFC79224)]),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      Text(
                        _isCardFrozen ? 'FROZEN' : 'ELUMO',
                        style: TextStyle(color: _isCardFrozen ? Colors.white38 : Colors.white, fontSize: 9.5, fontWeight: FontWeight.w900, letterSpacing: 1.0),
                      ),
                    ],
                  ),
                  Text(
                    '•••• •••• •••• 4821',
                    style: TextStyle(
                      color: _isCardFrozen ? Colors.white30 : Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'RAPHAEL M.',
                        style: TextStyle(color: _isCardFrozen ? Colors.white30 : Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'VISA',
                        style: TextStyle(
                          color: _isCardFrozen ? Colors.white30 : Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Freeze Trigger
          ElevatedButton.icon(
            onPressed: () => setState(() => _isCardFrozen = !_isCardFrozen),
            style: ElevatedButton.styleFrom(
              backgroundColor: _isCardFrozen ? brandGreen : Colors.redAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: Icon(_isCardFrozen ? Icons.lock_open_rounded : Icons.lock_outline_rounded, size: 16),
            label: Text(_isCardFrozen ? 'Unlock Card' : 'Freeze Card', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      );
    } else if (_activeTab == 'wallets') {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 250,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: brandNavy,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('USD Wallet', style: TextStyle(color: brandMuted, fontSize: 12, fontWeight: FontWeight.bold)),
                    Container(
                      width: 24,
                      height: 16,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)]),
                      ),
                      child: const Center(child: Text('🇺🇸', style: TextStyle(fontSize: 10))),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('\$2,500.00', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                ),
                const Divider(color: Colors.white10, height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_isConverted ? 'Converted NGN' : 'Convert Value', style: const TextStyle(color: brandMuted, fontSize: 12, fontWeight: FontWeight.bold)),
                    const Icon(Icons.arrow_downward_rounded, color: brandGreen, size: 14),
                  ],
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _isConverted ? '₦3,810,000.00' : '₦0.00',
                    style: TextStyle(color: _isConverted ? brandGreen : Colors.white24, fontSize: 20, fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => setState(() => _isConverted = !_isConverted),
            style: ElevatedButton.styleFrom(
              backgroundColor: brandBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.swap_horiz_rounded, size: 16),
            label: Text(_isConverted ? 'Reset Wallet' : 'Convert to NGN', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 250,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: brandNavy,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: _isBillPaid
                ? const Column(
                    children: [
                      Icon(Icons.check_circle_rounded, color: brandGreen, size: 36),
                      SizedBox(height: 8),
                      Text('Top Up Successful', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                      SizedBox(height: 4),
                      Text('₦5,000.00 bundle credited.', style: TextStyle(color: brandMuted, fontSize: 12)),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Top Up MTN Airtime', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 12),
                      TextField(
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                        decoration: InputDecoration(
                          hintText: 'Enter phone number',
                          hintStyle: const TextStyle(color: Colors.white24, fontSize: 12),
                          filled: true,
                          fillColor: const Color(0xFF0F172A),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                        ),
                        onChanged: (val) => _mockPhoneNumber = val,
                      ),
                      const SizedBox(height: 12),
                      const Text('Amount: ₦5,000.00', style: TextStyle(color: brandCyan, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              if (_isBillPaid) {
                setState(() => _isBillPaid = false);
              } else {
                if (_mockPhoneNumber.isNotEmpty) {
                  setState(() => _isBillPaid = true);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter phone number.')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: brandGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: Icon(_isBillPaid ? Icons.refresh_rounded : Icons.bolt_rounded, size: 16),
            label: Text(_isBillPaid ? 'Buy Again' : 'Pay Bill Now', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      );
    }
  }
}

// ============================================================
// AFRICA SECTION (DEPRECATED IN FAVOR OF PRODUCT SHOWCASE)
// ============================================================

// ============================================================
// BUSINESS PREVIEW
// ============================================================
class BusinessSection extends StatelessWidget {
  const BusinessSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: brandNavy,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            children: [
              const Column(
                children: [
                  Text(
                    'ELUMOPAY BUSINESS',
                    style: TextStyle(color: brandCyan, fontWeight: FontWeight.w800, letterSpacing: 2, fontSize: 11),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'Reconcile, manage and understand your money.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 16),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Text(
                      'Automate collections and reconciliations from multiple payment channels. Stop manually reviewing accounts.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: brandMuted, fontSize: 15, height: 1.5),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 50),
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: brandSlate,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Text(
                          'ELUMOPAY BUSINESS SUITE',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                        Spacer(),
                        Icon(
                          Icons.more_horiz,
                          color: Colors.white54,
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    Wrap(
                      spacing: 15,
                      runSpacing: 15,
                      children: [
                        _metric('Total collected', '₦12.8M', '+18.4%'),
                        _metric('AI Reconciliations', '1,284 Done', '100% Health'),
                        _metric('Suggested Matches', '0 Pending', 'All cleared'),
                      ],
                    ),
                    const SizedBox(height: 40),
                    Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.03),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.show_chart_rounded,
                          size: 90,
                          color: brandCyan,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metric(String title, String value, String change) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: brandMuted,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            change,
            style: const TextStyle(
              color: brandGreen,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// DEVELOPER SECTION
// ============================================================
class DeveloperSection extends StatelessWidget {
  const DeveloperSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: brandNavy,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 80,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1150),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final mobile = constraints.maxWidth < 850;

              final text = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'FOR DEVELOPERS',
                    style: TextStyle(
                      color: brandCyan,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Payments without the payment headache.',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w950,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Build automated payment experiences and transaction reconciliation databases using clear, developer-friendly endpoints.',
                    style: TextStyle(
                      fontSize: 16,
                      color: brandMuted,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 30),
                  FilledButton(
                    onPressed: () {},
                    style: FilledButton.styleFrom(
                      backgroundColor: brandGreen,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Explore API', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              );

              final code = Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: brandSlate,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                ),
                child: const Text(
                  '''const payment =
    await elumo.payments.create({
  amount: 250000,
  currency: "NGN",
  customer: customerId
});

print(payment.status);''',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    height: 1.7,
                    fontFamily: 'monospace',
                  ),
                ),
              );

              if (mobile) {
                return Column(
                  children: [
                    text,
                    const SizedBox(height: 45),
                    code,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: text),
                  const SizedBox(width: 60),
                  Expanded(child: code),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// ============================================================
// TRUST SECTION
// ============================================================
class TrustSection extends StatelessWidget {
  const TrustSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Section(
      child: Column(
        children: [
          SectionHeading(
            eyebrow: 'TRUST LAYER',
            title: 'Built around security. Anchored in trust.',
            subtitle:
                'End-to-end security compliance, real-time transaction verification, and licensed payment operations.',
          ),
          SizedBox(height: 55),
          TrustCards(),
        ],
      ),
    );
  }
}

class TrustCards extends StatelessWidget {
  const TrustCards({super.key});

  @override
  Widget build(BuildContext context) {
    final cards = [
      (
        Icons.lock_outline,
        'Bank-Grade Security',
        '256-bit encryption and advanced tokenization protect user profiles.'
      ),
      (
        Icons.verified_outlined,
        'Licensed Partners',
        'Remittances routed via CBN-licensed payment partners.'
      ),
      (
        Icons.visibility_outlined,
        '100% Transparency',
        'Reconcile transaction details instantly with zero fee markup.'
      ),
      (
        Icons.public,
        'African Passport',
        'Tailored to accommodate local cellular, mobile money and banking structures.'
      ),
    ];

    return Wrap(
      spacing: 15,
      runSpacing: 15,
      children: cards.map((card) {
        return Container(
          width: 250,
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: brandSlate,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                card.$1,
                color: brandCyan,
                size: 30,
              ),
              const SizedBox(height: 20),
              Text(
                card.$2,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                card.$3,
                style: const TextStyle(
                  color: brandMuted,
                  height: 1.5,
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ============================================================
// CTA
// ============================================================
class CTASection extends StatelessWidget {
  const CTASection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: brandNavy,
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 80,
      ),
      child: Column(
        children: [
          const Text(
            'Africa is moving.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.w900,
            ),
          ),
          const Text(
            'Move with it.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 25),
          const Text(
            'Start building a simpler way to move and reconcile money.',
            style: TextStyle(
              color: brandMuted,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 35),
          FilledButton(
            onPressed: () {
              Navigator.pushNamed(context, '/login');
            },
            style: FilledButton.styleFrom(
              backgroundColor: brandGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 35,
                vertical: 19,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Create your account', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// FOOTER WITH COMPLIANCE BADGING
// ============================================================
class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF020617), // Deepest black footer
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          const Text(
            'ElumoPay',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'AI-Powered Financial Operating System for African Businesses.',
            style: TextStyle(
              color: brandMuted,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 24),
          
          // Formal fintech disclaimer matching hitchpay.ng compliance
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: const Text(
              'Disclaimer: Elumo is a financial technology platform, not a bank. Banking, virtual accounts, and payment services are provided by Elumo licensed Partner Banks, licensed by the Central Bank of Nigeria (CBN). Remittances and global settlements are routed via CBN-licensed International Money Transfer Operators (IMTOs). Client deposits are protected under the Nigeria Deposit Insurance Corporation (NDIC) framework.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF475569),
                fontSize: 10,
                height: 1.5,
              ),
            ),
          ),
          
          const SizedBox(height: 40),
          const Text(
            '© 2026 ElumoPay. All rights reserved.',
            style: TextStyle(
              color: Color(0xFF334155),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// REUSABLE SECTION
// ============================================================
class Section extends StatelessWidget {
  final Widget child;

  const Section({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 80,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 1150,
          ),
          child: child,
        ),
      ),
    );
  }
}

// ============================================================
// SECTION HEADING
// ============================================================
class SectionHeading extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String subtitle;

  const SectionHeading({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          eyebrow,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: brandCyan,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 15),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 36,
            height: 1.1,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 20),
        ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 700,
          ),
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: brandMuted,
              fontSize: 15,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// INTERACTIVE ELUMO BUSINESS COPILOT WIDGET
// ============================================================
class BusinessCopilotTerminal extends StatefulWidget {
  const BusinessCopilotTerminal({super.key});

  @override
  State<BusinessCopilotTerminal> createState() => _BusinessCopilotTerminalState();
}

class _BusinessCopilotTerminalState extends State<BusinessCopilotTerminal> {
  final List<Map<String, String>> _messages = [
    {
      'sender': 'ai',
      'text': 'Good morning, Raphael 👋\\nYour business received ₦12.8M this month (+18.4% vs July).\\n\\n💡 **Elumo Intelligence:** Collections are strong, but outstanding invoices grew by 31%. You have ₦640K in pending payments.'
    }
  ];
  bool _isThinking = false;

  void _askQuestion(String query, String response) async {
    if (_isThinking) return;
    setState(() {
      _messages.add({'sender': 'user', 'text': query});
      _isThinking = true;
    });

    await Future.delayed(const Duration(milliseconds: 1000));

    if (!mounted) return;
    setState(() {
      _isThinking = false;
      _messages.add({'sender': 'ai', 'text': response});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 320,
        height: 560,
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A), // Dark smartphone body bezel
          borderRadius: BorderRadius.circular(44),
          border: Border.all(color: const Color(0xFF334155), width: 10), // Solid hardware bezel
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2563EB).withValues(alpha: 0.25),
              blurRadius: 40,
              spreadRadius: 5,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(34), // Clip to screen boundaries
          child: Container(
            color: const Color(0xFF07111F), // Screen background
            child: Column(
              children: [
                // 1. Status Bar & Dynamic Island
                Container(
                  height: 32,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  color: const Color(0xFF07111F),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '09:41',
                        style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                      // Mock Dynamic Island
                      Container(
                        width: 70,
                        height: 15,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const Row(
                        children: [
                          Icon(Icons.signal_cellular_alt_rounded, color: Colors.white, size: 10),
                          SizedBox(width: 4),
                          Icon(Icons.wifi, color: Colors.white, size: 10),
                          SizedBox(width: 4),
                          Icon(Icons.battery_5_bar_rounded, color: Colors.white, size: 10),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // 2. Terminal Header / App bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.06))),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'ELUMO COPILOT',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.psychology_rounded, color: Color(0xFF22D3EE), size: 14),
                    ],
                  ),
                ),
                
                // 3. Chat Messages logs
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, idx) {
                      final msg = _messages[idx];
                      final isAi = msg['sender'] == 'ai';
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: isAi ? const Color(0xFF2563EB) : Colors.white24,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isAi ? Icons.psychology_rounded : Icons.person_rounded,
                                color: Colors.white,
                                size: 11,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isAi ? Colors.white.withValues(alpha: 0.04) : Colors.white.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isAi ? Colors.white.withValues(alpha: 0.06) : Colors.white.withValues(alpha: 0.12),
                                  ),
                                ),
                                child: Text(
                                  msg['text'] ?? '',
                                  style: TextStyle(
                                    color: isAi ? const Color(0xFFE2E8F0) : Colors.white,
                                    fontSize: 11.5,
                                    height: 1.45,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                if (_isThinking)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 10,
                          height: 10,
                          child: CircularProgressIndicator(strokeWidth: 1.0, color: Color(0xFF2563EB)),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Thinking...',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 10, fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),

                // 4. Copilot Prompt Choices
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.02),
                    border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.06))),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ASK ELUMO:',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 8.5, fontWeight: FontWeight.bold, letterSpacing: 0.8),
                      ),
                      const SizedBox(height: 6),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _queryChip(
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
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // 5. Home Swipe Indicator
                Container(
                  width: 100,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _queryChip({required String label, required String query, required String response}) {
    return ActionChip(
      backgroundColor: const Color(0xFF1E293B),
      side: const BorderSide(color: Color(0xFF334155)),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      label: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF22D3EE),
          fontSize: 10.5,
          fontWeight: FontWeight.bold,
        ),
      ),
      onPressed: () => _askQuestion(query, response),
    );
  }
}
"""

with open(filepath, 'w') as f:
    f.write(new_landing_code)

print("Immersive landing page rewrite complete.")
