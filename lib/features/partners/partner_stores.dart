import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/local_json.dart';
import 'partner_rails.dart';

String _id() => DateTime.now().microsecondsSinceEpoch.toString();

// ── Escrow ───────────────────────────────────────────────────────────────

/// Mirrors ORPay's escrow lifecycle.
enum EscrowStage { awaitingFunding, funded, dispatched, released, refunded, disputed, cancelled }

class EscrowDeal {
  final String id;
  final String? partnerId;
  final String? fundingUrl;
  final String title;
  final String counterparty;
  final bool iAmBuyer;
  final int amountMinor;
  final EscrowStage stage;
  final List<String> log;
  final DateTime createdAt;

  const EscrowDeal({
    required this.id,
    this.partnerId,
    this.fundingUrl,
    required this.title,
    required this.counterparty,
    required this.iAmBuyer,
    required this.amountMinor,
    required this.stage,
    required this.log,
    required this.createdAt,
  });

  EscrowDeal copyWith({EscrowStage? stage, List<String>? log}) => EscrowDeal(
        id: id,
        partnerId: partnerId,
        fundingUrl: fundingUrl,
        title: title,
        counterparty: counterparty,
        iAmBuyer: iAmBuyer,
        amountMinor: amountMinor,
        stage: stage ?? this.stage,
        log: log ?? this.log,
        createdAt: createdAt,
      );

  bool get open =>
      stage == EscrowStage.awaitingFunding ||
      stage == EscrowStage.funded ||
      stage == EscrowStage.dispatched ||
      stage == EscrowStage.disputed;

  /// The steps this user may sign now. The partner enforces the same rules
  /// (and the ship-by date for a buyer's refund); this only hides buttons
  /// that would be refused.
  List<EscrowStep> stepsForMe() {
    if (stage == EscrowStage.funded || stage == EscrowStage.dispatched) {
      return iAmBuyer
          ? [EscrowStep.release, EscrowStep.dispute, if (stage == EscrowStage.funded) EscrowStep.refund]
          : [if (stage == EscrowStage.funded) EscrowStep.dispatch, EscrowStep.refund, EscrowStep.dispute, if (stage == EscrowStage.dispatched) EscrowStep.claim];
    }
    return const [];
  }

  static EscrowStage stageAfter(EscrowStep s) => switch (s) {
        EscrowStep.release || EscrowStep.claim => EscrowStage.released,
        EscrowStep.refund => EscrowStage.refunded,
        EscrowStep.dispute => EscrowStage.disputed,
        EscrowStep.dispatch => EscrowStage.dispatched,
      };

  Map<String, dynamic> toJson() => {
        'id': id,
        'pid': partnerId,
        'fund': fundingUrl,
        't': title,
        'c': counterparty,
        'buyer': iAmBuyer,
        'a': amountMinor,
        's': stage.name,
        'log': log,
        'at': createdAt.toIso8601String(),
      };

  static EscrowDeal? fromJson(Map<String, dynamic> j) {
    final at = readDate(j['at']);
    if (at == null) return null;
    return EscrowDeal(
      id: '${j['id']}',
      partnerId: j['pid'] as String?,
      fundingUrl: j['fund'] as String?,
      title: '${j['t']}',
      counterparty: '${j['c']}',
      iAmBuyer: j['buyer'] == true,
      amountMinor: (j['a'] as int?) ?? 0,
      // Deals saved by the earlier version used 'held'/'delivered'.
      stage: EscrowStage.values.firstWhere((s) => s.name == j['s'],
          orElse: () => switch (j['s']) { 'delivered' => EscrowStage.dispatched, _ => EscrowStage.funded }),
      log: ((j['log'] as List?) ?? const []).map((e) => '$e').toList(),
      createdAt: at,
    );
  }
}

/// What the screen should do after asking for a step: open a link for the
/// user to sign, or nothing (the step was applied here, in sandbox).
class StepOutcome {
  final String? signUrl;
  final String message;
  const StepOutcome(this.message, [this.signUrl]);
}

class EscrowNotifier extends StateNotifier<List<EscrowDeal>> {
  EscrowNotifier(this._custodian)
      : super(readJsonList(_key).map(EscrowDeal.fromJson).whereType<EscrowDeal>().toList());

  final EscrowCustodian _custodian;
  static const _key = 'gabis.escrow.v1';

  void _save() => writeJson(_key, state.map((d) => d.toJson()).toList());

  void _put(EscrowDeal d) {
    state = [for (final x in state) if (x.id == d.id) d else x];
    _save();
  }

  EscrowDeal _get(String id) => state.firstWhere((x) => x.id == id);

  Future<EscrowOpened> create({
    required String title,
    required String counterparty,
    required bool iAmBuyer,
    required int amountMinor,
  }) async {
    final o = await _custodian.open(title: title, seller: counterparty, amountMinor: amountMinor);
    if (!o.result.ok) return o;
    final deal = EscrowDeal(
      id: _id(),
      partnerId: o.partnerId,
      fundingUrl: o.fundingUrl,
      title: title,
      counterparty: counterparty,
      iAmBuyer: iAmBuyer,
      amountMinor: amountMinor,
      stage: EscrowStage.awaitingFunding,
      log: ['Escrow opened · ${o.result.reference}'],
      createdAt: DateTime.now(),
    );
    state = [deal, ...state];
    _save();
    return o;
  }

  /// Sandbox only: the buyer's funding, which a live partner reports by webhook.
  void simulateFunding(String id) {
    final d = _get(id);
    _put(d.copyWith(stage: EscrowStage.funded, log: [...d.log, 'Buyer funded the escrow (sandbox)']));
  }

  Future<PartnerResult> cancel(String id) async {
    final d = _get(id);
    final r = await _custodian.cancel(d.partnerId ?? d.id);
    if (r.ok) _put(d.copyWith(stage: EscrowStage.cancelled, log: [...d.log, 'Cancelled before funding']));
    return r;
  }

  /// Asks the custodian for the step. Live: returns a link for the user to
  /// sign in ORPay; the new state arrives by webhook. Sandbox: applies it.
  Future<StepOutcome> step(String id, EscrowStep step) async {
    final d = _get(id);
    final url = await _custodian.stepUrl(d.partnerId ?? d.id, step);
    if (url != null) return StepOutcome('Opening ORPay to sign "${step.name}"', url);
    _put(d.copyWith(
      stage: EscrowDeal.stageAfter(step),
      log: [...d.log, '${step.name[0].toUpperCase()}${step.name.substring(1)} signed by the ${d.iAmBuyer ? 'buyer' : 'seller'} (sandbox)'],
    ));
    return StepOutcome('${step.name} done (sandbox)');
  }

  /// Live: the webhook's state, as mirrored into Firestore, applied here.
  void applyPartnerStatus(String partnerId, String status) {
    final stage = switch (status) {
      'awaiting_funding' || 'linked' => null,
      'funded' => EscrowStage.funded,
      'dispatched' => EscrowStage.dispatched,
      'completed' || 'resolved' => EscrowStage.released,
      'refunded' => EscrowStage.refunded,
      'disputed' => EscrowStage.disputed,
      'cancelled' || 'expired' => EscrowStage.cancelled,
      _ => null,
    };
    for (final d in state.where((d) => d.partnerId == partnerId)) {
      if (stage != null && stage != d.stage) _put(d.copyWith(stage: stage, log: [...d.log, 'ORPay: $status']));
    }
  }
}

final escrowProvider = StateNotifierProvider<EscrowNotifier, List<EscrowDeal>>(
    (ref) => EscrowNotifier(ref.watch(escrowCustodianProvider)));

// ── Ajo saving circles ───────────────────────────────────────────────────

class AjoEvent {
  final String text;
  final DateTime at;
  const AjoEvent(this.text, this.at);
  Map<String, dynamic> toJson() => {'t': text, 'at': at.toIso8601String()};
  static AjoEvent? fromJson(Map<String, dynamic> j) {
    final at = readDate(j['at']);
    return at == null ? null : AjoEvent('${j['t']}', at);
  }
}

class AjoCircle {
  final String id;
  final String name;
  final List<String> members; // payout order
  final int contributionNaira;
  final String frequency; // 'weekly' | 'monthly'
  final int round; // 0-based, whose turn it is
  final Set<String> paidThisRound;
  final DateTime startedAt;

  /// Organiser's standing approval: pay the pot out the moment the last
  /// contribution arrives, instead of approving each round by hand.
  final bool autoPayout;
  final List<AjoEvent> history;

  const AjoCircle({
    required this.id,
    required this.name,
    required this.members,
    required this.contributionNaira,
    required this.frequency,
    required this.round,
    required this.paidThisRound,
    required this.startedAt,
    this.autoPayout = false,
    this.history = const [],
  });

  int get potNaira => contributionNaira * members.length;
  String get recipient => members[round % members.length];
  bool get complete => round >= members.length;
  bool get everyonePaid => paidThisRound.length == members.length;
  List<String> get unpaid => members.where((m) => !paidThisRound.contains(m)).toList();
  int get periodDays => frequency == 'weekly' ? 7 : 30;

  DateTime payoutOn(int r) => startedAt.add(Duration(days: periodDays * (r + 1)));
  DateTime get nextPayoutOn => payoutOn(round);

  AjoCircle copyWith({int? round, Set<String>? paidThisRound, bool? autoPayout, List<AjoEvent>? history}) => AjoCircle(
        id: id,
        name: name,
        members: members,
        contributionNaira: contributionNaira,
        frequency: frequency,
        round: round ?? this.round,
        paidThisRound: paidThisRound ?? this.paidThisRound,
        startedAt: startedAt,
        autoPayout: autoPayout ?? this.autoPayout,
        history: history ?? this.history,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'n': name,
        'm': members,
        'c': contributionNaira,
        'f': frequency,
        'r': round,
        'paid': paidThisRound.toList(),
        'at': startedAt.toIso8601String(),
        'auto': autoPayout,
        'h': history.map((e) => e.toJson()).toList(),
      };

  static AjoCircle? fromJson(Map<String, dynamic> j) {
    final at = readDate(j['at']);
    final members = ((j['m'] as List?) ?? const []).map((e) => '$e').toList();
    if (at == null || members.length < 2) return null;
    return AjoCircle(
      id: '${j['id']}',
      name: '${j['n']}',
      members: members,
      contributionNaira: (j['c'] as int?) ?? 0,
      frequency: '${j['f'] ?? 'monthly'}',
      round: (j['r'] as int?) ?? 0,
      paidThisRound: ((j['paid'] as List?) ?? const []).map((e) => '$e').toSet(),
      startedAt: at,
      autoPayout: j['auto'] == true,
      history: ((j['h'] as List?) ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(AjoEvent.fromJson)
          .whereType<AjoEvent>()
          .toList(),
    );
  }
}

class AjoNotifier extends StateNotifier<List<AjoCircle>> {
  AjoNotifier() : super(readJsonList(_key).map(AjoCircle.fromJson).whereType<AjoCircle>().toList());
  static const _key = 'gabis.ajo.v1';

  void _save() => writeJson(_key, state.map((c) => c.toJson()).toList());

  void _put(AjoCircle c) {
    state = [for (final x in state) if (x.id == c.id) c else x];
    _save();
  }

  AjoCircle _get(String id) => state.firstWhere((c) => c.id == id);

  static String _n(int v) {
    final s = v.toString();
    final b = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
      b.write(s[i]);
    }
    return '₦$b';
  }

  /// Starts a circle and returns it.
  AjoCircle create({
    required String name,
    required List<String> members,
    required int contributionNaira,
    required String frequency,
    bool autoPayout = false,
  }) {
    final circle = AjoCircle(
        id: _id(),
        name: name,
        members: members,
        contributionNaira: contributionNaira,
        frequency: frequency,
        round: 0,
        paidThisRound: const {},
        startedAt: DateTime.now(),
        autoPayout: autoPayout,
        history: [AjoEvent('Circle started with ${members.length} members', DateTime.now())],
      );
    state = [circle, ...state];
    _save();
    return circle;
  }

  void setAutoPayout(String id, bool v) {
    final c = _get(id);
    _put(c.copyWith(
        autoPayout: v,
        history: [...c.history, AjoEvent(v ? 'Auto-payout turned on' : 'Auto-payout turned off', DateTime.now())]));
  }

  /// Records a contribution. With auto-payout on, the last one releases the
  /// pot at once. Returns true when that happened.
  bool markPaid(String id, String member) {
    var c = _get(id);
    if (c.complete || c.paidThisRound.contains(member)) return false;
    c = c.copyWith(
      paidThisRound: {...c.paidThisRound, member},
      history: [...c.history, AjoEvent('$member paid ${_n(c.contributionNaira)}', DateTime.now())],
    );
    _put(c);
    if (c.autoPayout && c.everyonePaid) {
      payOut(id, auto: true);
      return true;
    }
    return false;
  }

  /// Pays the pot to this round's recipient. Only once everyone has paid.
  void payOut(String id, {bool auto = false}) {
    final c = _get(id);
    if (!c.everyonePaid || c.complete) return;
    _put(c.copyWith(
      round: c.round + 1,
      paidThisRound: const {},
      history: [...c.history, AjoEvent('${_n(c.potNaira)} paid to ${c.recipient}${auto ? ' automatically' : ''}', DateTime.now())],
    ));
  }

  void logReminder(String id, List<String> who) {
    final c = _get(id);
    _put(c.copyWith(history: [...c.history, AjoEvent('Reminder sent to ${who.join(', ')}', DateTime.now())]));
  }
}

final ajoProvider = StateNotifierProvider<AjoNotifier, List<AjoCircle>>((ref) => AjoNotifier());

// ── USDC wallet ──────────────────────────────────────────────────────────

class UsdcEntry {
  final String label;
  final int usdcCents; // positive in, negative out
  final String? outCurrency;
  final int? outMinor;
  final String reference;
  final DateTime at;

  const UsdcEntry({
    required this.label,
    required this.usdcCents,
    this.outCurrency,
    this.outMinor,
    required this.reference,
    required this.at,
  });

  Map<String, dynamic> toJson() => {
        'l': label,
        'u': usdcCents,
        'oc': outCurrency,
        'om': outMinor,
        'ref': reference,
        'at': at.toIso8601String(),
      };

  static UsdcEntry? fromJson(Map<String, dynamic> j) {
    final at = readDate(j['at']);
    if (at == null) return null;
    return UsdcEntry(
      label: '${j['l']}',
      usdcCents: (j['u'] as int?) ?? 0,
      outCurrency: j['oc'] as String?,
      outMinor: j['om'] as int?,
      reference: '${j['ref'] ?? ''}',
      at: at,
    );
  }
}

class UsdcWalletNotifier extends StateNotifier<List<UsdcEntry>> {
  UsdcWalletNotifier(this._rail)
      : super(readJsonList(_key).map(UsdcEntry.fromJson).whereType<UsdcEntry>().toList());

  final StablecoinRail _rail;
  static const _key = 'gabis.usdc.v1';

  int get balanceCents => state.fold(0, (s, e) => s + e.usdcCents);

  void _save() => writeJson(_key, state.map((e) => e.toJson()).toList());

  /// Sandbox only: simulates a client abroad paying in. A live rail credits
  /// this from the partner's deposit webhook instead.
  void simulateIncoming({required String from, required int usdcCents}) {
    state = [
      UsdcEntry(label: 'From $from', usdcCents: usdcCents, reference: 'SBX-IN-${state.length + 1}', at: DateTime.now()),
      ...state
    ];
    _save();
  }

  Future<RateQuote> quote(int usdcCents, String currency) =>
      _rail.quote(usdcCents: usdcCents, currency: currency);

  Future<PartnerResult> convert(RateQuote q) async {
    if (q.usdcCents > balanceCents) {
      return const PartnerResult(ok: false, reference: '', message: 'Not enough USDC', sandbox: true);
    }
    final r = await _rail.convert(q);
    if (r.ok) {
      state = [
        UsdcEntry(
          label: 'Converted to ${q.currency}',
          usdcCents: -q.usdcCents,
          outCurrency: q.currency,
          outMinor: q.outMinor,
          reference: r.reference,
          at: DateTime.now(),
        ),
        ...state
      ];
      _save();
    }
    return r;
  }
}

final usdcWalletProvider = StateNotifierProvider<UsdcWalletNotifier, List<UsdcEntry>>(
    (ref) => UsdcWalletNotifier(ref.watch(stablecoinRailProvider)));

// ── FX agent: rate watches ───────────────────────────────────────────────

class RateWatch {
  final String id;
  final String pair; // 'USD/NGN'
  final double target; // alert when rate >= target
  final int usdcCents; // amount to convert when it triggers
  final bool autoConvert; // false = alert only
  final DateTime? firedAt;

  const RateWatch({
    required this.id,
    required this.pair,
    required this.target,
    required this.usdcCents,
    required this.autoConvert,
    this.firedAt,
  });

  RateWatch fired() => RateWatch(
      id: id, pair: pair, target: target, usdcCents: usdcCents, autoConvert: autoConvert, firedAt: DateTime.now());

  Map<String, dynamic> toJson() => {
        'id': id,
        'p': pair,
        't': target,
        'u': usdcCents,
        'auto': autoConvert,
        'f': firedAt?.toIso8601String(),
      };

  static RateWatch fromJson(Map<String, dynamic> j) => RateWatch(
        id: '${j['id']}',
        pair: '${j['p']}',
        target: (j['t'] as num).toDouble(),
        usdcCents: (j['u'] as int?) ?? 0,
        autoConvert: j['auto'] == true,
        firedAt: readDate(j['f']),
      );
}

class RateWatchNotifier extends StateNotifier<List<RateWatch>> {
  RateWatchNotifier() : super(readJsonList(_key).map(RateWatch.fromJson).toList());
  static const _key = 'gabis.fx.watches.v1';

  void _save() => writeJson(_key, state.map((w) => w.toJson()).toList());

  void add(RateWatch w) {
    state = [w, ...state];
    _save();
  }

  void markFired(String id) {
    state = [for (final w in state) if (w.id == id) w.fired() else w];
    _save();
  }

  void remove(String id) {
    state = state.where((w) => w.id != id).toList();
    _save();
  }
}

final rateWatchProvider =
    StateNotifierProvider<RateWatchNotifier, List<RateWatch>>((ref) => RateWatchNotifier());
