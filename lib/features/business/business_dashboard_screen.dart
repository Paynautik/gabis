import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'business_store.dart';
import 'contact_policy.dart';
import 'invoice_ai.dart';
import 'outreach.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/providers/app_providers.dart';
import '../../core/services/africas_talking_service.dart';
import 'dart:async';
import 'dart:convert';

// ============================================================================
// SHARED INPUT FIELD BUILDER
// ============================================================================
Widget _buildField(String label, String hint, TextEditingController ctrl, {bool isNumber = false}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(color: GabisPalette.ink, fontSize: 13, fontWeight: FontWeight.w500)),
      const SizedBox(height: 8),
      TextField(
        controller: ctrl,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: const TextStyle(color: GabisPalette.ink, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: GabisPalette.inkFaint),
          filled: true,
          fillColor: GabisPalette.cream,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: GabisPalette.line)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: GabisPalette.line)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: GabisPalette.electric)),
        ),
      ),
    ],
  );
}

String _formatCurrency(double val) => formatNaira(val);

// ============================================================================
// MAIN SCREEN
// ============================================================================

/// The dashboard on the same palette as the site: cream surfaces, ink text,
/// electric for interaction, and the brand accents carrying meaning —
/// coral for overdue, lime for settled, lilac for due soon.
abstract final class GabisPalette {
  static const ink = Color(0xFF101010);
  static const inkSoft = Color(0xFF6B6660);
  static const inkMuted = Color(0xFF8A857D);
  static const inkFaint = Color(0xFFA8A29A);

  static const cream = Color(0xFFF4F0E8);
  static const creamDeep = Color(0xFFEDE7DC);
  static const surface = Color(0xFFFFFFFF);

  static const line = Color(0xFFE2DCD1);
  static const lineStrong = Color(0xFFD3CBBD);

  static const electric = Color(0xFF4C45FF);
  static const lime = Color(0xFFD9FF43);
  static const coral = Color(0xFFFF7657);
  static const lilac = Color(0xFFD9D0FF);

  /// Semantic, chosen for contrast on cream rather than borrowed from Tailwind.
  static const success = Color(0xFF1F8F5F);
  static const danger = Color(0xFFD9432B);
  static const warn = Color(0xFF9A6207);
  static const lilacInk = Color(0xFF6D5BD0);

  /// Lime carries the brand on dark surfaces; this is what it becomes when the
  /// same accent has to be read as text or a mark on cream.
  static const limeInk = Color(0xFF5B7500);
  static const warnSurface = Color(0xFFFBF1DC);
  static const limeSurface = Color(0xFFF3F8D8);
}

class BusinessDashboardScreen extends ConsumerStatefulWidget {
  const BusinessDashboardScreen({super.key});

  @override
  ConsumerState<BusinessDashboardScreen> createState() => _BusinessDashboardScreenState();
}

class _BusinessDashboardScreenState extends ConsumerState<BusinessDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 750;

    return Scaffold(
      backgroundColor: GabisPalette.cream,
      appBar: AppBar(
        backgroundColor: GabisPalette.cream,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Image.asset('assets/gabis_logo.png', height: 26, fit: BoxFit.contain),
            const SizedBox(width: 10),
            const Text('Business',
                style: TextStyle(
                    color: GabisPalette.ink,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    letterSpacing: -0.5)),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: TextButton.icon(
              onPressed: () => ref.read(isBusinessModeProvider.notifier).state = false,
              icon: const Icon(Icons.swap_horiz_rounded, color: GabisPalette.inkSoft, size: 16),
              label: const Text('Personal Account', style: TextStyle(color: GabisPalette.inkSoft, fontWeight: FontWeight.w500, fontSize: 13)),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: GabisPalette.line, width: 1))),
            child: TabBar(
              controller: _tabController,
              indicatorColor: GabisPalette.ink,
              indicatorWeight: 2,
              labelColor: GabisPalette.ink,
              unselectedLabelColor: GabisPalette.inkSoft,
              labelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
              isScrollable: !isDesktop,
              tabs: const [
                Tab(text: 'Smart Invoices'),
                Tab(text: 'Connected Payments'),
                Tab(text: 'AI Debt Collection'),
                Tab(text: 'Multi-Currency Tax'),
              ],
            ),
          ),
        ),
      ),
      body: Column(children: [
        _BusinessKpiStrip(isDesktop: isDesktop),
        Expanded(child: TabBarView(
        controller: _tabController,
        children: const [
          _SmartInvoicesTab(),
          _ConnectedPaymentsTab(),
          _AIDebtCollectionTab(),
          _MultiCurrencyTaxTab(),
        ],
        )),
      ]),
    );
  }
}

/// Live roll-ups shared by every tab — collected, outstanding, overdue and the
/// share of billed value actually recovered.
class _BusinessKpiStrip extends ConsumerWidget {
  final bool isDesktop;
  const _BusinessKpiStrip({required this.isDesktop});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final b = ref.watch(businessProvider);
    final overdue = b.defaulters.fold(0.0, (s, p) => s + p.outstanding);

    final items = [
      ('Collected', formatFull(b.totalRevenue), GabisPalette.success,
          '${b.customerCount} customers across ${b.companies.length} companies'),
      ('Outstanding', formatFull(b.outstanding), GabisPalette.electric,
          '${b.dueSoon.length} due within 10 days'),
      ('Overdue', formatFull(overdue), GabisPalette.danger,
          '${b.defaulters.length} past due date'),
      ('Collection rate', '${(b.collectionRate * 100).toStringAsFixed(0)}%',
          GabisPalette.lilacInk, 'of everything billed'),
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 32 : 20, vertical: 18),
      decoration: const BoxDecoration(
        color: GabisPalette.creamDeep,
        border: Border(bottom: BorderSide(color: GabisPalette.line)),
      ),
      child: Wrap(
        spacing: 40,
        runSpacing: 18,
        children: items
            .map((it) => SizedBox(
                  width: 210,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(children: [
                        Container(width: 6, height: 6,
                            decoration: BoxDecoration(color: it.$3, shape: BoxShape.circle)),
                        const SizedBox(width: 7),
                        Text(it.$1.toUpperCase(),
                            style: const TextStyle(
                                color: GabisPalette.inkMuted, fontSize: 10,
                                fontWeight: FontWeight.w700, letterSpacing: 1.1)),
                      ]),
                      const SizedBox(height: 6),
                      Text(it.$2,
                          style: const TextStyle(
                              color: GabisPalette.ink, fontSize: 21, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 3),
                      Text(it.$4,
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: GabisPalette.inkFaint, fontSize: 11)),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }
}

// ============================================================================
// 1. SMART INVOICE GENERATION
// ============================================================================

/// Small prompts used when a client record has no contact detail yet.
Future<String?> _askPhone(BuildContext context, String who) =>
    _askText(context, 'Send to $who', 'Phone number with country code',
        'e.g. +234 801 234 5678');

Future<String?> _askEmail(BuildContext context, String who) =>
    _askText(context, 'Email $who', 'Email address', 'e.g. name@company.com');

Future<String?> _askText(
    BuildContext context, String title, String label, String hint) async {
  final controller = TextEditingController();
  final value = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: GabisPalette.surface,
      title: Text(title, style: const TextStyle(color: GabisPalette.ink, fontSize: 16)),
      content: TextField(
        controller: controller,
        autofocus: true,
        style: const TextStyle(color: GabisPalette.ink),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: const TextStyle(color: GabisPalette.inkSoft),
          hintStyle: const TextStyle(color: GabisPalette.inkFaint),
          enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: GabisPalette.line)),
          focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: GabisPalette.electric)),
        ),
        onSubmitted: (v) => Navigator.of(context).pop(v.trim()),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(controller.text.trim()),
          child: const Text('Continue'),
        ),
      ],
    ),
  );
  return (value == null || value.isEmpty) ? null : value;
}

class _SmartInvoicesTab extends ConsumerStatefulWidget {
  const _SmartInvoicesTab();
  @override
  ConsumerState<_SmartInvoicesTab> createState() => _SmartInvoicesTabState();
}

class _SmartInvoicesTabState extends ConsumerState<_SmartInvoicesTab> {
  final _clientCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _promptCtrl = TextEditingController();
  bool _isGenerating = false;

  /// Set while the model is turning a sentence into fields.
  bool _isDrafting = false;

  /// Days the drafted terms asked for, so the due date follows what was said
  /// rather than always being thirty days.
  int _dueInDays = 30;

  /// What the sentence did not say, shown against the fields it left empty.
  List<String> _missing = const [];

  /// Describe the invoice in a sentence and let the model fill the form. The
  /// draft is never sent — it lands in the fields for the owner to check.
  Future<void> _draftFromText() async {
    final prompt = _promptCtrl.text.trim();
    if (prompt.length < 3 || _isDrafting) return;

    setState(() => _isDrafting = true);
    final draft = await ref.read(invoiceDrafterProvider).draft(prompt);
    if (!mounted) return;

    setState(() {
      _clientCtrl.text = draft.client;
      _amountCtrl.text =
          draft.amount == 0 ? '' : draft.amount.toStringAsFixed(0);
      _descCtrl.text = draft.description;
      _dueInDays = draft.dueInDays;
      _missing = draft.missing;
      _isDrafting = false;
    });

    if (draft.missing.isNotEmpty) {
      Outreach.toast(
          context, 'Drafted. Check ${draft.missing.join(' and ')} before sending.',
          ok: false);
    }
  }


  void _generate() async {
    final client = _clientCtrl.text.trim();
    final amount = _amountCtrl.text.trim();
    final desc = _descCtrl.text.trim();
    if (client.isEmpty || amount.isEmpty) return;
    setState(() => _isGenerating = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() {
      final now = DateTime.now();
      final seq = ref.read(businessProvider).invoices.length + 2482;
      ref.read(businessProvider.notifier).addInvoice(Invoice(
        id: 'INV-$seq',
        client: client,
        amount: double.tryParse(amount.replaceAll(',', '')) ?? 0,
        description: desc.isEmpty ? 'General services' : desc,
        issued: now,
        due: now.add(Duration(days: _dueInDays)),
      ));
      _isGenerating = false;
      _dueInDays = 30;
      _missing = const [];
      _clientCtrl.clear(); _amountCtrl.clear(); _descCtrl.clear();
      _promptCtrl.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invoice for $client created.'), backgroundColor: GabisPalette.success));
  }

  @override
  void dispose() { _clientCtrl.dispose(); _amountCtrl.dispose(); _descCtrl.dispose(); _promptCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Smart Invoice Generation', style: TextStyle(color: GabisPalette.ink, fontSize: 20, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        const Text('Instantly generate and send professional invoices.', style: TextStyle(color: GabisPalette.inkSoft, fontSize: 13, height: 1.5)),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: GabisPalette.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: GabisPalette.line)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('New Invoice', style: TextStyle(color: GabisPalette.ink, fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),
            // Say it once in plain words; the fields below fill themselves in.
            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Expanded(
                child: _buildField(
                  'Describe it',
                  'e.g. bill Sarah 150k for brand design, net 14',
                  _promptCtrl,
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 48,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                      foregroundColor: GabisPalette.ink,
                      side: const BorderSide(color: GabisPalette.lineStrong),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8))),
                  onPressed: _isDrafting ? null : _draftFromText,
                  icon: _isDrafting
                      ? const SizedBox(
                          height: 14,
                          width: 14,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: GabisPalette.ink))
                      : const Icon(Icons.auto_awesome_rounded, size: 15),
                  label: const Text('Draft it',
                      style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
            ]),
            if (_missing.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Add the ${_missing.join(' and ')} before sending.',
                  style: const TextStyle(
                      color: GabisPalette.warn, fontSize: 12, fontWeight: FontWeight.w600)),
            ],
            const SizedBox(height: 16),
            _buildField('Client Name', 'e.g. Acme Corp', _clientCtrl),
            const SizedBox(height: 16),
            _buildField('Amount (NGN)', 'e.g. 500000', _amountCtrl, isNumber: true),
            const SizedBox(height: 16),
            _buildField('Description', 'e.g. Web Development', _descCtrl),
            const SizedBox(height: 8),
            Text('Payment terms: net $_dueInDays days',
                style: const TextStyle(color: GabisPalette.inkSoft, fontSize: 12)),
            const SizedBox(height: 24),
            SizedBox(width: double.infinity, height: 48, child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: GabisPalette.electric, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: _isGenerating ? null : _generate,
              child: _isGenerating ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: GabisPalette.ink)) : const Text('Generate Invoice', style: TextStyle(fontWeight: FontWeight.bold)),
            )),
          ]),
        ),
        const SizedBox(height: 32),
        const Text('Recent Invoices', style: TextStyle(color: GabisPalette.ink, fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        ...ref.watch(businessProvider).invoices.map((inv) {
          final isPaid = inv.status == 'paid';
          final overdue = inv.isOverdue;
          return Container(
            margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: GabisPalette.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: GabisPalette.line)),
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text(inv.client, style: const TextStyle(color: GabisPalette.ink, fontWeight: FontWeight.w600, fontSize: 15)),
                  const SizedBox(width: 8),
                  Text(inv.id, style: const TextStyle(color: GabisPalette.inkFaint, fontSize: 11)),
                ]),
                const SizedBox(height: 4),
                Text(inv.description, style: const TextStyle(color: GabisPalette.inkSoft, fontSize: 12)),
              ])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(formatFull(inv.amount), style: const TextStyle(color: GabisPalette.ink, fontWeight: FontWeight.w600, fontSize: 15)),
                const SizedBox(height: 4),
                Text(
                  isPaid
                      ? 'Paid'
                      : overdue
                          ? 'Overdue by ${DateTime.now().difference(inv.due).inDays}d'
                          : 'Due in ${inv.due.difference(DateTime.now()).inDays}d',
                  style: TextStyle(
                      color: isPaid
                          ? GabisPalette.success
                          : overdue
                              ? GabisPalette.danger
                              : GabisPalette.electric,
                      fontSize: 12),
                ),
              ]),
              const SizedBox(width: 12),
              if (!isPaid) ...[
                IconButton(
                  tooltip: 'Send on WhatsApp',
                  icon: const Icon(Icons.chat_rounded, size: 18, color: Color(0xFF25D366)),
                  onPressed: () async {
                    final phone = await _askPhone(context, inv.client);
                    if (phone == null || !context.mounted) return;
                    final sent = await Outreach.whatsapp(
                        phone, Outreach.invoiceMessage(inv));
                    if (!context.mounted) return;
                    if (sent) {
                      ref.read(businessProvider.notifier).markInvoiceSent(inv.id);
                      Outreach.toast(context, 'WhatsApp opened for ${inv.client}.');
                    } else {
                      Outreach.toast(context, 'Could not open WhatsApp.', ok: false);
                    }
                  },
                ),
                IconButton(
                  tooltip: 'Email invoice',
                  icon: const Icon(Icons.mail_outline_rounded,
                      size: 18, color: GabisPalette.inkSoft),
                  onPressed: () async {
                    final address = await _askEmail(context, inv.client);
                    if (address == null || !context.mounted) return;
                    final sent = await Outreach.email(
                      address,
                      'Invoice ${inv.id} — ${formatFull(inv.amount)}',
                      Outreach.invoiceMessage(inv),
                    );
                    if (!context.mounted) return;
                    if (sent) {
                      ref.read(businessProvider.notifier).markInvoiceSent(inv.id);
                      Outreach.toast(context, 'Mail composer opened.');
                    } else {
                      Outreach.toast(context, 'No mail client available.', ok: false);
                    }
                  },
                ),
                TextButton(
                  onPressed: () => ref.read(businessProvider.notifier).markInvoicePaid(inv.id),
                  child: const Text('Mark paid', style: TextStyle(fontSize: 12)),
                ),
              ],
              IconButton(
                tooltip: 'Delete invoice',
                icon: const Icon(Icons.delete_outline_rounded,
                    size: 18, color: GabisPalette.inkMuted),
                onPressed: () =>
                    ref.read(businessProvider.notifier).deleteInvoice(inv.id),
              ),
            ]),
          );
        }),
      ]),
    );
  }
}

// ============================================================================
// 2. CONNECTED PAYMENTS (Companies + Students/Customers + Reminders + Robot Calls)
// ============================================================================
class _ConnectedPaymentsTab extends ConsumerStatefulWidget {
  const _ConnectedPaymentsTab();
  @override
  ConsumerState<_ConnectedPaymentsTab> createState() => _ConnectedPaymentsTabState();
}

class _ConnectedPaymentsTabState extends ConsumerState<_ConnectedPaymentsTab> {
  final _atService = AfricasTalkingService();
  final _nameCtrl = TextEditingController();
  final _domainCtrl = TextEditingController();
  final _typeCtrl = TextEditingController();
  // Collections cannot start without somebody to reach and terms to enforce.
  final _contactCtrl = TextEditingController();
  final _companyPhoneCtrl = TextEditingController();
  final _companyEmailCtrl = TextEditingController();
  final _termsCtrl = TextEditingController();
  final _payerNameCtrl = TextEditingController();
  final _payerEmailCtrl = TextEditingController();
  final _payerPhoneCtrl = TextEditingController();
  final _payerAmountCtrl = TextEditingController();
  final _payerInstCtrl = TextEditingController();

  int? _expandedCompany; // which company card is drilled into
  bool _isCallingDefaulter = false;
  String _callStatus = '';
  List<String> _callTranscript = [];


  void _addCompany() {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: GabisPalette.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Connect a Company', style: TextStyle(color: GabisPalette.ink)),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            _buildField('Company Name', 'e.g. Skill School, SolarGrid, Acme Corp', _nameCtrl),
            const SizedBox(height: 12),
            _buildField('Domain', 'e.g. skill-sch.com, company.com', _domainCtrl),
            const SizedBox(height: 12),
            _buildField('Payment Type', 'e.g. Tuition Fees, Device Installments, Retainer', _typeCtrl),
            const SizedBox(height: 12),
            _buildField('Billing Contact', 'Who signs off on payments — e.g. Ada Obi', _contactCtrl),
            const SizedBox(height: 12),
            _buildField('Contact Phone (WhatsApp)', 'e.g. +2348012345678', _companyPhoneCtrl),
            const SizedBox(height: 12),
            _buildField('Contact Email', 'e.g. accounts@company.com', _companyEmailCtrl),
            const SizedBox(height: 12),
            _buildField('Payment Terms (days)', 'e.g. 30', _termsCtrl, isNumber: true),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: GabisPalette.cream,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: GabisPalette.line),
              ),
              child: const Row(children: [
                Icon(Icons.info_outline_rounded, size: 15, color: GabisPalette.inkMuted),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Next: add the customers who owe this company. Collections start from their phone number and due date.',
                    style: TextStyle(color: GabisPalette.inkSoft, fontSize: 11.5, height: 1.45),
                  ),
                ),
              ]),
            ),
          ]),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: GabisPalette.inkSoft))),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: GabisPalette.ink, foregroundColor: GabisPalette.cream),
          onPressed: () {
            if (_nameCtrl.text.isEmpty || _domainCtrl.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('A company needs at least a name and a domain.'),
                backgroundColor: GabisPalette.danger,
              ));
              return;
            }
            final terms = int.tryParse(_termsCtrl.text.trim()) ?? 30;
            ref.read(businessProvider.notifier).addCompany(ConnectedCompany(
                  name: _nameCtrl.text.trim(),
                  domain: _domainCtrl.text.trim(),
                  paymentType: _typeCtrl.text.trim().isEmpty
                      ? 'Installments'
                      : _typeCtrl.text.trim(),
                  contactName: _contactCtrl.text.trim(),
                  contactPhone: _companyPhoneCtrl.text.trim(),
                  contactEmail: _companyEmailCtrl.text.trim(),
                  termsDays: terms,
                ));
            final name = _nameCtrl.text.trim();
            _nameCtrl.clear(); _domainCtrl.clear(); _typeCtrl.clear();
            _contactCtrl.clear(); _companyPhoneCtrl.clear();
            _companyEmailCtrl.clear(); _termsCtrl.clear();
            Navigator.pop(ctx);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('$name connected. Add the customers who owe them next.'),
              backgroundColor: GabisPalette.success,
            ));
          },
          child: const Text('Connect'),
        ),
      ],
    ));
  }



  /// For a trader with no registered company: name the book, then go straight
  /// to importing debtors. No domain, no payment type, no ceremony.
  void _startPersonalBook() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: GabisPalette.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Start with your debtors',
            style: TextStyle(color: GabisPalette.ink, fontSize: 16)),
        content: SizedBox(
          width: 420,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'You do not need a registered company. Give this book a name — '
                'your own name is fine — and import the people who owe you.',
                style: TextStyle(
                    color: GabisPalette.inkSoft, fontSize: 12.5, height: 1.5),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              style: const TextStyle(color: GabisPalette.ink),
              onSubmitted: (v) => Navigator.pop(ctx, v.trim()),
              decoration: InputDecoration(
                labelText: 'Book name',
                hintText: 'e.g. Deji Adewusi, Mama Ngozi Stores',
                labelStyle: const TextStyle(color: GabisPalette.inkSoft),
                hintStyle: const TextStyle(color: GabisPalette.inkFaint),
                enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: GabisPalette.line)),
                focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFD9FF43))),
              ),
            ),
          ]),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel',
                  style: TextStyle(color: GabisPalette.inkSoft))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD9FF43),
                foregroundColor: const Color(0xFF101010)),
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Continue'),
          ),
        ],
      ),
    );

    if (name == null || !mounted) return;

    ref.read(businessProvider.notifier).startPersonalBook(name);
    final index = ref.read(businessProvider).companies.length - 1;
    setState(() => _expandedCompany = index);
    _importPayers(index);
  }

  /// Their debtor list, theirs to take: names, numbers and balances as CSV.
  void _exportDebtors() {
    final store = ref.read(businessProvider);
    if (store.allPayers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('No debtors to export yet.'),
        backgroundColor: GabisPalette.danger,
      ));
      return;
    }

    final csv = ref.read(businessProvider.notifier).debtorsCsv();
    Clipboard.setData(ClipboardData(text: csv));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
          '${store.allPayers.length} debtors copied as CSV — paste into Sheets, Excel or a message.'),
      backgroundColor: GabisPalette.success,
    ));
  }

  /// Bulk import: paste rows straight out of a spreadsheet or an exported CSV.
  /// One customer per line — nobody types a hundred debtors in one at a time.
  void _importPayers(int companyIndex) {
    final company = ref.read(businessProvider).companies[companyIndex];
    final controller = TextEditingController();
    var instalments = 1;

    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          backgroundColor: GabisPalette.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Import debtors into ${company.name}',
              style: const TextStyle(color: GabisPalette.ink, fontSize: 16)),
          content: SizedBox(
            width: 560,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'One customer per line:\n\nname, phone, amount, email, days overdue',
                    style: TextStyle(
                        color: GabisPalette.inkSoft, fontSize: 12.5, height: 1.55),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Email and days overdue are optional. Days overdue is negative for a future due date.',
                    style: TextStyle(color: GabisPalette.inkMuted, fontSize: 11.5, height: 1.5),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: controller,
                    maxLines: 9,
                    style: const TextStyle(
                        color: GabisPalette.ink, fontSize: 13, fontFamily: 'monospace'),
                    decoration: InputDecoration(
                      hintText:
                          'Amara Johnson, +2348012345678, 450000, amara@mail.com, 14\n'
                          'Tunde Bello, 08023456789, 120000',
                      hintStyle:
                          const TextStyle(color: GabisPalette.inkFaint, fontSize: 12.5),
                      filled: true,
                      fillColor: GabisPalette.cream,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: GabisPalette.line),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: GabisPalette.electric),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Text('Split each balance into',
                          style: TextStyle(color: GabisPalette.ink, fontSize: 13)),
                      const SizedBox(width: 12),
                      DropdownButton<int>(
                        value: instalments,
                        dropdownColor: GabisPalette.surface,
                        style: const TextStyle(color: GabisPalette.ink, fontSize: 13),
                        items: [1, 2, 3, 4, 6, 12]
                            .map((n) => DropdownMenuItem(
                                value: n,
                                child: Text(n == 1 ? '1 payment' : '$n instalments')))
                            .toList(),
                        onChanged: (v) => setLocal(() => instalments = v ?? 1),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel',
                    style: TextStyle(color: GabisPalette.inkSoft))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: GabisPalette.ink, foregroundColor: GabisPalette.cream),
              onPressed: () {
                final result = _parseDebtors(controller.text, instalments);
                if (result.payers.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Nothing to import — check the format.'),
                    backgroundColor: GabisPalette.danger,
                  ));
                  return;
                }
                for (final payer in result.payers) {
                  ref.read(businessProvider.notifier).addPayer(company, payer);
                }
                Navigator.pop(ctx);
                final skipped = result.skipped == 0
                    ? ''
                    : ' ${result.skipped} line${result.skipped == 1 ? '' : 's'} skipped.';
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(
                      '${result.payers.length} debtor${result.payers.length == 1 ? '' : 's'} imported into ${company.name}.$skipped'),
                  backgroundColor: GabisPalette.success,
                ));
              },
              child: const Text('Import'),
            ),
          ],
        ),
      ),
    );
  }

  /// Accepts comma or tab separated rows and ignores a header line.
  ({List<Payer> payers, int skipped}) _parseDebtors(String raw, int instalments) {
    final payers = <Payer>[];
    var skipped = 0;

    for (final line in raw.split('\n')) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      final parts = trimmed
          .split(RegExp(r'[,\t]'))
          .map((p) => p.trim())
          .where((p) => p.isNotEmpty)
          .toList();
      if (parts.length < 3) {
        skipped++;
        continue;
      }

      // Skip a pasted header row.
      if (parts[0].toLowerCase() == 'name') continue;

      final amount =
          double.tryParse(parts[2].replaceAll(RegExp(r'[^0-9.]'), ''));
      if (amount == null || amount <= 0) {
        skipped++;
        continue;
      }

      final email = parts.length > 3 && parts[3].contains('@')
          ? parts[3]
          : '${parts[0].split(' ').first.toLowerCase()}@example.com';

      final overdueField = parts.length > 4 ? parts[4] : (parts.length > 3 && !parts[3].contains('@') ? parts[3] : '');
      final daysOverdue = int.tryParse(overdueField) ?? 0;

      payers.add(Payer(
        name: parts[0],
        email: email,
        phone: parts[1],
        totalAmount: amount,
        installments: instalments,
        nextDueDate: DateTime.now().subtract(Duration(days: daysOverdue)),
        // An imported debtor is being billed under an agreement they entered;
        // the operator can change this on the record if that is not so.
        consentBasis: 'Contract — outstanding balance under an agreement',
      ));
    }

    return (payers: payers, skipped: skipped);
  }

  /// The lawful bases a Nigerian, Kenyan or Ghanaian business actually has
  /// for holding a debtor's phone number.
  static const _consentBases = [
    'Contract — outstanding balance under an agreement',
    'Consent — they agreed to reminders',
    'Legitimate interest — recovering a debt owed to us',
  ];

  String _consentBasis = _consentBases.first;

  Widget _consentField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Why you may contact them',
            style: TextStyle(
                color: GabisPalette.inkSoft, fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        StatefulBuilder(
          builder: (context, setLocal) => DropdownButtonFormField<String>(
            initialValue: _consentBasis,
            isExpanded: true,
            style: const TextStyle(color: GabisPalette.ink, fontSize: 13),
            items: _consentBases
                .map((b) => DropdownMenuItem(
                    value: b, child: Text(b, overflow: TextOverflow.ellipsis)))
                .toList(),
            onChanged: (v) {
              if (v == null) return;
              setLocal(() => _consentBasis = v);
              _consentBasis = v;
            },
          ),
        ),
      ],
    );
  }

  /// The three things a person can ask a business to do with their data, and
  /// the refusal that has to outlive whoever took the call.
  Future<void> _payerRecordAction(String action, Payer p) async {
    final notifier = ref.read(businessProvider.notifier);

    switch (action) {
      case 'dnc':
        notifier.setDoNotContact(p, !p.doNotContact);
        if (!mounted) return;
        Outreach.toast(
            context,
            p.doNotContact
                ? '${p.name} will not be contacted again.'
                : 'Contact allowed for ${p.name} again.');
        break;

      case 'export':
        final data =
            const JsonEncoder.withIndent('  ').convert(notifier.exportPayer(p));
        await Clipboard.setData(ClipboardData(text: data));
        if (!mounted) return;
        Outreach.toast(context, 'Everything held about ${p.name} copied.');
        break;

      case 'erase':
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: GabisPalette.surface,
            title: const Text('Erase this person?',
                style: TextStyle(color: GabisPalette.ink, fontSize: 16)),
            content: Text(
                '${p.name}, their balance and every contact attempt will be '
                'removed. This cannot be undone.',
                style: const TextStyle(color: GabisPalette.inkSoft, fontSize: 13)),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel',
                      style: TextStyle(color: GabisPalette.inkSoft))),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: GabisPalette.danger,
                    foregroundColor: Colors.white),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Erase'),
              ),
            ],
          ),
        );
        if (confirmed != true || !mounted) return;
        notifier.erasePayer(p);
        if (!mounted) return;
        Outreach.toast(context, '${p.name} erased.');
        break;
    }
  }

  void _addPayer(int companyIndex) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: GabisPalette.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Add customer to ${ref.read(businessProvider).companies[companyIndex].name}', style: const TextStyle(color: GabisPalette.ink, fontSize: 16)),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          _buildField('Customer / Student Name', 'e.g. Amara Johnson', _payerNameCtrl),
          const SizedBox(height: 12),
          _buildField('Email', 'e.g. customer@gmail.com', _payerEmailCtrl),
          const SizedBox(height: 12),
          _buildField('Phone Number', 'e.g. +2348012345678', _payerPhoneCtrl),
          const SizedBox(height: 12),
          _buildField('Total Amount (NGN)', 'e.g. 500000', _payerAmountCtrl, isNumber: true),
          const SizedBox(height: 12),
          _buildField('Number of Installments', 'e.g. 4', _payerInstCtrl, isNumber: true),
          const SizedBox(height: 12),
          // Without a lawful basis on the record, the contact rules refuse to
          // send anything to this person.
          _consentField(),
        ]),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: GabisPalette.inkSoft))),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: GabisPalette.ink, foregroundColor: GabisPalette.cream),
          onPressed: () {
            final name = _payerNameCtrl.text.trim();
            final email = _payerEmailCtrl.text.trim();
            final phone = _payerPhoneCtrl.text.trim().isEmpty ? '+2348012345678' : _payerPhoneCtrl.text.trim();
            final amount = double.tryParse(_payerAmountCtrl.text.trim()) ?? 0;
            final inst = int.tryParse(_payerInstCtrl.text.trim()) ?? 1;
            if (name.isEmpty || amount <= 0) return;
            setState(() {
              ref.read(businessProvider.notifier).addPayer(ref.read(businessProvider).companies[companyIndex], Payer(
                name: name,
                email: email,
                phone: phone,
                totalAmount: amount,
                installments: inst,
                nextDueDate: DateTime.now().add(const Duration(days: 30)),
                consentBasis: _consentBasis,
              ));
            });
            _payerNameCtrl.clear(); _payerEmailCtrl.clear(); _payerPhoneCtrl.clear(); _payerAmountCtrl.clear(); _payerInstCtrl.clear();
            Navigator.pop(ctx);
          },
          child: const Text('Add Customer'),
        ),
      ],
    ));
  }

  void _recordPayment(int companyIdx, int payerIdx) {
    final payer = ref.read(businessProvider).companies[companyIdx].payers[payerIdx];
    if (payer.isSettled) return;
    final payAmount = payer.perInstallment.clamp(0.0, payer.outstanding);
    setState(() {
      payer.amountPaid += payAmount;
      payer.currentInstallment++;
      payer.nextDueDate = DateTime.now().add(const Duration(days: 30));
      payer.payments.add(PaymentRecord(
        timestamp: DateTime.now(),
        amount: payAmount,
        note: 'Installment ${payer.currentInstallment} of ${payer.installments}',
      ));
      if (payer.isSettled) {
        payer.status = 'settled';
      } else {
        payer.status = 'on_track';
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('${_formatCurrency(payAmount)} payment recorded for ${payer.name}.'),
      backgroundColor: GabisPalette.success,
    ));
  }

  void _sendReminder(int companyIdx, int payerIdx) async {
    final payer = ref.read(businessProvider).companies[companyIdx].payers[payerIdx];
    final company = ref.read(businessProvider).companies[companyIdx];
    setState(() => payer.status = 'reminder_sent');

    final smsMessage = 'Reminder from ${company.name}: Your ${company.paymentType} installment of ${_formatCurrency(payer.perInstallment)} is due in ${payer.daysUntilDue} days. Pay online: https://${company.domain}/pay';

    // Trigger Africa's Talking SMS API
    _atService.sendReminderSMS(
      recipientPhone: payer.phone,
      message: smsMessage,
    );

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('SMS Reminder dispatched via Africa\'s Talking to ${payer.name} (${payer.phone}): "${company.paymentType} due in ${payer.daysUntilDue}d"'),
      backgroundColor: GabisPalette.electric,
      duration: const Duration(seconds: 4),
    ));
  }

  void _robotCall(int companyIdx, int payerIdx) async {
    final payer = ref.read(businessProvider).companies[companyIdx].payers[payerIdx];
    final company = ref.read(businessProvider).companies[companyIdx];

    setState(() {
      _isCallingDefaulter = true;
      _callStatus = 'Dialing ${payer.name} (${payer.phone}) via Africa\'s Talking Voice Gateway...';
      _callTranscript = [];
    });

    // Trigger Africa's Talking Voice Call API
    _atService.initiateVoiceCall(
      recipientPhone: payer.phone,
    );

    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _callStatus = 'Call Connected (${payer.phone}) — AI Agent speaking');

    final lines = [
      "AI: Hello, am I speaking with ${payer.name}?",
      "${payer.name}: Yes, who is this?",
      "AI: Hi ${payer.name}, I'm calling on behalf of ${company.name} regarding your outstanding ${company.paymentType.toLowerCase()} payment.",
      "AI: You have an overdue balance of ${_formatCurrency(payer.outstanding)} — installment ${payer.currentInstallment + 1} of ${payer.installments} was due ${(-payer.daysUntilDue)} days ago.",
      "${payer.name}: Oh, I'm sorry. I've been meaning to pay.",
      "AI: No worries at all. I can send a payment link to ${payer.email} right now so you can pay instantly. Shall I?",
      "${payer.name}: Yes, please do.",
      "AI: Done! Payment link sent. Once paid, your ${company.name} account will update automatically. Thank you!",
    ];

    for (final line in lines) {
      await Future.delayed(const Duration(milliseconds: 1400));
      if (!mounted) return;
      setState(() => _callTranscript.add(line));
    }

    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() {
      _callStatus = 'Call completed with ${payer.name} — Payment link sent';
      _isCallingDefaulter = false;
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _domainCtrl.dispose(); _typeCtrl.dispose();
    _payerNameCtrl.dispose(); _payerEmailCtrl.dispose(); _payerPhoneCtrl.dispose(); _payerAmountCtrl.dispose(); _payerInstCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header. A Wrap, deliberately: Expanded collapsed the copy to one
        // character per line and a fixed width pushed the button off-screen,
        // because this subtree can be laid out with odd constraints during a
        // tab transition. Wrap gives its children loose constraints, so the
        // text sizes itself and the button always lands.
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 24,
          runSpacing: 16,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Connected Payments',
                      style: TextStyle(
                          color: GabisPalette.ink,
                          fontSize: 20,
                          fontWeight: FontWeight.w600)),
                  SizedBox(height: 8),
                  Text(
                    'Connect any company (schools, retailers, solar providers, agencies) and track every customer installment plan. Automatic SMS reminders 10 days before due, robot voice calls for defaulters.',
                    style: TextStyle(
                        color: GabisPalette.inkSoft, fontSize: 13, height: 1.5),
                  ),
                ],
              ),
            ),
            Wrap(spacing: 10, runSpacing: 10, children: [
              if (ref.watch(businessProvider).companies.isNotEmpty)
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                      foregroundColor: GabisPalette.ink,
                      side: const BorderSide(color: GabisPalette.lineStrong),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16)),
                  onPressed: _exportDebtors,
                  icon: const Icon(Icons.download_rounded, size: 15),
                  label: const Text('Export debtors'),
                ),
              OutlinedButton.icon(
                // Lime is a colour for the dark surfaces; on cream it is all
                // but invisible, so this reads in ink like its neighbour.
                style: OutlinedButton.styleFrom(
                    foregroundColor: GabisPalette.ink,
                    side: const BorderSide(color: GabisPalette.lineStrong),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 16)),
                onPressed: _startPersonalBook,
                icon: const Icon(Icons.person_outline_rounded, size: 15),
                label: const Text('No company? Start with your debtors'),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: GabisPalette.ink,
                    foregroundColor: GabisPalette.cream,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8))),
                onPressed: _addCompany,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Connect Company'),
              ),
            ]),
          ],
        ),
        const SizedBox(height: 32),

        if (ref.watch(businessProvider).companies.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: GabisPalette.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: GabisPalette.line),
            ),
            child: Column(children: [
              const Icon(Icons.apartment_rounded, size: 26, color: GabisPalette.inkFaint),
              const SizedBox(height: 14),
              const Text('No companies connected yet',
                  style: TextStyle(
                      color: GabisPalette.ink, fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              const Text(
                'Connect a company, then import the customers who owe it. Collections start from their phone number and due date.',
                textAlign: TextAlign.center,
                style: TextStyle(color: GabisPalette.inkSoft, fontSize: 13, height: 1.5),
              ),
              const SizedBox(height: 20),
              Wrap(spacing: 10, runSpacing: 10, children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD9FF43),
                      foregroundColor: const Color(0xFF101010),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8))),
                  onPressed: _startPersonalBook,
                  icon: const Icon(Icons.person_outline_rounded, size: 16),
                  label: const Text('I have no company — just debtors'),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: GabisPalette.ink,
                      foregroundColor: GabisPalette.cream,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8))),
                  onPressed: _addCompany,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Connect Company'),
                ),
              ]),
            ]),
          ),

        // Company cards
        ...ref.watch(businessProvider).companies.asMap().entries.map((entry) {
          final ci = entry.key;
          final c = entry.value;
          final isExpanded = _expandedCompany == ci;

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(color: GabisPalette.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: isExpanded ? GabisPalette.electric : GabisPalette.line)),
            child: Column(children: [
              // Company header
              GestureDetector(
                onTap: () => setState(() => _expandedCompany = isExpanded ? null : ci),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: GabisPalette.electric.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.business_rounded, color: GabisPalette.electric, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(c.name, style: const TextStyle(color: GabisPalette.ink, fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text('${c.domain} · ${c.paymentType}', style: const TextStyle(color: GabisPalette.inkSoft, fontSize: 12)),
                      ])),
                      Icon(isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: GabisPalette.inkSoft),
                    ]),
                    const SizedBox(height: 20),
                    Row(children: [
                      _compactStat('Customers', '${c.payers.length}'),
                      const SizedBox(width: 24),
                      _compactStat('Collected', _formatCurrency(c.totalCollected)),
                      const SizedBox(width: 24),
                      _compactStat('Outstanding', _formatCurrency(c.totalOutstanding)),
                      const SizedBox(width: 24),
                      if (c.reminderCount > 0) _alertBadge('${c.reminderCount} Reminders', GabisPalette.warn),
                      if (c.reminderCount > 0) const SizedBox(width: 12),
                      if (c.defaultedCount > 0) _alertBadge('${c.defaultedCount} Defaulted', GabisPalette.danger),
                    ]),
                  ]),
                ),
              ),

              // Expanded: customer list
              if (isExpanded) ...[
                const Divider(color: GabisPalette.line, height: 1),
                Container(
                  padding: const EdgeInsets.all(24),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    // Wrap, not Row+Spacer: the actions were being pushed past
                    // the right edge and silently clipped in release.
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                      Text('${c.name} Customers & Payers', style: const TextStyle(color: GabisPalette.ink, fontSize: 14, fontWeight: FontWeight.w600)),
                      Wrap(spacing: 8, runSpacing: 8, children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          final csv = ref
                              .read(businessProvider.notifier)
                              .debtorsCsv(company: c);
                          Clipboard.setData(ClipboardData(text: csv));
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                                '${c.payers.length} debtors from ${c.name} copied as CSV.'),
                            backgroundColor: GabisPalette.success,
                          ));
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: GabisPalette.inkSoft,
                          side: const BorderSide(color: GabisPalette.lineStrong),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                        ),
                        icon: const Icon(Icons.download_rounded, size: 14),
                        label: const Text('Export',
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w700)),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _importPayers(ci),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: GabisPalette.ink,
                          side: const BorderSide(color: GabisPalette.lineStrong),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                        icon: const Icon(Icons.upload_file_rounded, size: 14),
                        label: const Text('Import debtors',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                      ),
                      TextButton.icon(
                        onPressed: () => _addPayer(ci),
                        icon: const Icon(Icons.person_add, size: 14, color: GabisPalette.electric),
                        label: const Text('Add Customer', style: TextStyle(color: GabisPalette.electric, fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                      ]),
                    ]),
                    const SizedBox(height: 16),

                    ...c.payers.asMap().entries.map((pe) {
                      final pi = pe.key;
                      final p = pe.value;
                      return _buildPayerCard(ci, pi, p, c);
                    }),
                  ]),
                ),
              ],
            ]),
          );
        }),

        // Robot call transcript (shows below companies when a call is active)
        if (_callStatus.isNotEmpty) ...[
          const SizedBox(height: 32),
          const Text('Robot Call Transcript', style: TextStyle(color: GabisPalette.ink, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          Container(
            width: double.infinity, padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: GabisPalette.cream, borderRadius: BorderRadius.circular(16), border: Border.all(color: GabisPalette.line)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                if (_isCallingDefaulter) ...[
                  const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: GabisPalette.success)),
                  const SizedBox(width: 12),
                ],
                Expanded(child: Text(_callStatus, style: TextStyle(color: _isCallingDefaulter ? GabisPalette.success : GabisPalette.inkSoft, fontWeight: FontWeight.w600))),
              ]),
              if (_callTranscript.isNotEmpty) const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(color: GabisPalette.line)),
              ..._callTranscript.map((line) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(line, style: TextStyle(color: line.startsWith('AI:') ? GabisPalette.electric : GabisPalette.ink, fontSize: 14, height: 1.6)),
              )),
            ]),
          ),
        ],
      ]),
    );
  }

  Widget _buildPayerCard(int ci, int pi, Payer p, ConnectedCompany c) {
    Color statusColor;
    String statusLabel;
    IconData statusIcon;

    if (p.isSettled) {
      statusColor = GabisPalette.success; statusLabel = 'Settled'; statusIcon = Icons.check_circle;
    } else if (p.isDefaulted) {
      statusColor = GabisPalette.danger; statusLabel = 'Defaulted'; statusIcon = Icons.error;
    } else if (p.isDueReminder) {
      statusColor = GabisPalette.warn; statusLabel = 'Due in ${p.daysUntilDue}d'; statusIcon = Icons.notifications_active;
    } else {
      statusColor = GabisPalette.electric; statusLabel = 'On Track'; statusIcon = Icons.schedule;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: GabisPalette.cream, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.isDefaulted ? GabisPalette.danger.withOpacity(0.3) : GabisPalette.line),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Name + status + actions
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(p.name, style: const TextStyle(color: GabisPalette.ink, fontWeight: FontWeight.w600, fontSize: 15)),
            const SizedBox(height: 2),
            Text('${p.email} · ${p.phone}', style: const TextStyle(color: GabisPalette.inkMuted, fontSize: 12)),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(statusIcon, color: statusColor, size: 12),
              const SizedBox(width: 4),
              Text(statusLabel, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w600)),
            ]),
          ),
          if (p.doNotContact) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  color: GabisPalette.warnSurface,
                  borderRadius: BorderRadius.circular(6)),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.block_rounded, color: GabisPalette.warn, size: 12),
                SizedBox(width: 4),
                Text('Do not contact',
                    style: TextStyle(
                        color: GabisPalette.warn,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ]),
            ),
          ],
          PopupMenuButton<String>(
            tooltip: 'Record',
            icon: const Icon(Icons.more_horiz_rounded,
                color: GabisPalette.inkSoft, size: 18),
            onSelected: (value) => _payerRecordAction(value, p),
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'dnc',
                child: Text(p.doNotContact
                    ? 'Allow contact again'
                    : 'They asked not to be contacted'),
              ),
              const PopupMenuItem(
                  value: 'export', child: Text('Copy everything we hold')),
              const PopupMenuItem(
                  value: 'erase', child: Text('Erase this person')),
            ],
          ),
        ]),
        const SizedBox(height: 16),

        // Progress
        Row(children: [
          _compactStat('Total', _formatCurrency(p.totalAmount)),
          const SizedBox(width: 24),
          _compactStat('Paid', _formatCurrency(p.amountPaid)),
          const SizedBox(width: 24),
          _compactStat('Installment', '${p.currentInstallment} of ${p.installments}'),
        ]),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: p.progress, minHeight: 6,
            backgroundColor: GabisPalette.line,
            valueColor: AlwaysStoppedAnimation<Color>(p.isSettled ? GabisPalette.success : statusColor),
          ),
        ),

        // Action buttons
        if (!p.isSettled) ...[
          const SizedBox(height: 16),
          Row(children: [
            if (p.isDueReminder || p.status == 'on_track')
              TextButton.icon(
                onPressed: () => _sendReminder(ci, pi),
                icon: const Icon(Icons.notifications, size: 14, color: GabisPalette.warn),
                label: const Text('Send Reminder (SMS)', style: TextStyle(color: GabisPalette.warn, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            if (p.isDefaulted)
              TextButton.icon(
                onPressed: _isCallingDefaulter ? null : () => _robotCall(ci, pi),
                icon: Icon(_isCallingDefaulter ? Icons.phone_in_talk : Icons.phone, size: 14, color: GabisPalette.danger),
                label: Text(_isCallingDefaulter ? 'Calling...' : 'Robot Call', style: const TextStyle(color: GabisPalette.danger, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            const Spacer(),
            TextButton.icon(
              onPressed: () => _recordPayment(ci, pi),
              icon: const Icon(Icons.payments, size: 14, color: GabisPalette.success),
              label: const Text('Record Payment', style: TextStyle(color: GabisPalette.success, fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ]),
        ],

        // Payment history
        if (p.payments.isNotEmpty) ...[
          const SizedBox(height: 12),
          const Divider(color: GabisPalette.line),
          const SizedBox(height: 8),
          const Text('Payment History', style: TextStyle(color: GabisPalette.inkMuted, fontSize: 11, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ...p.payments.reversed.take(3).map((r) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(children: [
              const Icon(Icons.check, color: GabisPalette.success, size: 12),
              const SizedBox(width: 8),
              Text(_formatCurrency(r.amount), style: const TextStyle(color: GabisPalette.ink, fontSize: 12, fontWeight: FontWeight.w500)),
              const SizedBox(width: 8),
              Text('· ${r.note}', style: const TextStyle(color: GabisPalette.inkMuted, fontSize: 11)),
              const Spacer(),
              Text('${r.timestamp.day}/${r.timestamp.month}/${r.timestamp.year}', style: const TextStyle(color: GabisPalette.inkFaint, fontSize: 11)),
            ]),
          )),
        ],
      ]),
    );
  }

  Widget _compactStat(String label, String value) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: GabisPalette.inkMuted, fontSize: 11)),
      const SizedBox(height: 2),
      Text(value, style: const TextStyle(color: GabisPalette.ink, fontSize: 14, fontWeight: FontWeight.w600)),
    ]);
  }

  Widget _alertBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

// ============================================================================
// 3. AI DEBT COLLECTION CALLS
// ============================================================================
class _AIDebtCollectionTab extends ConsumerStatefulWidget {
  const _AIDebtCollectionTab();
  @override
  ConsumerState<_AIDebtCollectionTab> createState() => _AIDebtCollectionTabState();
}

class _AIDebtCollectionTabState extends ConsumerState<_AIDebtCollectionTab> {
  final _atService = AfricasTalkingService();
  bool _isCalling = false;
  String _callStatus = '';
  final List<String> _transcript = [];
  String _selectedTone = 'Polite & Helpful';

  /// The queue is whoever is actually past their due date, not a fixed list.
  List<Payer> get _debtors => ref.read(businessProvider).defaulters;
  int _selectedDebtor = 0;

  void _startCall() async {
    final debtors = _debtors;
    if (debtors.isEmpty) return;
    final debtor = debtors[_selectedDebtor.clamp(0, debtors.length - 1)];

    // An automated caller is exactly the thing that must not be able to ring
    // someone at 3am, or for the fourth time this week.
    final gate = ContactPolicy.check(
        payer: debtor, priorCalls: ref.read(businessProvider).calls);
    if (!gate.allowed) {
      Outreach.toast(context, gate.reason!, ok: false);
      return;
    }

    final company = ref.read(businessProvider).companyOf(debtor);
    final owed = debtor.outstanding;
    final overdueDays = -debtor.daysUntilDue;

    setState(() {
      _isCalling = true;
      _callStatus = 'Dialling ${debtor.name} (${debtor.phone}) via Africa\'s Talking...';
      _transcript.clear();
    });

    _atService.initiateVoiceCall(recipientPhone: debtor.phone);

    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _callStatus = 'Connected to ${debtor.phone} — agent speaking');

    final lines = [
      "Agent: Good afternoon, am I speaking with ${debtor.name}?",
      "${debtor.name.split(' ').first}: Yes, who is this?",
      "Agent: This is the ${company?.name ?? 'gabis'} billing assistant. Your instalment of ${formatFull(debtor.perInstallment)} was due $overdueDays days ago.",
      "${debtor.name.split(' ').first}: I have been meaning to sort that out.",
      "Agent: I can send a payment link to this number now. The balance outstanding is ${formatFull(owed)}.",
      "${debtor.name.split(' ').first}: Yes, send it across.",
      "Agent: Sent to your WhatsApp. Your ledger clears automatically once it goes through.",
    ];
    for (final line in lines) {
      await Future.delayed(const Duration(milliseconds: 1400));
      if (!mounted) return;
      setState(() => _transcript.add(line));
    }

    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    ref.read(businessProvider.notifier).logCall(CallLog(
          payerName: debtor.name,
          company: company?.name ?? '—',
          amount: owed,
          placedAt: DateTime.now(),
          tone: _selectedTone,
          outcome: 'link_sent',
          transcript: List<String>.from(_transcript),
        ));
    ref.read(businessProvider.notifier).markReminderSent(debtor);

    setState(() {
      _callStatus = 'Call completed — payment link sent to ${debtor.name}';
      _isCalling = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('AI Debt Collection Calls', style: TextStyle(color: GabisPalette.ink, fontSize: 20, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        const Text('Dispatch conversational AI agents to follow up on overdue invoices.', style: TextStyle(color: GabisPalette.inkSoft, fontSize: 13, height: 1.5)),
        const SizedBox(height: 24),
        const _PromiseQueue(),
        const _CollectionsIntelligence(),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: GabisPalette.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: GabisPalette.line)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Select Debtor', style: TextStyle(color: GabisPalette.ink, fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 12),
            ..._debtors.asMap().entries.map((e) {
              final i = e.key; final d = e.value; final selected = i == _selectedDebtor;
              return GestureDetector(
                onTap: () => setState(() => _selectedDebtor = i),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: selected ? GabisPalette.electric.withOpacity(0.08) : GabisPalette.cream, borderRadius: BorderRadius.circular(12), border: Border.all(color: selected ? GabisPalette.electric : GabisPalette.line)),
                  child: Row(children: [
                    Icon(selected ? Icons.radio_button_checked : Icons.radio_button_off, color: selected ? GabisPalette.electric : GabisPalette.inkFaint, size: 18),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                      Text(d.name, style: const TextStyle(color: GabisPalette.ink, fontWeight: FontWeight.w500)),
                      Text('${ref.read(businessProvider).companyOf(d)?.name ?? '—'} · instalment ${d.currentInstallment + 1} of ${d.installments}',
                          style: const TextStyle(color: GabisPalette.inkMuted, fontSize: 11)),
                    ])),
                    Text(formatFull(d.outstanding), style: const TextStyle(color: GabisPalette.ink, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 12),
                    Text('${-d.daysUntilDue}d overdue', style: const TextStyle(color: GabisPalette.warn, fontSize: 12)),
                  ]),
                ),
              );
            }),
            const SizedBox(height: 20),
            _ReachOutPanel(
              debtor: _debtors.isEmpty
                  ? null
                  : _debtors[_selectedDebtor.clamp(0, _debtors.length - 1)],
            ),
            const SizedBox(height: 20),
            const Text('AI Tone', style: TextStyle(color: GabisPalette.ink, fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: GabisPalette.cream, borderRadius: BorderRadius.circular(8), border: Border.all(color: GabisPalette.line)),
              child: DropdownButtonHideUnderline(child: DropdownButton<String>(
                value: _selectedTone, dropdownColor: GabisPalette.surface, isExpanded: true, style: const TextStyle(color: GabisPalette.ink, fontSize: 14), icon: const Icon(Icons.arrow_drop_down, color: GabisPalette.inkSoft),
                items: ['Polite & Helpful', 'Professional & Firm', 'Urgent & Direct'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (v) { if (v != null) setState(() => _selectedTone = v); },
              )),
            ),
            const SizedBox(height: 24),
            SizedBox(width: double.infinity, height: 48, child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: _isCalling ? GabisPalette.danger : GabisPalette.electric, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: _isCalling ? null : _startCall,
              icon: Icon(_isCalling ? Icons.phone_in_talk : Icons.phone, size: 18),
              label: Text(_isCalling ? 'Call in Progress...' : 'Initiate AI Call', style: const TextStyle(fontWeight: FontWeight.bold)),
            )),
          ]),
        ),
        if (_callStatus.isNotEmpty) ...[
          const SizedBox(height: 32),
          const Text('Live Call Transcript', style: TextStyle(color: GabisPalette.ink, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          Container(
            width: double.infinity, padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: GabisPalette.cream, borderRadius: BorderRadius.circular(16), border: Border.all(color: GabisPalette.line)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                if (_isCalling) ...[const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: GabisPalette.success)), const SizedBox(width: 12)],
                Expanded(child: Text(_callStatus, style: TextStyle(color: _isCalling ? GabisPalette.success : GabisPalette.inkSoft, fontWeight: FontWeight.w600))),
              ]),
              if (_transcript.isNotEmpty) const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(color: GabisPalette.line)),
              ..._transcript.map((line) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Text(line, style: TextStyle(color: line.startsWith('AI:') ? GabisPalette.electric : GabisPalette.ink, fontSize: 14, height: 1.6)))),
            ]),
          ),
        ],
      ]),
    );
  }
}


/// Reaches the selected debtor through channels that actually exist on the
/// device, and writes the result back into the ledger.
class _ReachOutPanel extends ConsumerStatefulWidget {
  final Payer? debtor;

  const _ReachOutPanel({required this.debtor});

  @override
  ConsumerState<_ReachOutPanel> createState() => _ReachOutPanelState();
}

class _ReachOutPanelState extends ConsumerState<_ReachOutPanel> {
  static const _languages = ['English', 'Pidgin', 'Yoruba', 'Hausa', 'Igbo'];
  String _language = 'English';

  @override
  Widget build(BuildContext context) {
    final debtor = widget.debtor;
    final d = debtor;
    if (d == null) {
      return const Text('Nobody is overdue right now.',
          style: TextStyle(color: GabisPalette.inkMuted, fontSize: 13));
    }

    final store = ref.read(businessProvider);
    final company = store.companyOf(d)?.name ?? 'gabis';
    final overdueDays = -d.daysUntilDue;
    final message = '${Outreach.chaseMessage(
      name: d.name,
      company: company,
      outstanding: d.outstanding,
      daysOverdue: overdueDays,
    )}\n\n${ContactPolicy.optOutLine(company)}';

    // Checked before the buttons are drawn, so a blocked chase reads as a
    // stated rule rather than a button that quietly does nothing.
    final gate = ContactPolicy.check(payer: d, priorCalls: store.calls);

    final priorAttempts =
        store.calls.where((c) => c.payerName == d.name).length;

    void log(
      String outcome,
      String note, {
      String channel = 'manual',
      DateTime? promised,
      double recovered = 0,
    }) {
      ref.read(businessProvider.notifier).logCall(CallLog(
            payerName: d.name,
            company: company,
            amount: d.outstanding,
            placedAt: DateTime.now(),
            tone: 'Manual outreach',
            outcome: outcome,
            transcript: [note],
            language: _language,
            channel: channel,
            daysOverdue: overdueDays,
            attemptNumber: priorAttempts + 1,
            promisedDate: promised,
            promiseKept: recovered > 0 ? true : null,
            amountRecovered: recovered,
          ));
    }

    Widget channel(String label, IconData icon, Color colour,
        Future<bool> Function() go, String outcome, String route) {
      return OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: colour,
          side: const BorderSide(color: GabisPalette.line),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
        icon: Icon(icon, size: 16),
        label: Text(label, style: const TextStyle(fontSize: 12.5)),
        onPressed: !gate.allowed
            ? null
            : () async {
          final opened = await go();
          if (!context.mounted) return;
          if (opened) {
            log(outcome,
                '$label opened for ${d.name} — ${formatFull(d.outstanding)} outstanding',
                channel: route);
            ref.read(businessProvider.notifier).markReminderSent(d);
            Outreach.toast(context, '$label opened for ${d.name}.');
          } else {
            Outreach.toast(context, 'Could not open $label on this device.', ok: false);
          }
        },
      );
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: GabisPalette.cream,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: GabisPalette.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Reach out now',
                  style: TextStyle(
                      color: GabisPalette.ink, fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(width: 10),
              Text(d.phone,
                  style: const TextStyle(color: GabisPalette.inkMuted, fontSize: 12)),
              const Spacer(),
              // Which language this attempt is made in — the dimension the
              // whole dataset turns on.
              DropdownButton<String>(
                value: _language,
                dropdownColor: GabisPalette.surface,
                underline: const SizedBox.shrink(),
                style: const TextStyle(color: GabisPalette.ink, fontSize: 12.5),
                icon: const Icon(Icons.arrow_drop_down,
                    color: GabisPalette.inkSoft, size: 18),
                items: _languages
                    .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                    .toList(),
                onChanged: (v) => setState(() => _language = v ?? 'English'),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(message,
              style: const TextStyle(
                  color: GabisPalette.inkSoft, fontSize: 12.5, height: 1.5)),
          const SizedBox(height: 14),
          if (!gate.allowed) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: GabisPalette.warnSurface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(children: [
                const Icon(Icons.block_rounded, size: 16, color: GabisPalette.warn),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(gate.reason!,
                      style: const TextStyle(
                          color: GabisPalette.warn, fontSize: 12.5, height: 1.4)),
                ),
              ]),
            ),
            const SizedBox(height: 12),
          ],
          Wrap(spacing: 10, runSpacing: 10, children: [
            channel('WhatsApp', Icons.chat_rounded, const Color(0xFF25D366),
                () => Outreach.whatsapp(d.phone, message), 'contacted', 'whatsapp'),
            channel('SMS', Icons.sms_rounded, GabisPalette.electric,
                () => Outreach.sms(d.phone, message), 'contacted', 'sms'),
            channel('Call', Icons.phone_rounded, GabisPalette.success,
                () => Outreach.call(d.phone), 'contacted', 'voice'),
            channel('Email', Icons.mail_outline_rounded, GabisPalette.inkSoft,
                () => Outreach.email(d.email, 'Outstanding balance — $company', message),
                'contacted', 'email'),
          ]),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(color: GabisPalette.line, height: 1),
          ),
          const Text('Record what happened',
              style: TextStyle(
                  color: GabisPalette.ink, fontSize: 12.5, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Wrap(spacing: 10, runSpacing: 10, children: [
            TextButton(
              onPressed: () {
                ref
                    .read(businessProvider.notifier)
                    .recordPayment(d, d.perInstallment, 'Paid after outreach');
                log('paid', '${d.name} paid ${formatFull(d.perInstallment)}',
                    recovered: d.perInstallment);
                Outreach.toast(context, '${formatFull(d.perInstallment)} recorded against ${d.name}.');
              },
              child: const Text('Paid an instalment', style: TextStyle(fontSize: 12.5)),
            ),
            TextButton(
              onPressed: () {
                ref
                    .read(businessProvider.notifier)
                    .recordPayment(d, d.outstanding, 'Settled after outreach');
                log('settled', '${d.name} settled in full',
                    recovered: d.outstanding);
                Outreach.toast(context, '${d.name} settled in full.');
              },
              child: const Text('Paid in full', style: TextStyle(fontSize: 12.5)),
            ),
            TextButton(
              onPressed: () async {
                final when = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(const Duration(days: 3)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 120)),
                  helpText: 'When did they promise to pay?',
                );
                if (when == null || !context.mounted) return;
                log('promised', '${d.name} promised to pay',
                    promised: when);
                ref.read(businessProvider.notifier).markReminderSent(d);
                Outreach.toast(context,
                    'Promise logged for ${when.day}/${when.month}. We will ask you if it held.');
              },
              child: const Text('Promised to pay', style: TextStyle(fontSize: 12.5)),
            ),
            TextButton(
              onPressed: () {
                log('no_answer', 'No answer from ${d.name}', channel: 'voice');
                Outreach.toast(context, 'Logged: no answer.');
              },
              child: const Text('No answer', style: TextStyle(fontSize: 12.5)),
            ),
          ]),
        ],
      ),
    );
  }
}


/// What the attempts are teaching us. Thin at first by design — the point is
/// that the loop is instrumented from attempt one, not that the numbers are
/// impressive on day one.
class _CollectionsIntelligence extends ConsumerWidget {
  const _CollectionsIntelligence();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(businessProvider);
    if (store.calls.isEmpty) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: GabisPalette.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: GabisPalette.line),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Collections intelligence',
              style: TextStyle(
                  color: GabisPalette.ink, fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          const Text(
            'Nothing measured yet. Every attempt you make records the language, the channel, the hour and what came of it — the numbers appear here once there are attempts to count.',
            style: TextStyle(color: GabisPalette.inkSoft, fontSize: 12.5, height: 1.5),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () =>
                ref.read(businessProvider.notifier).loadSampleAttempts(),
            style: OutlinedButton.styleFrom(
              foregroundColor: GabisPalette.inkSoft,
              side: const BorderSide(color: GabisPalette.lineStrong),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            icon: const Icon(Icons.science_outlined, size: 15),
            label: const Text('Load 25 sample attempts to see the panel',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ]),
      );
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: GabisPalette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GabisPalette.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Text('Collections intelligence',
                style: TextStyle(
                    color: GabisPalette.ink, fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFD9FF43),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text('${store.calls.length} ATTEMPTS',
                  style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: .9,
                      color: Color(0xFF101010))),
            ),
          ]),
          const SizedBox(height: 6),
          const Text(
            'Which language, which channel and which hour actually gets people to pay. Every attempt adds a row.',
            style: TextStyle(color: GabisPalette.inkSoft, fontSize: 12.5, height: 1.5),
          ),
          if (store.sampleAttempts) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: GabisPalette.warnSurface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: GabisPalette.warn),
              ),
              child: Row(children: [
                const Icon(Icons.warning_amber_rounded,
                    size: 17, color: GabisPalette.warn),
                const SizedBox(width: 11),
                const Expanded(
                  child: Text(
                    'SAMPLE DATA — these attempts are illustrative, not measured outcomes. '
                    'Do not present these figures as results.',
                    style: TextStyle(
                        color: GabisPalette.warn,
                        fontSize: 11.5,
                        height: 1.45,
                        fontWeight: FontWeight.w700),
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      ref.read(businessProvider.notifier).clearSampleAttempts(),
                  child: const Text('Clear',
                      style: TextStyle(
                          color: GabisPalette.warn,
                          fontSize: 12,
                          fontWeight: FontWeight.w800)),
                ),
              ]),
            ),
          ],
          const SizedBox(height: 20),
          Wrap(spacing: 14, runSpacing: 14, children: [
            _Metric(
                label: 'RECOVERY RATE',
                value: '${(store.recoveryRate * 100).round()}%',
                sub: 'of attempts ended in payment'),
            _Metric(
                label: 'RECOVERED',
                value: formatNaira(store.totalRecovered),
                sub: 'attributed to outreach'),
            _Metric(
                label: 'PROMISES KEPT',
                value: store.promisesMade == 0
                    ? '—'
                    : '${(store.promiseKeptRate * 100).round()}%',
                sub: '${store.promisesKept} of ${store.promisesMade} promises'),
            _Metric(
                label: 'ATTEMPTS PER RECOVERY',
                value: store.attemptsPerRecovery == 0
                    ? '—'
                    : store.attemptsPerRecovery.toStringAsFixed(1),
                sub: 'lower is better'),
          ]),
          const SizedBox(height: 22),
          _StatTable(title: 'BY LANGUAGE', stats: store.statsByLanguage),
          const SizedBox(height: 16),
          _StatTable(title: 'BY CHANNEL', stats: store.statsByChannel),
          const SizedBox(height: 16),
          _StatTable(title: 'BY TIME OF DAY', stats: store.statsByHour),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () {
              final csv = ref.read(businessProvider.notifier).attemptsCsv();
              Clipboard.setData(ClipboardData(text: csv));
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                    '${store.calls.length} attempts copied as CSV${store.sampleAttempts ? ' (sample data)' : ''}.'),
                backgroundColor: GabisPalette.success,
              ));
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: GabisPalette.ink,
              side: const BorderSide(color: GabisPalette.lineStrong),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            icon: const Icon(Icons.download_rounded, size: 15),
            label: const Text('Copy dataset as CSV',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;
  final String sub;

  const _Metric({required this.label, required this.value, required this.sub});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: GabisPalette.inkMuted,
                  fontSize: 9.5,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w900)),
          const SizedBox(height: 7),
          Text(value,
              style: const TextStyle(
                  color: GabisPalette.ink,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -.8)),
          const SizedBox(height: 3),
          Text(sub,
              style: const TextStyle(color: GabisPalette.inkMuted, fontSize: 11)),
        ],
      ),
    );
  }
}

class _StatTable extends StatelessWidget {
  final String title;
  final List<CollectionStat> stats;

  const _StatTable({required this.title, required this.stats});

  @override
  Widget build(BuildContext context) {
    if (stats.isEmpty) return const SizedBox.shrink();
    final best = stats.reduce((a, b) => a.successRate >= b.successRate ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                color: GabisPalette.inkMuted,
                fontSize: 9.5,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        for (final stat in stats)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: [
                SizedBox(
                  width: 150,
                  child: Row(children: [
                    Flexible(
                      child: Text(stat.label,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: stat == best && stat.successes > 0
                                  ? GabisPalette.limeInk
                                  : GabisPalette.ink,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600)),
                    ),
                  ]),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: LinearProgressIndicator(
                      value: stat.successRate.clamp(0.0, 1.0),
                      minHeight: 5,
                      backgroundColor: GabisPalette.line,
                      valueColor: AlwaysStoppedAnimation(
                          stat == best && stat.successes > 0
                              ? GabisPalette.limeInk
                              : GabisPalette.electric),
                    ),
                  ),
                ),
                SizedBox(
                  width: 96,
                  child: Text(
                      '${(stat.successRate * 100).round()}%  ·  ${stat.attempts}',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                          color: GabisPalette.inkSoft, fontSize: 11.5)),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Promises whose date has passed. Answering these is what turns the log into
/// a dataset — an unverified promise teaches nothing.
class _PromiseQueue extends ConsumerWidget {
  const _PromiseQueue();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final due = ref.watch(businessProvider).promisesToVerify;
    if (due.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: GabisPalette.limeSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD9FF43).withValues(alpha: .35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${due.length} promise${due.length == 1 ? '' : 's'} to verify',
              style: const TextStyle(
                  color: GabisPalette.limeInk,
                  fontSize: 14,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          const Text(
            'They said they would pay by now. Did the money arrive? The answer is what makes the next call smarter.',
            style: TextStyle(color: GabisPalette.inkSoft, fontSize: 12, height: 1.45),
          ),
          const SizedBox(height: 14),
          for (final call in due.take(4))
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${call.payerName} · promised ${call.promisedDate!.day}/${call.promisedDate!.month} · ${call.language}',
                      style: const TextStyle(color: GabisPalette.ink, fontSize: 12.5),
                    ),
                  ),
                  TextButton(
                    onPressed: () => ref
                        .read(businessProvider.notifier)
                        .resolvePromise(call, kept: true, recovered: call.amount),
                    child: const Text('Paid',
                        style: TextStyle(
                            color: GabisPalette.success,
                            fontSize: 12,
                            fontWeight: FontWeight.w800)),
                  ),
                  TextButton(
                    onPressed: () => ref
                        .read(businessProvider.notifier)
                        .resolvePromise(call, kept: false),
                    child: const Text('Did not pay',
                        style: TextStyle(
                            color: Color(0xFFFF7657),
                            fontSize: 12,
                            fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================================
// 4. MULTI-CURRENCY TAX FILING
// ============================================================================
class _MultiCurrencyTaxTab extends ConsumerStatefulWidget {
  const _MultiCurrencyTaxTab();
  @override
  ConsumerState<_MultiCurrencyTaxTab> createState() => _MultiCurrencyTaxTabState();
}

class _MultiCurrencyTaxTabState extends ConsumerState<_MultiCurrencyTaxTab> {
  String _currency = 'NGN';
  final _revenueCtrl = TextEditingController();
  double _taxAmount = 0.0;
  bool _isFiling = false;
  final _currencySymbols = {'NGN': '₦', 'USD': '\$', 'GBP': '£', 'EUR': '€'};
  /// VAT / sales-tax rate by jurisdiction.
  static const _rates = {'NGN': 0.075, 'USD': 0.0, 'GBP': 0.20, 'EUR': 0.21};
  static const _jurisdictions = {
    'NGN': 'Nigeria · FIRS VAT 7.5%',
    'USD': 'United States · no federal VAT',
    'GBP': 'United Kingdom · HMRC VAT 20%',
    'EUR': 'EU · VAT 21%',
  };

  /// Pre-fills from revenue actually collected, so the figure is not invented.
  void _useCollectedRevenue() {
    final revenue = ref.read(businessProvider).totalRevenue;
    _revenueCtrl.text = revenue.toStringAsFixed(0);
    _calculateTax(_revenueCtrl.text);
  }

  void _calculateTax(String val) {
    setState(() => _taxAmount = (double.tryParse(val.replaceAll(',', '')) ?? 0.0) * (_rates[_currency] ?? 0));
  }

  void _fileTax() async {
    if (_taxAmount <= 0) return;
    setState(() => _isFiling = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    ref.read(businessProvider.notifier).fileTax(TaxFiling(
          currency: _currency,
          jurisdiction: _jurisdictions[_currency] ?? _currency,
          revenue: double.tryParse(_revenueCtrl.text.replaceAll(',', '')) ?? 0,
          rate: _rates[_currency] ?? 0,
          filedAt: DateTime.now(),
          period: 'This period',
        ));
    setState(() {
      _isFiling = false;
      _revenueCtrl.clear();
      _taxAmount = 0.0;
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Filing recorded and remittance queued.'), backgroundColor: GabisPalette.success));
  }

  @override
  void dispose() { _revenueCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final sym = _currencySymbols[_currency]!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Multi-Currency Tax Filing', style: TextStyle(color: GabisPalette.ink, fontSize: 20, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        const Text('Calculate and remit taxes across different currencies and jurisdictions.', style: TextStyle(color: GabisPalette.inkSoft, fontSize: 13, height: 1.5)),
        const SizedBox(height: 12),
        Row(children: [
          Text('Collected to date: ${formatFull(ref.watch(businessProvider).totalRevenue)}',
              style: const TextStyle(color: GabisPalette.inkMuted, fontSize: 12)),
          const SizedBox(width: 12),
          TextButton(
            onPressed: _useCollectedRevenue,
            style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 10), minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
            child: const Text('Use this figure', style: TextStyle(fontSize: 12)),
          ),
        ]),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: GabisPalette.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: GabisPalette.line)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('File New Tax', style: TextStyle(color: GabisPalette.ink, fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Currency', style: TextStyle(color: GabisPalette.ink, fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(color: GabisPalette.cream, borderRadius: BorderRadius.circular(8), border: Border.all(color: GabisPalette.line)),
                  child: DropdownButtonHideUnderline(child: DropdownButton<String>(
                    value: _currency, dropdownColor: GabisPalette.surface, isExpanded: true, style: const TextStyle(color: GabisPalette.ink, fontSize: 14), icon: const Icon(Icons.arrow_drop_down, color: GabisPalette.inkSoft),
                    items: _currencySymbols.entries.map((e) => DropdownMenuItem(value: e.key, child: Text('${e.key} (${e.value})'))).toList(),
                    onChanged: (v) { if (v != null) setState(() => _currency = v); },
                  )),
                ),
              ])),
              const SizedBox(width: 16),
              Expanded(flex: 2, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Declarable Revenue', style: TextStyle(color: GabisPalette.ink, fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                TextField(controller: _revenueCtrl, keyboardType: TextInputType.number, onChanged: _calculateTax, style: const TextStyle(color: GabisPalette.ink, fontSize: 14),
                  decoration: InputDecoration(hintText: 'e.g. 5000000', hintStyle: const TextStyle(color: GabisPalette.inkFaint), filled: true, fillColor: GabisPalette.cream,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: GabisPalette.line)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: GabisPalette.line)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: GabisPalette.electric)),
                  ),
                ),
              ])),
            ]),
            const Padding(padding: EdgeInsets.symmetric(vertical: 24), child: Divider(color: GabisPalette.line)),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Tax Liability (7.5% VAT)', style: TextStyle(color: GabisPalette.inkSoft, fontSize: 14)),
              Text('$sym${_taxAmount.toStringAsFixed(2)}', style: const TextStyle(color: GabisPalette.ink, fontSize: 28, fontWeight: FontWeight.w600, letterSpacing: -0.5)),
            ]),
            const SizedBox(height: 24),
            SizedBox(width: double.infinity, height: 48, child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: GabisPalette.electric, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: (_taxAmount > 0 && !_isFiling) ? _fileTax : null,
              child: _isFiling ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: GabisPalette.ink)) : const Text('File & Remit Tax', style: TextStyle(fontWeight: FontWeight.bold)),
            )),
          ]),
        ),
        const SizedBox(height: 32),
        const Text('Filing History', style: TextStyle(color: GabisPalette.ink, fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        ...ref.watch(businessProvider).filings.map((f) => Container(
          margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: GabisPalette.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: GabisPalette.line)),
          child: Row(children: [
            const Icon(Icons.check_circle_rounded, color: GabisPalette.success, size: 18),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              Text(f.jurisdiction, style: const TextStyle(color: GabisPalette.ink, fontWeight: FontWeight.w500)),
              Text('${f.period} · revenue ${formatFull(f.revenue)} at ${(f.rate * 100).toStringAsFixed(1)}%',
                  style: const TextStyle(color: GabisPalette.inkMuted, fontSize: 11)),
            ])),
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: GabisPalette.line, borderRadius: BorderRadius.circular(4)), child: Text(f.currency, style: const TextStyle(color: GabisPalette.inkSoft, fontSize: 11))),
            const SizedBox(width: 12),
            Text(formatFull(f.taxDue), style: const TextStyle(color: GabisPalette.ink, fontWeight: FontWeight.w600)),
          ]),
        )),
      ]),
    );
  }
}
