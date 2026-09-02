import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/firebase/auth_service.dart';
import '../../core/theme/app_theme.dart';
import 'kyc_models.dart';
import 'kyc_store.dart';

/// Verification, and the naira account it unlocks.
class KycScreen extends ConsumerStatefulWidget {
  const KycScreen({super.key});

  @override
  ConsumerState<KycScreen> createState() => _KycScreenState();
}

class _KycScreenState extends ConsumerState<KycScreen> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _bvn = TextEditingController();
  DateTime? _dob;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _bvn.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _error = null);

    if (_name.text.trim().split(' ').length < 2) {
      setState(() => _error = 'Enter your full name as it appears on your BVN.');
      return;
    }
    if (_dob == null) {
      setState(() => _error = 'Choose your date of birth.');
      return;
    }
    if (_bvn.text.trim().length != 11) {
      setState(() => _error = 'A BVN is 11 digits.');
      return;
    }

    final failure = await ref.read(kycProvider.notifier).submitTier1(
          legalName: _name.text.trim(),
          phone: _phone.text.trim(),
          dateOfBirth: _dob!,
          bvn: _bvn.text.trim(),
        );

    if (!mounted) return;
    if (failure != null) {
      setState(() => _error = failure);
      return;
    }
    _bvn.clear(); // never held longer than the request
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Verified. You can open a naira account now.'),
      backgroundColor: Color(0xFF10B981),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final kyc = ref.watch(kycProvider);
    final notifier = ref.read(kycProvider.notifier);
    final profile = kyc.profile;

    return Scaffold(
      backgroundColor: context.colors.scaffoldBg,
      appBar: AppBar(
        title: const Text('Verify your identity'),
        backgroundColor: context.colors.scaffoldBg,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          if (!notifier.providerIsLive) const _SandboxNotice(),
          _StatusCard(profile: profile),
          const SizedBox(height: 22),

          if (profile.status != KycStatus.verified) ...[
            const _SectionTitle('Tier 1 — your details'),
            const SizedBox(height: 4),
            Text(
              'Checked against your BVN record at NIBSS. Your BVN is sent to the '
              'verification service and never stored here — we keep the last four '
              'digits so you know which one you used.',
              style: TextStyle(color: context.colors.inkSoft, fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 18),
            _field('Full name (as on your BVN)', 'e.g. Deji Adewusi', _name),
            const SizedBox(height: 14),
            _field('Phone number', 'e.g. +234 801 234 5678', _phone,
                keyboard: TextInputType.phone),
            const SizedBox(height: 14),
            _dobField(context),
            const SizedBox(height: 14),
            _field('BVN', '11 digits', _bvn,
                keyboard: TextInputType.number,
                formatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(11),
                ]),
            if (_error != null) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1EE),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFFD5CB)),
                ),
                child: Text(_error!,
                    style: const TextStyle(
                        color: Color(0xFFB3341C), fontSize: 13, height: 1.4)),
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: kyc.busy ? null : _submit,
                child: kyc.busy
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.4, color: Colors.white))
                    : const Text('Verify with BVN'),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Dial *565*0# on the phone tied to your bank account if you do not know your BVN.',
              style: TextStyle(color: context.colors.inkSoft, fontSize: 12),
            ),
          ],

          if (profile.canOpenNairaAccount) ...[
            const SizedBox(height: 8),
            const _SectionTitle('Your naira account'),
            const SizedBox(height: 12),
            if (kyc.account == null)
              _OpenAccountCard(busy: kyc.busy, onOpen: _openAccount)
            else
              _AccountCard(account: kyc.account!),
          ],

          const SizedBox(height: 28),
          const _SectionTitle('What each tier allows'),
          const SizedBox(height: 12),
          _limitsTable(context, profile.tier),
        ],
      ),
    );
  }

  Future<void> _openAccount() async {
    final email = ref.read(authServiceProvider).current?.email ?? '';
    final failure = await ref
        .read(kycProvider.notifier)
        .openNairaAccount(email: email, bvn: _bvn.text.trim());
    if (!mounted || failure == null) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(failure),
      backgroundColor: const Color(0xFFEF4444),
    ));
  }

  Widget _field(String label, String hint, TextEditingController controller,
      {TextInputType? keyboard, List<TextInputFormatter>? formatters}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
        const SizedBox(height: 7),
        TextField(
          controller: controller,
          keyboardType: keyboard,
          inputFormatters: formatters,
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }

  Widget _dobField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Date of birth',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
        const SizedBox(height: 7),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime(1995),
              firstDate: DateTime(1930),
              lastDate: DateTime.now().subtract(const Duration(days: 365 * 16)),
            );
            if (picked != null) setState(() => _dob = picked);
          },
          child: InputDecorator(
            decoration: const InputDecoration(),
            child: Text(
              _dob == null
                  ? 'Select your date of birth'
                  : '${_dob!.day.toString().padLeft(2, '0')}/'
                      '${_dob!.month.toString().padLeft(2, '0')}/${_dob!.year}',
              style: TextStyle(
                  color: _dob == null ? context.colors.inkSoft : context.colors.ink),
            ),
          ),
        ),
      ],
    );
  }

  Widget _limitsTable(BuildContext context, KycTier current) {
    Widget row(KycTier tier, String label, String needs) {
      final limits = TierLimits.of(tier);
      final active = tier == current;
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: active
              ? const Color(0xFFD9FF43).withValues(alpha: .25)
              : context.colors.bgSoft,
          border: Border(top: BorderSide(color: context.colors.border)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text(label,
                        style: const TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 14)),
                    if (active) ...[
                      const SizedBox(width: 8),
                      const Text('YOU',
                          style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1)),
                    ],
                  ]),
                  const SizedBox(height: 3),
                  Text(needs,
                      style: TextStyle(
                          color: context.colors.inkSoft, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 120,
              child: Text(
                limits.maxBalance == 0
                    ? 'No account'
                    : '₦${_thousands(limits.dailyTransfer)}/day',
                textAlign: TextAlign.right,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: [
        row(KycTier.none, 'Unverified', 'Look around only'),
        row(KycTier.tier1, 'Tier 1', 'BVN and phone'),
        row(KycTier.tier2, 'Tier 2', 'Government ID and a selfie'),
        row(KycTier.tier3, 'Tier 3', 'Proof of address'),
      ]),
    );
  }

  static String _thousands(int v) {
    final s = v.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

class _SandboxNotice extends StatelessWidget {
  const _SandboxNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFBF1DC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0A93B)),
      ),
      child: const Row(children: [
        Icon(Icons.warning_amber_rounded, size: 18, color: Color(0xFF9A6207)),
        SizedBox(width: 11),
        Expanded(
          child: Text(
            'Sandbox mode — no identity provider is connected, so nothing here is '
            'checked against a real record and any account number issued cannot '
            'receive money.',
            style: TextStyle(
                color: Color(0xFF7A4E06), fontSize: 12, height: 1.45,
                fontWeight: FontWeight.w600),
          ),
        ),
      ]),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final KycProfile profile;
  const _StatusCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    final (label, colour, detail) = switch (profile.status) {
      KycStatus.verified => (
          'Verified · ${profile.tier.name.replaceAll('tier', 'Tier ')}',
          const Color(0xFF10B981),
          'Your BVN ending ${profile.bvnLast4} was confirmed.'
        ),
      KycStatus.pending => (
          'Waiting on the provider',
          const Color(0xFF9A6207),
          'This usually takes a few minutes.'
        ),
      KycStatus.rejected => (
          'Not verified',
          const Color(0xFFD9432B),
          profile.rejectionReason ?? 'Check your details and try again.'
        ),
      KycStatus.inProgress => (
          'Checking…',
          const Color(0xFF4C45FF),
          'Confirming your details.'
        ),
      KycStatus.notStarted => (
          'Not verified yet',
          const Color(0xFF6B6660),
          'Verify to open a naira account and raise your limits.'
        ),
    };

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.colors.bgSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.border),
      ),
      child: Row(children: [
        Container(width: 10, height: 10,
            decoration: BoxDecoration(color: colour, shape: BoxShape.circle)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
              const SizedBox(height: 3),
              Text(detail,
                  style: TextStyle(color: context.colors.inkSoft, fontSize: 12.5)),
            ],
          ),
        ),
      ]),
    );
  }
}

class _OpenAccountCard extends StatelessWidget {
  final bool busy;
  final VoidCallback onOpen;

  const _OpenAccountCard({required this.busy, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.colors.bgSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Open a naira account',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
          const SizedBox(height: 6),
          Text(
            'A 10-digit NUBAN in your name that anyone in Nigeria can pay into.',
            style: TextStyle(color: context.colors.inkSoft, fontSize: 13),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: busy ? null : onOpen,
              child: const Text('Open account'),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  final NairaAccount account;
  const _AccountCard({required this.account});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF101010),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!account.live)
            Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFE0A93B),
                borderRadius: BorderRadius.circular(100),
              ),
              child: const Text('TEST ACCOUNT — CANNOT RECEIVE MONEY',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: .8,
                      color: Color(0xFF3B2703))),
            ),
          const Text('Account number',
              style: TextStyle(color: Color(0x99FFFFFF), fontSize: 12)),
          const SizedBox(height: 4),
          Row(children: [
            Text(account.accountNumber,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.4)),
            const SizedBox(width: 10),
            IconButton(
              icon: const Icon(Icons.copy_rounded, size: 17, color: Colors.white70),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: account.accountNumber));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Account number copied.')),
                );
              },
            ),
          ]),
          const SizedBox(height: 10),
          Text(account.accountName,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
          Text(account.bankName,
              style: const TextStyle(color: Color(0x99FFFFFF), fontSize: 12.5)),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -.5));
}
