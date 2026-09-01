import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'business_persistence.dart';

/// One store behind every business tab.
///
/// Invoices, installment plans, collection calls and tax filings all read and
/// write the same state, so the numbers on one tab are the numbers on the next:
/// an invoice raised here shows up as outstanding there, a payer who slips past
/// their due date appears in the collections queue, and tax is computed from
/// money actually collected.

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
  String status; // on_track | reminder_sent | defaulted | settled
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

  /// Who to reach when an invoice slips, and how long they have to pay.
  String contactName;
  String contactPhone;
  String contactEmail;
  int termsDays;

  List<Payer> payers;

  ConnectedCompany({
    required this.name,
    required this.domain,
    required this.paymentType,
    this.contactName = '',
    this.contactPhone = '',
    this.contactEmail = '',
    this.termsDays = 30,
    List<Payer>? payers,
  }) : payers = payers ?? [];

  double get totalCollected => payers.fold(0.0, (s, p) => s + p.amountPaid);
  double get totalOutstanding => payers.fold(0.0, (s, p) => s + p.outstanding);
  int get settledCount => payers.where((p) => p.isSettled).length;
  int get defaultedCount => payers.where((p) => p.isDefaulted).length;
  int get reminderCount => payers.where((p) => p.isDueReminder).length;
}

class Invoice {
  final String id;
  final String client;
  final double amount;
  final String currency;
  final String description;
  final DateTime issued;
  final DateTime due;
  String status; // draft | sent | paid | overdue
  final String? companyDomain;

  Invoice({
    required this.id,
    required this.client,
    required this.amount,
    required this.description,
    required this.issued,
    required this.due,
    this.currency = 'NGN',
    this.status = 'sent',
    this.companyDomain,
  });

  bool get isOverdue => status != 'paid' && due.isBefore(DateTime.now());
}

/// A collections call the voice agent placed.
/// One collection attempt and what came of it.
///
/// This is the asset. Anyone can place a call; nobody else has a record of
/// which language, tone and hour actually got a Nigerian customer to pay, or
/// whether the promise they made was kept. Every field here exists so that
/// question can be answered later from data rather than opinion.
class CallLog {
  final String payerName;
  final String company;
  final double amount;
  final DateTime placedAt;
  final String tone;
  final String outcome; // link_sent | promised | no_answer | settled | paid | refused
  final List<String> transcript;

  /// The language the attempt was made in — the whole point of the agent.
  final String language;

  /// Which route it went out on: voice, whatsapp, sms, email.
  final String channel;

  final int daysOverdue;

  /// How many attempts this debtor had already had before this one.
  final int attemptNumber;

  /// When they said they would pay, if they said anything.
  final DateTime? promisedDate;

  /// Filled in later: did the promise hold? Null until the date passes.
  bool? promiseKept;

  /// Money that actually arrived attributable to this attempt.
  double amountRecovered;

  CallLog({
    required this.payerName,
    required this.company,
    required this.amount,
    required this.placedAt,
    required this.tone,
    required this.outcome,
    required this.transcript,
    this.language = 'English',
    this.channel = 'voice',
    this.daysOverdue = 0,
    this.attemptNumber = 1,
    this.promisedDate,
    this.promiseKept,
    this.amountRecovered = 0,
  });

  /// The hour of day the attempt was made — one of the few dials that is free
  /// to change and might matter a great deal.
  int get hour => placedAt.hour;

  bool get succeeded =>
      outcome == 'paid' || outcome == 'settled' || amountRecovered > 0;
}

/// A roll-up of attempts, sliced however the caller asks.
class CollectionStat {
  final String label;
  final int attempts;
  final int successes;
  final int promises;
  final int promisesKept;
  final double recovered;

  const CollectionStat({
    required this.label,
    required this.attempts,
    required this.successes,
    required this.promises,
    required this.promisesKept,
    required this.recovered,
  });

  double get successRate => attempts == 0 ? 0 : successes / attempts;
  double get keptRate => promises == 0 ? 0 : promisesKept / promises;
}

class TaxFiling {
  final String currency;
  final String jurisdiction;
  final double revenue;
  final double rate;
  final DateTime filedAt;
  final String period;

  TaxFiling({
    required this.currency,
    required this.jurisdiction,
    required this.revenue,
    required this.rate,
    required this.filedAt,
    required this.period,
  });

  double get taxDue => revenue * rate;
}

class BusinessState {
  final List<ConnectedCompany> companies;
  final List<Invoice> invoices;
  final List<CallLog> calls;
  final List<TaxFiling> filings;

  /// True when the collection attempts are illustrative rather than real.
  /// Every surface that reports on them has to say so — a number that looks
  /// like evidence and is not is worse than no number.
  final bool sampleAttempts;

  const BusinessState({
    required this.companies,
    required this.invoices,
    required this.calls,
    required this.filings,
    this.sampleAttempts = false,
  });

  BusinessState copyWith({
    List<ConnectedCompany>? companies,
    List<Invoice>? invoices,
    List<CallLog>? calls,
    List<TaxFiling>? filings,
    bool? sampleAttempts,
  }) =>
      BusinessState(
        companies: companies ?? this.companies,
        invoices: invoices ?? this.invoices,
        calls: calls ?? this.calls,
        filings: filings ?? this.filings,
        sampleAttempts: sampleAttempts ?? this.sampleAttempts,
      );

  // ── roll-ups the whole dashboard shares ────────────────────────────────
  double get collected => companies.fold(0.0, (s, c) => s + c.totalCollected);
  double get outstanding => companies.fold(0.0, (s, c) => s + c.totalOutstanding);

  double get invoicedOutstanding => invoices
      .where((i) => i.status != 'paid')
      .fold(0.0, (s, i) => s + i.amount);

  double get invoicedPaid =>
      invoices.where((i) => i.status == 'paid').fold(0.0, (s, i) => s + i.amount);

  /// Everything actually received — installment payments plus settled invoices.
  double get totalRevenue => collected + invoicedPaid;

  List<Payer> get allPayers => companies.expand((c) => c.payers).toList();
  List<Payer> get defaulters => allPayers.where((p) => p.isDefaulted).toList();
  List<Payer> get dueSoon => allPayers.where((p) => p.isDueReminder).toList();

  int get customerCount => allPayers.length;

  /// Share of billed value that has been collected.
  double get collectionRate {
    final billed = collected + outstanding;
    return billed == 0 ? 0 : collected / billed;
  }

  // ── the collections loop, measured ─────────────────────────────────────

  /// Attempts grouped by any dimension — language, tone, channel, hour band.
  List<CollectionStat> statsBy(String Function(CallLog) key) {
    final buckets = <String, List<CallLog>>{};
    for (final call in calls) {
      buckets.putIfAbsent(key(call), () => []).add(call);
    }

    final stats = buckets.entries.map((e) {
      final list = e.value;
      final promises = list.where((c) => c.promisedDate != null).toList();
      return CollectionStat(
        label: e.key,
        attempts: list.length,
        successes: list.where((c) => c.succeeded).length,
        promises: promises.length,
        promisesKept: promises.where((c) => c.promiseKept == true).length,
        recovered: list.fold(0.0, (s, c) => s + c.amountRecovered),
      );
    }).toList();

    stats.sort((a, b) => b.attempts.compareTo(a.attempts));
    return stats;
  }

  List<CollectionStat> get statsByLanguage => statsBy((c) => c.language);
  List<CollectionStat> get statsByTone => statsBy((c) => c.tone);
  List<CollectionStat> get statsByChannel => statsBy((c) => c.channel);

  List<CollectionStat> get statsByHour => statsBy((c) {
        final h = c.hour;
        if (h < 12) return 'Morning (before 12)';
        if (h < 16) return 'Afternoon (12–16)';
        return 'Evening (after 16)';
      });

  /// Share of attempts that ended in money arriving.
  double get recoveryRate {
    if (calls.isEmpty) return 0;
    return calls.where((c) => c.succeeded).length / calls.length;
  }

  double get totalRecovered =>
      calls.fold(0.0, (s, c) => s + c.amountRecovered);

  int get promisesMade => calls.where((c) => c.promisedDate != null).length;

  int get promisesKept => calls.where((c) => c.promiseKept == true).length;

  double get promiseKeptRate =>
      promisesMade == 0 ? 0 : promisesKept / promisesMade;

  /// Attempts whose promise date has passed with no answer either way — the
  /// queue that keeps the dataset honest.
  List<CallLog> get promisesToVerify => calls
      .where((c) =>
          c.promisedDate != null &&
          c.promiseKept == null &&
          c.promisedDate!.isBefore(DateTime.now()))
      .toList();

  /// How many attempts it has taken, on average, to get money.
  double get attemptsPerRecovery {
    final wins = calls.where((c) => c.succeeded).length;
    return wins == 0 ? 0 : calls.length / wins;
  }

  ConnectedCompany? companyOf(Payer p) {
    for (final c in companies) {
      if (c.payers.contains(p)) return c;
    }
    return null;
  }
}

class BusinessNotifier extends StateNotifier<BusinessState> {
  BusinessNotifier() : super(_restore());

  /// Prefer the operator's own saved ledger; fall back to the seed only on a
  /// first run or unreadable data.
  static BusinessState _restore() {
    final raw = BusinessPersistence.read();
    if (raw == null) return _seed();
    return BusinessPersistence.decode(raw) ?? _seed();
  }

  /// Every mutation goes through here, so nothing can change on screen without
  /// also being written down.
  @override
  set state(BusinessState value) {
    super.state = value;
    BusinessPersistence.write(value);
  }

  /// Wipes the saved ledger and returns to the seeded example data.
  void resetToSeed() {
    BusinessPersistence.clear();
    state = _seed();
  }

  /// Starts an empty book — no example companies, invoices or calls.
  void startEmpty() {
    state = const BusinessState(
      companies: [],
      invoices: [],
      calls: [],
      filings: [],
    );
  }

  void deleteInvoice(String id) {
    state = state.copyWith(
      invoices: state.invoices.where((i) => i.id != id).toList(),
    );
  }

  /// Marks an invoice as sent to the client (from an actual share action).
  void markInvoiceSent(String id) {
    for (final i in state.invoices) {
      if (i.id == id && i.status == 'draft') i.status = 'sent';
    }
    state = state.copyWith(invoices: [...state.invoices]);
  }

  static BusinessState _seed() {
    final now = DateTime.now();
    DateTime day(int offset) => DateTime(now.year, now.month, now.day + offset);

    final skillSch = ConnectedCompany(
      name: 'Skill School',
      domain: 'skill-sch.com',
      paymentType: 'Tuition installments',
      payers: [
        Payer(
          name: 'Amara Johnson',
          email: 'amara.j@gmail.com',
          phone: '+2348031234567',
          totalAmount: 400000,
          amountPaid: 200000,
          installments: 4,
          currentInstallment: 2,
          nextDueDate: day(6),
          payments: [
            PaymentRecord(timestamp: day(-62), amount: 100000, note: 'Instalment 1'),
            PaymentRecord(timestamp: day(-31), amount: 100000, note: 'Instalment 2'),
          ],
        ),
        Payer(
          name: 'Emmanuel Adeyemi',
          email: 'e.adeyemi@outlook.com',
          phone: '+2348062223344',
          totalAmount: 600000,
          amountPaid: 200000,
          installments: 6,
          currentInstallment: 2,
          nextDueDate: day(-9),
          status: 'defaulted',
          payments: [
            PaymentRecord(timestamp: day(-70), amount: 100000, note: 'Instalment 1'),
            PaymentRecord(timestamp: day(-40), amount: 100000, note: 'Instalment 2'),
          ],
        ),
        Payer(
          name: 'Ngozi Okeke',
          email: 'ngozi.okeke@yahoo.com',
          phone: '+2348099887766',
          totalAmount: 300000,
          amountPaid: 300000,
          installments: 3,
          currentInstallment: 3,
          nextDueDate: day(-4),
          status: 'settled',
          payments: [
            PaymentRecord(timestamp: day(-90), amount: 100000, note: 'Instalment 1'),
            PaymentRecord(timestamp: day(-60), amount: 100000, note: 'Instalment 2'),
            PaymentRecord(timestamp: day(-30), amount: 100000, note: 'Instalment 3'),
          ],
        ),
      ],
    );

    final solar = ConnectedCompany(
      name: 'SolarGrid Energy',
      domain: 'solargrid.ng',
      paymentType: 'Equipment financing',
      payers: [
        Payer(
          name: 'Chidi Nwosu',
          email: 'chidi@nwosufarms.ng',
          phone: '+2348055512345',
          totalAmount: 1200000,
          amountPaid: 800000,
          installments: 6,
          currentInstallment: 4,
          nextDueDate: day(3),
          payments: [
            PaymentRecord(timestamp: day(-100), amount: 400000, note: 'Deposit'),
            PaymentRecord(timestamp: day(-45), amount: 400000, note: 'Instalment 2'),
          ],
        ),
        Payer(
          name: 'Fatima Bello',
          email: 'fatima.bello@gmail.com',
          phone: '+2348077766554',
          totalAmount: 900000,
          amountPaid: 150000,
          installments: 6,
          currentInstallment: 1,
          nextDueDate: day(-21),
          status: 'defaulted',
          payments: [
            PaymentRecord(timestamp: day(-51), amount: 150000, note: 'Deposit'),
          ],
        ),
      ],
    );

    final agency = ConnectedCompany(
      name: 'Northgate Agency',
      domain: 'northgate.africa',
      paymentType: 'Retainer billing',
      payers: [
        Payer(
          name: 'Tunde Balogun',
          email: 'tunde@northgate.africa',
          phone: '+2348012340000',
          totalAmount: 750000,
          amountPaid: 500000,
          installments: 3,
          currentInstallment: 2,
          nextDueDate: day(9),
          payments: [
            PaymentRecord(timestamp: day(-58), amount: 250000, note: 'Instalment 1'),
            PaymentRecord(timestamp: day(-28), amount: 250000, note: 'Instalment 2'),
          ],
        ),
      ],
    );

    return BusinessState(
      companies: [skillSch, solar, agency],
      invoices: [
        Invoice(
          id: 'INV-2481',
          client: 'Acme Corp',
          amount: 450000,
          description: 'Q3 software licence',
          issued: day(-4),
          due: day(26),
          status: 'sent',
        ),
        Invoice(
          id: 'INV-2478',
          client: 'TechBridge Ltd',
          amount: 1200000,
          description: 'Cloud infrastructure setup',
          issued: day(-7),
          due: day(-1),
          status: 'paid',
        ),
        Invoice(
          id: 'INV-2470',
          client: 'Harbour Logistics',
          amount: 320000,
          description: 'Fleet tracking retainer',
          issued: day(-33),
          due: day(-3),
          status: 'sent',
        ),
      ],
      calls: [
        CallLog(
          payerName: 'Fatima Bello',
          company: 'SolarGrid Energy',
          amount: 750000,
          placedAt: day(-2),
          tone: 'Polite',
          outcome: 'link_sent',
          transcript: [
            'Agent: Good afternoon, am I speaking with Fatima Bello?',
            'Customer: Yes, who is this?',
            'Agent: This is the SolarGrid billing assistant. Your instalment of ₦150,000 was due 21 days ago.',
            'Customer: I remember. Can you send the link again?',
            'Agent: Sent to your WhatsApp now. Thank you.',
          ],
        ),
      ],
      filings: [
        TaxFiling(
          currency: 'NGN',
          jurisdiction: 'Nigeria · FIRS VAT',
          revenue: 2450000,
          rate: 0.075,
          filedAt: day(-30),
          period: 'Last month',
        ),
      ],
    );
  }

  // ── mutations ──────────────────────────────────────────────────────────

  void addInvoice(Invoice invoice) {
    state = state.copyWith(invoices: [invoice, ...state.invoices]);
  }

  void markInvoicePaid(String id) {
    for (final i in state.invoices) {
      if (i.id == id) i.status = 'paid';
    }
    state = state.copyWith(invoices: [...state.invoices]);
  }

  void addCompany(ConnectedCompany company) {
    state = state.copyWith(companies: [...state.companies, company]);
  }

  void addPayer(ConnectedCompany company, Payer payer) {
    company.payers.add(payer);
    state = state.copyWith(companies: [...state.companies]);
  }

  /// Records an instalment against a payer and advances their schedule.
  void recordPayment(Payer payer, double amount, String note) {
    payer.amountPaid = (payer.amountPaid + amount).clamp(0, payer.totalAmount);
    payer.payments.add(PaymentRecord(timestamp: DateTime.now(), amount: amount, note: note));
    payer.currentInstallment =
        (payer.currentInstallment + 1).clamp(0, payer.installments);
    if (payer.isSettled) {
      payer.status = 'settled';
    } else {
      payer.status = 'on_track';
      payer.nextDueDate = DateTime.now().add(const Duration(days: 30));
    }
    state = state.copyWith(companies: [...state.companies]);
  }

  void markReminderSent(Payer payer) {
    payer.status = 'reminder_sent';
    state = state.copyWith(companies: [...state.companies]);
  }

  /// Closes the loop on a promise: did the money actually arrive?
  void resolvePromise(CallLog call, {required bool kept, double recovered = 0}) {
    call.promiseKept = kept;
    call.amountRecovered = recovered;
    state = state.copyWith(calls: [...state.calls]);
  }

  /// Loads 25 illustrative attempts so the intelligence panel can be seen
  /// working. Marked as sample, and cleared in one call — never to be passed
  /// off as real outcomes.
  void loadSampleAttempts() {
    final rng = math.Random(7);
    const languages = ['English', 'Pidgin', 'Yoruba', 'Hausa', 'Igbo'];
    const channels = ['voice', 'whatsapp', 'sms', 'email'];
    const names = [
      'Amara Johnson', 'Tunde Bello', 'Chidi Okafor', 'Fatima Bello',
      'Ngozi Eze', 'Musa Ibrahim', 'Kemi Adeyemi', 'Emeka Nwosu',
    ];

    final calls = <CallLog>[];
    for (var i = 0; i < 25; i++) {
      final language = languages[rng.nextInt(languages.length)];
      final channel = channels[rng.nextInt(channels.length)];
      final placedAt = DateTime.now().subtract(
        Duration(days: rng.nextInt(40), hours: 8 + rng.nextInt(11)),
      );
      final amount = (25 + rng.nextInt(180)) * 1000.0;

      // Illustrative only: these outcomes are drawn from a distribution, not
      // measured. Nothing here is a finding.
      final roll = rng.nextDouble();
      final paid = roll < .32;
      final promised = !paid && roll < .62;
      final kept = promised ? rng.nextDouble() < .45 : null;

      calls.add(CallLog(
        payerName: names[rng.nextInt(names.length)],
        company: 'Sample company',
        amount: amount,
        placedAt: placedAt,
        tone: 'Polite & Helpful',
        outcome: paid ? 'paid' : (promised ? 'promised' : 'no_answer'),
        transcript: const ['Sample attempt — illustrative data'],
        language: language,
        channel: channel,
        daysOverdue: rng.nextInt(60),
        attemptNumber: 1 + rng.nextInt(3),
        promisedDate: promised
            ? placedAt.add(Duration(days: 2 + rng.nextInt(10)))
            : null,
        promiseKept: kept,
        amountRecovered: paid ? amount : (kept == true ? amount / 2 : 0),
      ));
    }

    state = state.copyWith(calls: calls, sampleAttempts: true);
  }

  void clearSampleAttempts() {
    if (!state.sampleAttempts) return;
    state = state.copyWith(calls: [], sampleAttempts: false);
  }

  /// The dataset as CSV — one row per attempt, ready to attach to anything.
  String attemptsCsv() {
    final rows = <String>[
      'placed_at,payer,company,language,channel,hour,days_overdue,'
          'attempt_number,amount,outcome,promised_date,promise_kept,amount_recovered',
    ];
    for (final c in state.calls) {
      rows.add([
        c.placedAt.toIso8601String(),
        '"${c.payerName}"',
        '"${c.company}"',
        c.language,
        c.channel,
        c.hour,
        c.daysOverdue,
        c.attemptNumber,
        c.amount.round(),
        c.outcome,
        c.promisedDate?.toIso8601String() ?? '',
        c.promiseKept == null ? '' : (c.promiseKept! ? 'yes' : 'no'),
        c.amountRecovered.round(),
      ].join(','));
    }
    return rows.join('\n');
  }

  /// A trader with no registered company still has debtors. This creates the
  /// one book they need so collections can start immediately.
  ConnectedCompany startPersonalBook(String name) {
    final book = ConnectedCompany(
      name: name.trim().isEmpty ? 'My business' : name.trim(),
      domain: 'personal',
      paymentType: 'Money owed to me',
    );
    state = state.copyWith(companies: [...state.companies, book]);
    return book;
  }

  /// Debtors as CSV — names, numbers and what they owe. Theirs to take
  /// anywhere: a phone backup, a spreadsheet, another tool.
  String debtorsCsv({ConnectedCompany? company}) {
    final rows = <String>[
      'name,phone,email,company,total,paid,outstanding,next_due,instalment,status',
    ];
    final payers = company == null
        ? state.companies.expand((c) => c.payers.map((p) => (c, p)))
        : company.payers.map((p) => (company, p));

    for (final (c, p) in payers) {
      rows.add([
        '"${p.name}"',
        p.phone,
        p.email,
        '"${c.name}"',
        p.totalAmount.round(),
        p.amountPaid.round(),
        p.outstanding.round(),
        '${p.nextDueDate.year}-${p.nextDueDate.month.toString().padLeft(2, '0')}-${p.nextDueDate.day.toString().padLeft(2, '0')}',
        '${p.currentInstallment} of ${p.installments}',
        p.isSettled
            ? 'settled'
            : (p.isDefaulted ? 'overdue' : (p.isDueReminder ? 'due_soon' : 'on_track')),
      ].join(','));
    }
    return rows.join('\n');
  }

  void logCall(CallLog call) {
    state = state.copyWith(calls: [call, ...state.calls]);
  }

  void fileTax(TaxFiling filing) {
    state = state.copyWith(filings: [filing, ...state.filings]);
  }
}

final businessProvider =
    StateNotifierProvider<BusinessNotifier, BusinessState>((ref) => BusinessNotifier());

String formatNaira(double val) {
  if (val >= 1000000) return '₦${(val / 1000000).toStringAsFixed(1)}M';
  if (val >= 1000) return '₦${(val / 1000).toStringAsFixed(0)}K';
  return '₦${val.toStringAsFixed(0)}';
}

String formatFull(double val) {
  final s = val.round().toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return '₦$buf';
}
