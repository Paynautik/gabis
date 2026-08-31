import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/providers/app_providers.dart';
import '../../core/services/africas_talking_service.dart';
import 'dart:async';

// ============================================================================
// DATA MODELS
// ============================================================================
class PaymentRecord {
  final DateTime timestamp;
  final double amount;
  final String note;
  PaymentRecord({required this.timestamp, required this.amount, required this.note});
}

class Payer {
  String name;
  String email;
  String phone;
  double totalAmount;
  double amountPaid;
  int installments;
  int currentInstallment;
  DateTime nextDueDate;
  String status; // 'on_track', 'reminder_sent', 'defaulted', 'settled'
  List<PaymentRecord> payments;

  Payer({
    required this.name,
    required this.email,
    this.phone = '+2348012345678',
    required this.totalAmount,
    this.amountPaid = 0.0,
    required this.installments,
    this.currentInstallment = 0,
    required this.nextDueDate,
    this.status = 'on_track',
    List<PaymentRecord>? payments,
  }) : payments = payments ?? [];

  double get perInstallment => totalAmount / installments;
  double get progress => totalAmount > 0 ? (amountPaid / totalAmount).clamp(0.0, 1.0) : 0.0;
  double get outstanding => totalAmount - amountPaid;
  bool get isSettled => amountPaid >= totalAmount;
  int get daysUntilDue => nextDueDate.difference(DateTime.now()).inDays;
  bool get isDueReminder => daysUntilDue <= 10 && daysUntilDue > 0 && !isSettled;
  bool get isDefaulted => daysUntilDue < 0 && !isSettled;
}

class ConnectedCompany {
  String name;
  String domain;
  String paymentType;
  List<Payer> payers;

  ConnectedCompany({
    required this.name,
    required this.domain,
    required this.paymentType,
    List<Payer>? payers,
  }) : payers = payers ?? [];

  double get totalCollected => payers.fold(0.0, (s, p) => s + p.amountPaid);
  double get totalOutstanding => payers.fold(0.0, (s, p) => s + p.outstanding);
  int get settledCount => payers.where((p) => p.isSettled).length;
  int get defaultedCount => payers.where((p) => p.isDefaulted).length;
  int get reminderCount => payers.where((p) => p.isDueReminder).length;
}

// ============================================================================
// SHARED INPUT FIELD BUILDER
// ============================================================================
Widget _buildField(String label, String hint, TextEditingController ctrl, {bool isNumber = false}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(color: Color(0xFFE4E4E7), fontSize: 13, fontWeight: FontWeight.w500)),
      const SizedBox(height: 8),
      TextField(
        controller: ctrl,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF52525B)),
          filled: true,
          fillColor: const Color(0xFF09090B),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF27272A))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF27272A))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF3B82F6))),
        ),
      ),
    ],
  );
}

String _formatCurrency(double val) {
  if (val >= 1000000) return '₦${(val / 1000000).toStringAsFixed(1)}M';
  if (val >= 1000) return '₦${(val / 1000).toStringAsFixed(0)}K';
  return '₦${val.toStringAsFixed(0)}';
}

// ============================================================================
// MAIN SCREEN
// ============================================================================
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
      backgroundColor: const Color(0xFF09090B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF09090B),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
              child: const Icon(Icons.business_center_rounded, color: Colors.black, size: 16),
            ),
            const SizedBox(width: 12),
            const Text('gabis Business', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16, letterSpacing: -0.5)),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: TextButton.icon(
              onPressed: () => ref.read(isBusinessModeProvider.notifier).state = false,
              icon: const Icon(Icons.swap_horiz_rounded, color: Color(0xFFA1A1AA), size: 16),
              label: const Text('Personal Account', style: TextStyle(color: Color(0xFFA1A1AA), fontWeight: FontWeight.w500, fontSize: 13)),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFF27272A), width: 1))),
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              indicatorWeight: 2,
              labelColor: Colors.white,
              unselectedLabelColor: const Color(0xFFA1A1AA),
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
      body: TabBarView(
        controller: _tabController,
        children: const [
          _SmartInvoicesTab(),
          _ConnectedPaymentsTab(),
          _AIDebtCollectionTab(),
          _MultiCurrencyTaxTab(),
        ],
      ),
    );
  }
}

// ============================================================================
// 1. SMART INVOICE GENERATION
// ============================================================================
class _SmartInvoicesTab extends StatefulWidget {
  const _SmartInvoicesTab();
  @override
  State<_SmartInvoicesTab> createState() => _SmartInvoicesTabState();
}

class _SmartInvoicesTabState extends State<_SmartInvoicesTab> {
  final _clientCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  bool _isGenerating = false;

  final List<Map<String, String>> _invoices = [
    {'client': 'Acme Corp', 'amount': '₦450,000', 'desc': 'Q3 Software License', 'status': 'Sent', 'date': 'Aug 28'},
    {'client': 'TechBridge Ltd', 'amount': '₦1,200,000', 'desc': 'Cloud Infrastructure Setup', 'status': 'Paid', 'date': 'Aug 25'},
  ];

  void _generate() async {
    final client = _clientCtrl.text.trim();
    final amount = _amountCtrl.text.trim();
    final desc = _descCtrl.text.trim();
    if (client.isEmpty || amount.isEmpty) return;
    setState(() => _isGenerating = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() {
      _invoices.insert(0, {'client': client, 'amount': '₦$amount', 'desc': desc.isEmpty ? 'General Services' : desc, 'status': 'Generated', 'date': 'Just now'});
      _isGenerating = false;
      _clientCtrl.clear(); _amountCtrl.clear(); _descCtrl.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invoice for $client created.'), backgroundColor: const Color(0xFF10B981)));
  }

  @override
  void dispose() { _clientCtrl.dispose(); _amountCtrl.dispose(); _descCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Smart Invoice Generation', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        const Text('Instantly generate and send professional invoices.', style: TextStyle(color: Color(0xFFA1A1AA), fontSize: 13, height: 1.5)),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: const Color(0xFF18181B), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF27272A))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('New Invoice', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),
            _buildField('Client Name', 'e.g. Acme Corp', _clientCtrl),
            const SizedBox(height: 16),
            _buildField('Amount (NGN)', 'e.g. 500000', _amountCtrl, isNumber: true),
            const SizedBox(height: 16),
            _buildField('Description', 'e.g. Web Development', _descCtrl),
            const SizedBox(height: 24),
            SizedBox(width: double.infinity, height: 48, child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: _isGenerating ? null : _generate,
              child: _isGenerating ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Generate Invoice', style: TextStyle(fontWeight: FontWeight.bold)),
            )),
          ]),
        ),
        const SizedBox(height: 32),
        const Text('Recent Invoices', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        ..._invoices.map((inv) {
          final isPaid = inv['status'] == 'Paid';
          return Container(
            margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: const Color(0xFF18181B), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF27272A))),
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(inv['client']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
                const SizedBox(height: 4),
                Text(inv['desc']!, style: const TextStyle(color: Color(0xFFA1A1AA), fontSize: 12)),
              ])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(inv['amount']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
                const SizedBox(height: 4),
                Text('${inv['status']} · ${inv['date']}', style: TextStyle(color: isPaid ? const Color(0xFF10B981) : const Color(0xFF3B82F6), fontSize: 12)),
              ]),
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
class _ConnectedPaymentsTab extends StatefulWidget {
  const _ConnectedPaymentsTab();
  @override
  State<_ConnectedPaymentsTab> createState() => _ConnectedPaymentsTabState();
}

class _ConnectedPaymentsTabState extends State<_ConnectedPaymentsTab> {
  final _atService = AfricasTalkingService();
  final _nameCtrl = TextEditingController();
  final _domainCtrl = TextEditingController();
  final _typeCtrl = TextEditingController();
  final _payerNameCtrl = TextEditingController();
  final _payerEmailCtrl = TextEditingController();
  final _payerPhoneCtrl = TextEditingController();
  final _payerAmountCtrl = TextEditingController();
  final _payerInstCtrl = TextEditingController();

  int? _expandedCompany; // which company card is drilled into
  bool _isCallingDefaulter = false;
  String _callStatus = '';
  List<String> _callTranscript = [];

  final List<ConnectedCompany> _companies = [
    ConnectedCompany(
      name: 'Skill School',
      domain: 'skill-sch.com',
      paymentType: 'Tuition Fees',
      payers: [
        Payer(
          name: 'Amara Johnson',
          email: 'amara@gmail.com',
          phone: '+2348012345678',
          totalAmount: 500000,
          amountPaid: 200000,
          installments: 4,
          currentInstallment: 2,
          nextDueDate: DateTime.now().add(const Duration(days: 8)),
          status: 'reminder_sent',
          payments: [
            PaymentRecord(timestamp: DateTime.now().subtract(const Duration(days: 60)), amount: 100000, note: 'Installment 1 of 4'),
            PaymentRecord(timestamp: DateTime.now().subtract(const Duration(days: 30)), amount: 100000, note: 'Installment 2 of 4'),
          ],
        ),
        Payer(
          name: 'Chukwudi Eze',
          email: 'chukwudi@outlook.com',
          phone: '+2348023456789',
          totalAmount: 500000,
          amountPaid: 500000,
          installments: 4,
          currentInstallment: 4,
          nextDueDate: DateTime.now().subtract(const Duration(days: 5)),
          status: 'settled',
          payments: [
            PaymentRecord(timestamp: DateTime.now().subtract(const Duration(days: 90)), amount: 125000, note: 'Installment 1 of 4'),
            PaymentRecord(timestamp: DateTime.now().subtract(const Duration(days: 60)), amount: 125000, note: 'Installment 2 of 4'),
            PaymentRecord(timestamp: DateTime.now().subtract(const Duration(days: 30)), amount: 125000, note: 'Installment 3 of 4'),
            PaymentRecord(timestamp: DateTime.now().subtract(const Duration(days: 5)), amount: 125000, note: 'Installment 4 of 4'),
          ],
        ),
        Payer(
          name: 'Fatima Bello',
          email: 'fatima.b@yahoo.com',
          phone: '+2348034567890',
          totalAmount: 500000,
          amountPaid: 125000,
          installments: 4,
          currentInstallment: 1,
          nextDueDate: DateTime.now().subtract(const Duration(days: 3)),
          status: 'defaulted',
          payments: [
            PaymentRecord(timestamp: DateTime.now().subtract(const Duration(days: 45)), amount: 125000, note: 'Installment 1 of 4'),
          ],
        ),
      ],
    ),
    ConnectedCompany(
      name: 'SolarGrid Energy',
      domain: 'solargrid.ng',
      paymentType: 'Solar Inverter Installments',
      payers: [
        Payer(
          name: 'Emmanuel Adeyemi',
          email: 'emmanuel@adeyemi.ng',
          phone: '+2348045678901',
          totalAmount: 1200000,
          amountPaid: 800000,
          installments: 6,
          currentInstallment: 4,
          nextDueDate: DateTime.now().add(const Duration(days: 6)),
          status: 'reminder_sent',
          payments: [
            PaymentRecord(timestamp: DateTime.now().subtract(const Duration(days: 90)), amount: 200000, note: 'Installment 1 of 6'),
            PaymentRecord(timestamp: DateTime.now().subtract(const Duration(days: 60)), amount: 200000, note: 'Installment 2 of 6'),
            PaymentRecord(timestamp: DateTime.now().subtract(const Duration(days: 30)), amount: 200000, note: 'Installment 3 of 6'),
            PaymentRecord(timestamp: DateTime.now().subtract(const Duration(days: 1)), amount: 200000, note: 'Installment 4 of 6'),
          ],
        ),
        Payer(
          name: 'Ngozi Okonkwo',
          email: 'ngozi.o@gmail.com',
          phone: '+2348056789012',
          totalAmount: 850000,
          amountPaid: 283333,
          installments: 3,
          currentInstallment: 1,
          nextDueDate: DateTime.now().subtract(const Duration(days: 7)),
          status: 'defaulted',
          payments: [
            PaymentRecord(timestamp: DateTime.now().subtract(const Duration(days: 37)), amount: 283333, note: 'Installment 1 of 3'),
          ],
        ),
      ],
    ),
  ];

  void _addCompany() {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF18181B),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Connect a Company', style: TextStyle(color: Colors.white)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        _buildField('Company Name', 'e.g. Skill School, SolarGrid, Acme Corp', _nameCtrl),
        const SizedBox(height: 12),
        _buildField('Domain', 'e.g. skill-sch.com, company.com', _domainCtrl),
        const SizedBox(height: 12),
        _buildField('Payment Type', 'e.g. Tuition Fees, Device Installments, Retainer', _typeCtrl),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Color(0xFFA1A1AA)))),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black),
          onPressed: () {
            if (_nameCtrl.text.isEmpty || _domainCtrl.text.isEmpty) return;
            setState(() => _companies.add(ConnectedCompany(name: _nameCtrl.text.trim(), domain: _domainCtrl.text.trim(), paymentType: _typeCtrl.text.trim().isEmpty ? 'Installments' : _typeCtrl.text.trim())));
            _nameCtrl.clear(); _domainCtrl.clear(); _typeCtrl.clear();
            Navigator.pop(ctx);
          },
          child: const Text('Connect'),
        ),
      ],
    ));
  }

  void _addPayer(int companyIndex) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF18181B),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Add Customer / Payer to ${_companies[companyIndex].name}', style: const TextStyle(color: Colors.white, fontSize: 16)),
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
        ]),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Color(0xFFA1A1AA)))),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black),
          onPressed: () {
            final name = _payerNameCtrl.text.trim();
            final email = _payerEmailCtrl.text.trim();
            final phone = _payerPhoneCtrl.text.trim().isEmpty ? '+2348012345678' : _payerPhoneCtrl.text.trim();
            final amount = double.tryParse(_payerAmountCtrl.text.trim()) ?? 0;
            final inst = int.tryParse(_payerInstCtrl.text.trim()) ?? 1;
            if (name.isEmpty || amount <= 0) return;
            setState(() {
              _companies[companyIndex].payers.insert(0, Payer(
                name: name,
                email: email,
                phone: phone,
                totalAmount: amount,
                installments: inst,
                nextDueDate: DateTime.now().add(const Duration(days: 30)),
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
    final payer = _companies[companyIdx].payers[payerIdx];
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
      backgroundColor: const Color(0xFF10B981),
    ));
  }

  void _sendReminder(int companyIdx, int payerIdx) async {
    final payer = _companies[companyIdx].payers[payerIdx];
    final company = _companies[companyIdx];
    setState(() => payer.status = 'reminder_sent');

    final smsMessage = 'Reminder from ${company.name}: Your ${company.paymentType} installment of ${_formatCurrency(payer.perInstallment)} is due in ${payer.daysUntilDue} days. Pay online: https://${company.domain}/pay';

    // Trigger Africa's Talking SMS API
    _atService.sendReminderSMS(
      recipientPhone: payer.phone,
      message: smsMessage,
    );

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('SMS Reminder dispatched via Africa\'s Talking to ${payer.name} (${payer.phone}): "${company.paymentType} due in ${payer.daysUntilDue}d"'),
      backgroundColor: const Color(0xFF3B82F6),
      duration: const Duration(seconds: 4),
    ));
  }

  void _robotCall(int companyIdx, int payerIdx) async {
    final payer = _companies[companyIdx].payers[payerIdx];
    final company = _companies[companyIdx];

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
        // Header
        Row(children: [
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Connected Payments', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
            SizedBox(height: 8),
            Text('Connect any company (schools, retailers, solar providers, agencies) and track every customer installment plan. Automatic SMS reminders 10 days before due, robot voice calls for defaulters.', style: TextStyle(color: Color(0xFFA1A1AA), fontSize: 13, height: 1.5)),
          ])),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            onPressed: _addCompany,
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Connect Company'),
          ),
        ]),
        const SizedBox(height: 32),

        // Company cards
        ..._companies.asMap().entries.map((entry) {
          final ci = entry.key;
          final c = entry.value;
          final isExpanded = _expandedCompany == ci;

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(color: const Color(0xFF18181B), borderRadius: BorderRadius.circular(16), border: Border.all(color: isExpanded ? const Color(0xFF3B82F6) : const Color(0xFF27272A))),
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
                        decoration: BoxDecoration(color: const Color(0xFF3B82F6).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.business_rounded, color: Color(0xFF3B82F6), size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(c.name, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text('${c.domain} · ${c.paymentType}', style: const TextStyle(color: Color(0xFFA1A1AA), fontSize: 12)),
                      ])),
                      Icon(isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: const Color(0xFFA1A1AA)),
                    ]),
                    const SizedBox(height: 20),
                    Row(children: [
                      _compactStat('Customers', '${c.payers.length}'),
                      const SizedBox(width: 24),
                      _compactStat('Collected', _formatCurrency(c.totalCollected)),
                      const SizedBox(width: 24),
                      _compactStat('Outstanding', _formatCurrency(c.totalOutstanding)),
                      const SizedBox(width: 24),
                      if (c.reminderCount > 0) _alertBadge('${c.reminderCount} Reminders', const Color(0xFFF59E0B)),
                      if (c.reminderCount > 0) const SizedBox(width: 12),
                      if (c.defaultedCount > 0) _alertBadge('${c.defaultedCount} Defaulted', const Color(0xFFEF4444)),
                    ]),
                  ]),
                ),
              ),

              // Expanded: customer list
              if (isExpanded) ...[
                const Divider(color: Color(0xFF27272A), height: 1),
                Container(
                  padding: const EdgeInsets.all(24),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Text('${c.name} Customers & Payers', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () => _addPayer(ci),
                        icon: const Icon(Icons.person_add, size: 14, color: Color(0xFF3B82F6)),
                        label: const Text('Add Customer', style: TextStyle(color: Color(0xFF3B82F6), fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
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
          const Text('Robot Call Transcript', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          Container(
            width: double.infinity, padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: const Color(0xFF09090B), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF27272A))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                if (_isCallingDefaulter) ...[
                  const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF10B981))),
                  const SizedBox(width: 12),
                ],
                Expanded(child: Text(_callStatus, style: TextStyle(color: _isCallingDefaulter ? const Color(0xFF10B981) : const Color(0xFFA1A1AA), fontWeight: FontWeight.w600))),
              ]),
              if (_callTranscript.isNotEmpty) const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(color: Color(0xFF27272A))),
              ..._callTranscript.map((line) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(line, style: TextStyle(color: line.startsWith('AI:') ? const Color(0xFF3B82F6) : Colors.white, fontSize: 14, height: 1.6)),
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
      statusColor = const Color(0xFF10B981); statusLabel = 'Settled'; statusIcon = Icons.check_circle;
    } else if (p.isDefaulted) {
      statusColor = const Color(0xFFEF4444); statusLabel = 'Defaulted'; statusIcon = Icons.error;
    } else if (p.isDueReminder) {
      statusColor = const Color(0xFFF59E0B); statusLabel = 'Due in ${p.daysUntilDue}d'; statusIcon = Icons.notifications_active;
    } else {
      statusColor = const Color(0xFF3B82F6); statusLabel = 'On Track'; statusIcon = Icons.schedule;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF09090B), borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.isDefaulted ? const Color(0xFFEF4444).withOpacity(0.3) : const Color(0xFF27272A)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Name + status + actions
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(p.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
            const SizedBox(height: 2),
            Text('${p.email} · ${p.phone}', style: const TextStyle(color: Color(0xFF71717A), fontSize: 12)),
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
            backgroundColor: const Color(0xFF27272A),
            valueColor: AlwaysStoppedAnimation<Color>(p.isSettled ? const Color(0xFF10B981) : statusColor),
          ),
        ),

        // Action buttons
        if (!p.isSettled) ...[
          const SizedBox(height: 16),
          Row(children: [
            if (p.isDueReminder || p.status == 'on_track')
              TextButton.icon(
                onPressed: () => _sendReminder(ci, pi),
                icon: const Icon(Icons.notifications, size: 14, color: Color(0xFFF59E0B)),
                label: const Text('Send Reminder (SMS)', style: TextStyle(color: Color(0xFFF59E0B), fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            if (p.isDefaulted)
              TextButton.icon(
                onPressed: _isCallingDefaulter ? null : () => _robotCall(ci, pi),
                icon: Icon(_isCallingDefaulter ? Icons.phone_in_talk : Icons.phone, size: 14, color: const Color(0xFFEF4444)),
                label: Text(_isCallingDefaulter ? 'Calling...' : 'Robot Call', style: const TextStyle(color: Color(0xFFEF4444), fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            const Spacer(),
            TextButton.icon(
              onPressed: () => _recordPayment(ci, pi),
              icon: const Icon(Icons.payments, size: 14, color: Color(0xFF10B981)),
              label: const Text('Record Payment', style: TextStyle(color: Color(0xFF10B981), fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ]),
        ],

        // Payment history
        if (p.payments.isNotEmpty) ...[
          const SizedBox(height: 12),
          const Divider(color: Color(0xFF27272A)),
          const SizedBox(height: 8),
          const Text('Payment History', style: TextStyle(color: Color(0xFF71717A), fontSize: 11, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ...p.payments.reversed.take(3).map((r) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(children: [
              const Icon(Icons.check, color: Color(0xFF10B981), size: 12),
              const SizedBox(width: 8),
              Text(_formatCurrency(r.amount), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
              const SizedBox(width: 8),
              Text('· ${r.note}', style: const TextStyle(color: Color(0xFF71717A), fontSize: 11)),
              const Spacer(),
              Text('${r.timestamp.day}/${r.timestamp.month}/${r.timestamp.year}', style: const TextStyle(color: Color(0xFF52525B), fontSize: 11)),
            ]),
          )),
        ],
      ]),
    );
  }

  Widget _compactStat(String label, String value) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: Color(0xFF71717A), fontSize: 11)),
      const SizedBox(height: 2),
      Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
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
class _AIDebtCollectionTab extends StatefulWidget {
  const _AIDebtCollectionTab();
  @override
  State<_AIDebtCollectionTab> createState() => _AIDebtCollectionTabState();
}

class _AIDebtCollectionTabState extends State<_AIDebtCollectionTab> {
  final _atService = AfricasTalkingService();
  bool _isCalling = false;
  String _callStatus = '';
  final List<String> _transcript = [];
  String _selectedTone = 'Polite & Helpful';

  final List<Map<String, String>> _debtors = [
    {'name': 'David O.', 'phone': '+2348012345678', 'invoice': 'INV-492', 'amount': '₦150,000', 'days': '14 days'},
    {'name': 'Sarah K.', 'phone': '+2348023456789', 'invoice': 'INV-501', 'amount': '₦85,000', 'days': '7 days'},
    {'name': 'Michael A.', 'phone': '+2348034567890', 'invoice': 'INV-478', 'amount': '₦320,000', 'days': '30 days'},
  ];
  int _selectedDebtor = 0;

  void _startCall() async {
    final debtor = _debtors[_selectedDebtor];
    setState(() { _isCalling = true; _callStatus = 'Dialing ${debtor['name']} (${debtor['phone']}) via Africa\'s Talking Voice Gateway...'; _transcript.clear(); });
    
    // Call Africa's Talking Voice endpoint
    _atService.initiateVoiceCall(
      recipientPhone: debtor['phone'] ?? '+2348012345678',
    );

    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _callStatus = 'Call Connected (${debtor['phone']}) — AI Agent speaking');
    final lines = [
      "AI: Hello, am I speaking with ${debtor['name']}?",
      "${debtor['name']}: Yes, who is this?",
      "AI: Hi ${debtor['name']}, I'm calling on behalf of gabis Business regarding invoice ${debtor['invoice']} for ${debtor['amount']}.",
      "${debtor['name']}: Oh right, I forgot about that.",
      "AI: No problem at all. I can send a quick payment link to your phone right now. Would that work?",
      "${debtor['name']}: Yes, please send it.",
      "AI: Done! Payment link sent. Once paid, your ledger will clear automatically. Have a great day!",
    ];
    for (final line in lines) { await Future.delayed(const Duration(milliseconds: 1500)); if (!mounted) return; setState(() => _transcript.add(line)); }
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() { _callStatus = 'Call completed with ${debtor['name']} — Payment link sent'; _isCalling = false; });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('AI Debt Collection Calls', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        const Text('Dispatch conversational AI agents to follow up on overdue invoices.', style: TextStyle(color: Color(0xFFA1A1AA), fontSize: 13, height: 1.5)),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: const Color(0xFF18181B), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF27272A))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Select Debtor', style: TextStyle(color: Color(0xFFE4E4E7), fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 12),
            ..._debtors.asMap().entries.map((e) {
              final i = e.key; final d = e.value; final selected = i == _selectedDebtor;
              return GestureDetector(
                onTap: () => setState(() => _selectedDebtor = i),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: selected ? const Color(0xFF3B82F6).withOpacity(0.08) : const Color(0xFF09090B), borderRadius: BorderRadius.circular(12), border: Border.all(color: selected ? const Color(0xFF3B82F6) : const Color(0xFF27272A))),
                  child: Row(children: [
                    Icon(selected ? Icons.radio_button_checked : Icons.radio_button_off, color: selected ? const Color(0xFF3B82F6) : const Color(0xFF52525B), size: 18),
                    const SizedBox(width: 12),
                    Expanded(child: Text('${d['name']} — ${d['invoice']}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500))),
                    Text(d['amount']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 12),
                    Text('${d['days']} overdue', style: const TextStyle(color: Color(0xFFF59E0B), fontSize: 12)),
                  ]),
                ),
              );
            }),
            const SizedBox(height: 20),
            const Text('AI Tone', style: TextStyle(color: Color(0xFFE4E4E7), fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: const Color(0xFF09090B), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFF27272A))),
              child: DropdownButtonHideUnderline(child: DropdownButton<String>(
                value: _selectedTone, dropdownColor: const Color(0xFF18181B), isExpanded: true, style: const TextStyle(color: Colors.white, fontSize: 14), icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFA1A1AA)),
                items: ['Polite & Helpful', 'Professional & Firm', 'Urgent & Direct'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (v) { if (v != null) setState(() => _selectedTone = v); },
              )),
            ),
            const SizedBox(height: 24),
            SizedBox(width: double.infinity, height: 48, child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: _isCalling ? const Color(0xFFEF4444) : const Color(0xFF3B82F6), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: _isCalling ? null : _startCall,
              icon: Icon(_isCalling ? Icons.phone_in_talk : Icons.phone, size: 18),
              label: Text(_isCalling ? 'Call in Progress...' : 'Initiate AI Call', style: const TextStyle(fontWeight: FontWeight.bold)),
            )),
          ]),
        ),
        if (_callStatus.isNotEmpty) ...[
          const SizedBox(height: 32),
          const Text('Live Call Transcript', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          Container(
            width: double.infinity, padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: const Color(0xFF09090B), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF27272A))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                if (_isCalling) ...[const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF10B981))), const SizedBox(width: 12)],
                Expanded(child: Text(_callStatus, style: TextStyle(color: _isCalling ? const Color(0xFF10B981) : const Color(0xFFA1A1AA), fontWeight: FontWeight.w600))),
              ]),
              if (_transcript.isNotEmpty) const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(color: Color(0xFF27272A))),
              ..._transcript.map((line) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Text(line, style: TextStyle(color: line.startsWith('AI:') ? const Color(0xFF3B82F6) : Colors.white, fontSize: 14, height: 1.6)))),
            ]),
          ),
        ],
      ]),
    );
  }
}

// ============================================================================
// 4. MULTI-CURRENCY TAX FILING
// ============================================================================
class _MultiCurrencyTaxTab extends StatefulWidget {
  const _MultiCurrencyTaxTab();
  @override
  State<_MultiCurrencyTaxTab> createState() => _MultiCurrencyTaxTabState();
}

class _MultiCurrencyTaxTabState extends State<_MultiCurrencyTaxTab> {
  String _currency = 'NGN';
  final _revenueCtrl = TextEditingController();
  double _taxAmount = 0.0;
  bool _isFiling = false;
  final _currencySymbols = {'NGN': '₦', 'USD': '\$', 'GBP': '£', 'EUR': '€'};
  final List<Map<String, String>> _filingHistory = [
    {'period': 'Q2 2024', 'currency': 'NGN', 'amount': '₦318,750', 'status': 'Filed'},
    {'period': 'Q1 2024', 'currency': 'NGN', 'amount': '₦195,200', 'status': 'Filed'},
  ];

  void _calculateTax(String val) { setState(() => _taxAmount = (double.tryParse(val) ?? 0.0) * 0.075); }

  void _fileTax() async {
    if (_taxAmount <= 0) return;
    setState(() => _isFiling = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    final sym = _currencySymbols[_currency]!;
    setState(() {
      _filingHistory.insert(0, {'period': 'Q3 2024', 'currency': _currency, 'amount': '$sym${_taxAmount.toStringAsFixed(2)}', 'status': 'Filed'});
      _isFiling = false; _revenueCtrl.clear(); _taxAmount = 0.0;
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tax successfully filed and remitted.'), backgroundColor: Color(0xFF10B981)));
  }

  @override
  void dispose() { _revenueCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final sym = _currencySymbols[_currency]!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Multi-Currency Tax Filing', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        const Text('Calculate and remit taxes across different currencies and jurisdictions.', style: TextStyle(color: Color(0xFFA1A1AA), fontSize: 13, height: 1.5)),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: const Color(0xFF18181B), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF27272A))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('File New Tax', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Currency', style: TextStyle(color: Color(0xFFE4E4E7), fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(color: const Color(0xFF09090B), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFF27272A))),
                  child: DropdownButtonHideUnderline(child: DropdownButton<String>(
                    value: _currency, dropdownColor: const Color(0xFF18181B), isExpanded: true, style: const TextStyle(color: Colors.white, fontSize: 14), icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFA1A1AA)),
                    items: _currencySymbols.entries.map((e) => DropdownMenuItem(value: e.key, child: Text('${e.key} (${e.value})'))).toList(),
                    onChanged: (v) { if (v != null) setState(() => _currency = v); },
                  )),
                ),
              ])),
              const SizedBox(width: 16),
              Expanded(flex: 2, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Declarable Revenue', style: TextStyle(color: Color(0xFFE4E4E7), fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                TextField(controller: _revenueCtrl, keyboardType: TextInputType.number, onChanged: _calculateTax, style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(hintText: 'e.g. 5000000', hintStyle: const TextStyle(color: Color(0xFF52525B)), filled: true, fillColor: const Color(0xFF09090B),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF27272A))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF27272A))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF3B82F6))),
                  ),
                ),
              ])),
            ]),
            const Padding(padding: EdgeInsets.symmetric(vertical: 24), child: Divider(color: Color(0xFF27272A))),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Tax Liability (7.5% VAT)', style: TextStyle(color: Color(0xFFA1A1AA), fontSize: 14)),
              Text('$sym${_taxAmount.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w600, letterSpacing: -0.5)),
            ]),
            const SizedBox(height: 24),
            SizedBox(width: double.infinity, height: 48, child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3B82F6), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: (_taxAmount > 0 && !_isFiling) ? _fileTax : null,
              child: _isFiling ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('File & Remit Tax', style: TextStyle(fontWeight: FontWeight.bold)),
            )),
          ]),
        ),
        const SizedBox(height: 32),
        const Text('Filing History', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        ..._filingHistory.map((f) => Container(
          margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: const Color(0xFF18181B), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF27272A))),
          child: Row(children: [
            const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 18),
            const SizedBox(width: 12),
            Text(f['period']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
            const SizedBox(width: 12),
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: const Color(0xFF27272A), borderRadius: BorderRadius.circular(4)), child: Text(f['currency']!, style: const TextStyle(color: Color(0xFFA1A1AA), fontSize: 11))),
            const Spacer(),
            Text(f['amount']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ]),
        )),
      ]),
    );
  }
}
