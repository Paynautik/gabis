import 'package:flutter/material.dart';

import 'landing_ui.dart';

/// ============================================================================
/// RAILS STRIP — the networks money actually moves over.
/// Mirrors the "supported banks" band in the reference design.
/// ============================================================================
class RailsStripSection extends StatelessWidget {
  const RailsStripSection({super.key});

  static const _rails = [
    ('MTN MoMo', Icons.smartphone_rounded),
    ('Airtel Money', Icons.smartphone_rounded),
    ('M-Pesa', Icons.account_balance_wallet_rounded),
    ('Providus', Icons.account_balance_rounded),
    ('Lead Bank US', Icons.account_balance_rounded),
    ('ACH & Wire', Icons.swap_horiz_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 64 : 24,
        vertical: isDesktop ? 44 : 34,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            children: [
              const Text(
                'MOVES OVER THE RAILS YOU ALREADY USE',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.8,
                  color: LandingUi.inkSoft,
                ),
              ),
              const SizedBox(height: 24),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 14,
                runSpacing: 14,
                children: _rails
                    .map((r) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFAFBFC),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: LandingUi.border),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(r.$2, size: 16, color: LandingUi.inkSoft),
                              const SizedBox(width: 9),
                              Text(
                                r.$1,
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: LandingUi.ink,
                                ),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ============================================================================
/// CONTACT — ways to reach a human, plus a message form.
/// ============================================================================
class ContactSection extends StatefulWidget {
  const ContactSection({super.key});

  @override
  State<ContactSection> createState() => _ContactSectionState();
}

class _ContactSectionState extends State<ContactSection> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _message = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _message.dispose();
    super.dispose();
  }

  void _submit() {
    if (_name.text.trim().isEmpty || _email.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add your name and email so we can reply.')),
      );
      return;
    }
    setState(() => _sent = true);
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 950;

    return Container(
      width: double.infinity,
      color: LandingUi.canvas,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 64 : 24,
        vertical: isDesktop ? 72 : 48,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            children: [
              const SectionHeading(
                eyebrow: 'TALK TO US',
                title: 'Questions? Reach a real',
                circled: 'human',
                subtitle:
                    'Support is handled by people who understand African payments — not a script.',
                titleSize: 34,
              ),
              const SizedBox(height: 40),
              isDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 4, child: _channels()),
                        const SizedBox(width: 28),
                        Expanded(flex: 6, child: _form()),
                      ],
                    )
                  : Column(
                      children: [
                        _channels(),
                        const SizedBox(height: 20),
                        _form(),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _channels() {
    return Column(
      children: [
        _channel(Icons.chat_bubble_outline_rounded, 'Chat with us',
            'WhatsApp live chat, 8am – 8pm WAT'),
        const SizedBox(height: 12),
        _channel(Icons.mail_outline_rounded, 'Message us',
            'Use the form — we reply within one working day'),
        const SizedBox(height: 12),
        _channel(Icons.headset_mic_outlined, 'Call us', '+234 801 234 5678'),
      ],
    );
  }

  Widget _channel(IconData icon, String title, String detail) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: LandingUi.softCard(r: 18),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: LandingUi.accent.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, size: 20, color: LandingUi.accent),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14.5,
                        color: LandingUi.ink)),
                const SizedBox(height: 3),
                Text(detail,
                    style: const TextStyle(
                        fontSize: 12.5, color: LandingUi.inkSoft)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _form() {
    if (_sent) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: LandingUi.softCard(),
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded,
                  color: Color(0xFF059669), size: 26),
            ),
            const SizedBox(height: 16),
            const Text('Message noted',
                style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                    color: LandingUi.ink)),
            const SizedBox(height: 8),
            Text(
              'Thanks — we will get back to you within one working day.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 13, color: LandingUi.inkSoft, height: 1.5),
            ),
            const SizedBox(height: 18),
            TextButton(
              onPressed: () => setState(() => _sent = false),
              child: const Text('Write another'),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: LandingUi.softCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _field('Name', 'Your full name', _name),
          const SizedBox(height: 16),
          _field('Email', 'you@example.com', _email),
          const SizedBox(height: 16),
          _field('Message', 'How can we help?', _message, lines: 4),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _submit,
              style: FilledButton.styleFrom(
                backgroundColor: LandingUi.accent,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Send message',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(String label, String hint, TextEditingController c,
      {int lines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: LandingUi.ink)),
        const SizedBox(height: 7),
        TextField(
          controller: c,
          maxLines: lines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                const TextStyle(color: Color(0xFF9AA5B3), fontSize: 14),
            filled: true,
            fillColor: const Color(0xFFFAFBFC),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: LandingUi.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: LandingUi.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: LandingUi.accent, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
