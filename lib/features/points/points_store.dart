import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/firebase/user_sync.dart';

import '../business/business_persistence_stub.dart'
    if (dart.library.js_interop) '../business/business_persistence_web.dart';

/// Gabis Points: earned by using the account, spent on things people in
/// Nigeria actually want — airtime, data, a fee-free transfer, cashback.
///
/// The ledger is the truth: a balance nobody can explain is a balance nobody
/// trusts, so every point in and out is a dated entry with a reason.

enum PointsKind { earned, redeemed }

class PointsEntry {
  final int amount; // positive earned, negative redeemed
  final String reason;
  final DateTime at;
  final PointsKind kind;

  const PointsEntry({
    required this.amount,
    required this.reason,
    required this.at,
    required this.kind,
  });

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'reason': reason,
        'at': at.toIso8601String(),
        'kind': kind.name,
      };

  static PointsEntry fromJson(Map<String, dynamic> m) => PointsEntry(
        amount: m['amount'] as int,
        reason: m['reason'] as String,
        at: DateTime.parse(m['at'] as String),
        kind: m['kind'] == 'redeemed' ? PointsKind.redeemed : PointsKind.earned,
      );
}

/// Something a balance can be turned into.
class Reward {
  final String id;
  final String title;
  final String detail;
  final int cost;
  final String category;

  const Reward({
    required this.id,
    required this.title,
    required this.detail,
    required this.cost,
    required this.category,
  });
}

const rewardCatalogue = <Reward>[
  Reward(
      id: 'airtime_500',
      title: '₦500 airtime',
      detail: 'Any network, delivered to your number.',
      cost: 500,
      category: 'AIRTIME & DATA'),
  Reward(
      id: 'data_1gb',
      title: '1GB data bundle',
      detail: 'MTN, Airtel, Glo or 9mobile.',
      cost: 800,
      category: 'AIRTIME & DATA'),
  Reward(
      id: 'airtime_2000',
      title: '₦2,000 airtime',
      detail: 'For when the month has been long.',
      cost: 1800,
      category: 'AIRTIME & DATA'),
  Reward(
      id: 'fee_free_5',
      title: '5 fee-free transfers',
      detail: 'No transfer fee on your next five sends.',
      cost: 600,
      category: 'FEES'),
  Reward(
      id: 'fx_zero',
      title: 'Zero-fee currency swap',
      detail: 'One conversion at the mid-market rate, no fee.',
      cost: 1200,
      category: 'FEES'),
  Reward(
      id: 'card_free',
      title: 'Free virtual card',
      detail: 'Skip the issuing fee on your next card.',
      cost: 1000,
      category: 'FEES'),
  Reward(
      id: 'cashback_1000',
      title: '₦1,000 cashback',
      detail: 'Paid straight into your naira balance.',
      cost: 2000,
      category: 'CASH'),
  Reward(
      id: 'bill_2500',
      title: '₦2,500 off a bill',
      detail: 'Electricity, subscriptions or airtime.',
      cost: 4500,
      category: 'CASH'),
];

/// How points are earned, shown to the user so the rate is never a mystery.
const earnRules = <(String, String, String)>[
  ('Send money', '1 pt per ₦1,000 sent', 'Local and international transfers.'),
  ('Pay a bill', '25 pts per bill', 'Airtime, data, electricity, subscriptions.'),
  ('Invoice paid', '50 pts', 'When a customer settles an invoice you raised.'),
  ('Swap currency', '10 pts per swap', 'Any pair, any direction.'),
  ('Payday sweep', '30 pts', 'Each time you move spare money into savings.'),
];

class PointsState {
  final int balance;
  final List<PointsEntry> entries;

  /// Points just claimed from the landing-page game, so the app can tell the
  /// user their catch actually landed. Cleared once shown.
  final int justClaimed;

  const PointsState({
    this.balance = 0,
    this.entries = const [],
    this.justClaimed = 0,
  });

  int get lifetimeEarned => entries
      .where((e) => e.kind == PointsKind.earned)
      .fold(0, (s, e) => s + e.amount);

  int get lifetimeSpent => entries
      .where((e) => e.kind == PointsKind.redeemed)
      .fold(0, (s, e) => s - e.amount);

  /// Tier is cosmetic, but it should follow real activity rather than a guess.
  String get tier {
    if (lifetimeEarned >= 10000) return 'Gold';
    if (lifetimeEarned >= 3000) return 'Silver';
    return 'Bronze';
  }

  int get toNextTier {
    if (lifetimeEarned >= 10000) return 0;
    if (lifetimeEarned >= 3000) return 10000 - lifetimeEarned;
    return 3000 - lifetimeEarned;
  }

  PointsState copyWith({
    int? balance,
    List<PointsEntry>? entries,
    int? justClaimed,
  }) =>
      PointsState(
        balance: balance ?? this.balance,
        entries: entries ?? this.entries,
        justClaimed: justClaimed ?? this.justClaimed,
      );
}

class PointsNotifier extends StateNotifier<PointsState> {
  PointsNotifier() : super(_restore()) {
    claimPending();
    _pullRemote();
  }

  final _sync = UserSync();

  /// On sign-in the account's balance is the truth — but never downwards.
  /// Points earned offline on this device are merged up rather than dropped.
  Future<void> _pullRemote() async {
    final remote = await _sync.get('points');

    // A fresh account has no document yet — seed it, so the wallet exists on
    // the server the first time rather than only after the first change.
    if (remote == null) {
      _push();
      return;
    }

    final remoteBalance = (remote['balance'] as num?)?.toInt() ?? 0;
    final remoteEntries = (remote['entries'] as List?)
            ?.map((e) => PointsEntry.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList() ??
        const <PointsEntry>[];

    if (remoteBalance <= state.balance && remoteEntries.length <= state.entries.length) {
      _push();
      return;
    }

    state = state.copyWith(
      balance: remoteBalance > state.balance ? remoteBalance : state.balance,
      entries: remoteEntries.length > state.entries.length
          ? remoteEntries
          : state.entries,
    );
  }

  void _push() {
    _sync.put('points', {
      'balance': state.balance,
      'entries': state.entries.take(100).map((e) => e.toJson()).toList(),
    });
  }

  static const _key = 'gabis.points.v1';

  /// Points caught on the landing page before signing in. They are banked
  /// under their own key; the first time the wallet loads, they are claimed
  /// into the balance and the pending key is cleared so they cannot be
  /// counted twice.
  static const _pendingKey = 'gabis.points.pending';

  void claimPending() {
    final raw = readRaw(_pendingKey);
    final pending = raw == null ? 0 : (int.tryParse(raw) ?? 0);
    if (pending <= 0) return;

    writeRaw(_pendingKey, '0');
    state = state.copyWith(
      justClaimed: pending,
      balance: state.balance + pending,
      entries: [
        PointsEntry(
            amount: pending,
            reason: 'Caught orbs on gabispay.com',
            at: DateTime.now(),
            kind: PointsKind.earned),
        ...state.entries,
      ],
    );
  }

  static PointsState _restore() {
    final raw = readRaw(_key);
    if (raw == null) return _seed();
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return PointsState(
        balance: map['balance'] as int,
        entries: (map['entries'] as List)
            .map((e) => PointsEntry.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } catch (_) {
      return _seed();
    }
  }

  /// A new account starts at zero — the wallet fills as the person uses it,
  /// or from points caught on the landing page. Example entries only appear
  /// when demo data is switched on.
  static PointsState _seed() {
    if (readRaw('gabis.demoData') != 'on') return const PointsState();
    return _demoSeed();
  }

  static PointsState _demoSeed() {
    final now = DateTime.now();
    final entries = [
      PointsEntry(
          amount: 50,
          reason: 'Invoice INV-2482 paid',
          at: now.subtract(const Duration(days: 1)),
          kind: PointsKind.earned),
      PointsEntry(
          amount: 25,
          reason: 'MTN airtime purchase',
          at: now.subtract(const Duration(days: 3)),
          kind: PointsKind.earned),
      PointsEntry(
          amount: 120,
          reason: 'Transfer to Deji Adewusi',
          at: now.subtract(const Duration(days: 5)),
          kind: PointsKind.earned),
      PointsEntry(
          amount: 30,
          reason: 'Payday sweep to savings',
          at: now.subtract(const Duration(days: 9)),
          kind: PointsKind.earned),
      PointsEntry(
          amount: 2255,
          reason: 'Welcome bonus',
          at: now.subtract(const Duration(days: 12)),
          kind: PointsKind.earned),
    ];
    return PointsState(
      balance: entries.fold(0, (s, e) => s + e.amount),
      entries: entries,
    );
  }

  @override
  set state(PointsState value) {
    super.state = value;
    _sync.put('points', {
      'balance': value.balance,
      'entries': value.entries.take(100).map((e) => e.toJson()).toList(),
    });
    writeRaw(
      _key,
      jsonEncode({
        'balance': value.balance,
        'entries': value.entries.map((e) => e.toJson()).toList(),
      }),
    );
  }

  /// Called once the arrival has been announced.
  void acknowledgeClaim() {
    if (state.justClaimed == 0) return;
    state = state.copyWith(justClaimed: 0);
  }

  void earn(int amount, String reason) {
    if (amount <= 0) return;
    state = state.copyWith(
      balance: state.balance + amount,
      entries: [
        PointsEntry(
            amount: amount,
            reason: reason,
            at: DateTime.now(),
            kind: PointsKind.earned),
        ...state.entries,
      ],
    );
  }

  /// Returns false when the balance will not cover it, so the caller can say so
  /// rather than silently doing nothing.
  bool redeem(Reward reward) {
    if (state.balance < reward.cost) return false;
    state = state.copyWith(
      balance: state.balance - reward.cost,
      entries: [
        PointsEntry(
            amount: -reward.cost,
            reason: reward.title,
            at: DateTime.now(),
            kind: PointsKind.redeemed),
        ...state.entries,
      ],
    );
    return true;
  }
}

final pointsProvider =
    StateNotifierProvider<PointsNotifier, PointsState>((ref) => PointsNotifier());
