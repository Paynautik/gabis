import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/account.dart';
import '../models/money.dart';
import '../models/payment_card.dart';
import '../models/transaction.dart';
import '../../core/firebase/auth_service.dart';
import '../../core/firebase/user_sync.dart';
import '../../features/business/business_persistence_stub.dart'
    if (dart.library.js_interop) '../../features/business/business_persistence_web.dart';

/// Whether to fill the app with example data.
///
/// Off by default: someone who has just opened an account should see their own
/// empty account, not a stranger's ₦2.5m and three months of somebody else's
/// groceries. Kept on for demos and screenshots, and remembered per browser.
class DemoDataNotifier extends StateNotifier<bool> {
  DemoDataNotifier() : super(readRaw(_key) == 'on') {
    _pullRemote();
  }

  static const _key = 'gabis.demoData';

  final _sync = UserSync();

  /// The local copy is read synchronously at startup so the first frame is
  /// correct; the account's own setting then arrives and wins, so signing in
  /// on a borrowed machine does not inherit its demo state.
  Future<void> _pullRemote() async {
    final prefs = await _sync.get('prefs');
    final remote = prefs?['demoData'];
    if (remote is! bool || remote == state) return;

    state = remote;
    writeRaw(_key, remote ? 'on' : 'off');
  }

  void set(bool value) {
    state = value;
    writeRaw(_key, value ? 'on' : 'off');
    _sync.put('prefs', {'demoData': value});
  }
}

final demoDataProvider =
    StateNotifierProvider<DemoDataNotifier, bool>((ref) => DemoDataNotifier());

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);
final authStateProvider = StateProvider<bool>((ref) => false);

/// Which tab the home shell is showing. Held here so anything on screen — a
/// promo card, a snackbar action — can send the user to the right place.
final homeTabProvider = StateProvider<int>((ref) => 0);
final isBusinessModeProvider = StateProvider<bool>((ref) => false);
/// The picture on the account: null for initials, `fun:<n>` for one of the
/// generated characters, `photo:<base64>` for an uploaded one.
///
/// Stored the same way as the name — locally so the first frame is right, and
/// in Firestore so the picture follows the account to another device.
class UserAvatarNotifier extends StateNotifier<String?> {
  UserAvatarNotifier() : super(readRaw(_key)) {
    _pullRemote();
  }

  static const _key = 'gabis.profile.avatar';

  /// A picture is stored inline with the account document, which Firestore
  /// caps at 1MB. Anything bigger stays on this device rather than failing the
  /// write and losing it everywhere.
  static const _maxRemoteChars = 600 * 1024;

  final _sync = UserSync();

  Future<void> _pullRemote() async {
    final profile = await _sync.get('profile');
    final remote = profile?['avatar'];
    if (remote is! String || remote.isEmpty || remote == state) return;
    state = remote;
    writeRaw(_key, remote);
  }

  Future<void> setPhoto(Uint8List bytes) =>
      _write('photo:${base64Encode(bytes)}');

  Future<void> setFun(int index) => _write('fun:$index');

  /// Back to initials, which is the absence of a picture rather than a
  /// third kind of one.
  Future<void> clear() async {
    state = null;
    removeRaw(_key);
    await _sync.put('profile', {'avatar': null});
  }

  Future<void> _write(String value) async {
    state = value;
    writeRaw(_key, value);
    if (value.length > _maxRemoteChars) return;
    await _sync.put('profile', {'avatar': value});
  }
}

final userAvatarProvider = StateNotifierProvider<UserAvatarNotifier, String?>(
    (ref) => UserAvatarNotifier());
/// The name the account holder chose, held locally so the first frame is right
/// and synced to Firestore so it follows them to another device.
///
/// Accounts created before sign-up asked for a name have no displayName; this
/// is how they set one without registering again.
class ProfileNameNotifier extends StateNotifier<String?> {
  ProfileNameNotifier(this._ref) : super(readRaw(_key)) {
    _pullRemote();
  }

  static const _key = 'gabis.profile.name';

  final Ref _ref;
  final _sync = UserSync();

  Future<void> _pullRemote() async {
    final profile = await _sync.get('profile');
    final remote = profile?['name'];
    if (remote is! String || remote.trim().isEmpty || remote == state) return;
    state = remote;
    writeRaw(_key, remote);
  }

  /// Writes all three copies: memory, this browser, and the account.
  Future<void> set(String name) async {
    final clean = name.trim();
    if (clean.isEmpty) return;

    state = clean;
    writeRaw(_key, clean);
    await _sync.put('profile', {'name': clean});
    await _ref.read(authServiceProvider).updateName(clean);
  }
}

final profileNameProvider =
    StateNotifierProvider<ProfileNameNotifier, String?>(
        (ref) => ProfileNameNotifier(ref));

/// The account holder's name, as given when they registered.
///
/// Firebase's displayName is the source; an account created before the sign-up
/// form asked for a name falls back to the email local part, so a card or a
/// greeting never shows somebody else's name.
final userNameProvider = Provider<String>((ref) {
  // A name set in the profile wins: it is the most recent thing the person
  // told us, and it is there before Firebase's cached profile catches up.
  final chosen = ref.watch(profileNameProvider)?.trim();
  if (chosen != null && chosen.isNotEmpty) return chosen;

  final user = ref.watch(authUserProvider).value;

  final name = user?.displayName?.trim();
  if (name != null && name.isNotEmpty) return name;

  final email = user?.email;
  if (email != null && email.contains('@')) {
    final local = email.split('@').first.replaceAll(RegExp(r'[._+-]+'), ' ').trim();
    if (local.isNotEmpty) {
      return local
          .split(RegExp(r'\s+'))
          .map((w) => w[0].toUpperCase() + w.substring(1))
          .join(' ');
    }
  }

  return 'there';
});

/// Just the first name, for greetings.
final userFirstNameProvider =
    Provider<String>((ref) => ref.watch(userNameProvider).split(' ').first);

/// One or two letters for the avatar, taken from the same name.
final userInitialsProvider = Provider<String>((ref) {
  final parts = ref
      .watch(userNameProvider)
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty)
      .toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) return parts.first[0].toUpperCase();
  return (parts.first[0] + parts.last[0]).toUpperCase();
});

/// The name as it is printed on a card.
final userCardNameProvider =
    Provider<String>((ref) => ref.watch(userNameProvider).toUpperCase());

// --- Accounts Stateful StateNotifier ---
class AccountsNotifier extends StateNotifier<List<Account>> {
  AccountsNotifier({bool demo = false})
      : super([
          Account(
            id: 'acc_ngn',
            currency: 'NGN',
            balance:
                Money(minorUnits: demo ? 125000000 : 0, currency: 'NGN'),
            type: AccountType.personal,
          ),
          Account(
            id: 'acc_usd',
            currency: 'USD',
            balance: Money(minorUnits: demo ? 82000 : 0, currency: 'USD'),
            type: AccountType.personal,
          ),
        ]);

  void addAccount(Account account) {
    if (!state.any((a) => a.currency == account.currency)) {
      state = [...state, account];
    }
  }

  void addBalance(String currency, int amountMinor) {
    state = [
      for (final a in state)
        if (a.currency == currency)
          a.copyWith(balance: a.balance + Money(minorUnits: amountMinor, currency: currency))
        else
          a,
    ];
  }

  void subtractBalance(String currency, int amountMinor) {
    state = [
      for (final a in state)
        if (a.currency == currency)
          a.copyWith(balance: a.balance - Money(minorUnits: amountMinor, currency: currency))
        else
          a,
    ];
  }
}

final accountsProvider =
    StateNotifierProvider<AccountsNotifier, List<Account>>((ref) {
  return AccountsNotifier(demo: ref.watch(demoDataProvider));
});

// --- Dynamic Net Worth Calculation ---
final totalBalanceNgnProvider = Provider<Money>((ref) {
  final accounts = ref.watch(accountsProvider);
  final rate = ref.watch(fxRateProvider);
  int total = 0;
  for (final a in accounts) {
    if (a.currency == 'NGN') {
      total += a.balance.minorUnits;
    } else if (a.currency == 'USD') {
      total += (a.balance.minorUnits * rate).round();
    }
  }
  return Money(minorUnits: total, currency: 'NGN');
});

// --- Transactions Stateful StateNotifier ---
class TransactionsNotifier extends StateNotifier<List<AppTransaction>> {
  TransactionsNotifier({bool demo = false})
      : super(demo ? _seedHistory() : const []);

  /// Three months of activity so the copilot has real behaviour to reason over:
  /// salary credits, recurring bills and subscriptions, telecom top-ups,
  /// transport, food and one-off transfers.
  static List<AppTransaction> _seedHistory() {
    final now = DateTime.now();
    final txs = <AppTransaction>[];
    var seq = 0;

    AppTransaction tx({
      required TransactionType type,
      required int naira,
      required String description,
      required String counterparty,
      required DateTime at,
      bool credit = false,
    }) {
      seq++;
      return AppTransaction(
        id: 'tx_$seq',
        type: type,
        status: TransactionStatus.completed,
        amount: Money(minorUnits: naira * 100, currency: 'NGN'),
        description: description,
        counterparty: counterparty,
        createdAt: at,
        isCredit: credit,
      );
    }

    // Three full months back, most recent last (list is reversed at the end).
    for (var m = 3; m >= 0; m--) {
      final month = DateTime(now.year, now.month - m, 1);
      if (month.isAfter(now)) continue;

      DateTime day(int d) {
        final candidate = DateTime(month.year, month.month, d, 9, 30);
        return candidate.isAfter(now) ? now.subtract(Duration(hours: d)) : candidate;
      }

      // Salary — the anchor of the whole picture.
      if (day(28).isBefore(now)) {
        txs.add(tx(
          type: TransactionType.deposit,
          naira: 650000,
          description: 'Salary',
          counterparty: 'Kernel Systems Ltd',
          at: day(28),
          credit: true,
        ));
      }

      // Recurring obligations.
      txs.add(tx(type: TransactionType.transfer, naira: 180000, description: 'Rent', counterparty: 'Lekki Gardens', at: day(2)));
      txs.add(tx(type: TransactionType.transfer, naira: 80000, description: 'Family support', counterparty: 'Mrs Gab-Momoh', at: day(3)));
      txs.add(tx(type: TransactionType.billPayment, naira: 25000, description: 'Netflix subscription', counterparty: 'Netflix', at: day(6)));
      txs.add(tx(type: TransactionType.billPayment, naira: 8500, description: 'Spotify Premium', counterparty: 'Spotify', at: day(7)));
      txs.add(tx(type: TransactionType.billPayment, naira: 14000, description: 'Gym membership', counterparty: 'i-Fitness', at: day(8)));
      txs.add(tx(type: TransactionType.billPayment, naira: 21000, description: 'DStv Compact', counterparty: 'MultiChoice', at: day(9)));
      txs.add(tx(type: TransactionType.billPayment, naira: 42000, description: 'Electricity bill', counterparty: 'IKEDC', at: day(12)));

      // Telecom — climbing in the most recent month.
      final airtime = m == 0 ? 34000 : (m == 1 ? 26000 : 24000);
      txs.add(tx(type: TransactionType.billPayment, naira: airtime, description: 'MTN airtime & data', counterparty: 'MTN', at: day(11)));
      txs.add(tx(type: TransactionType.billPayment, naira: (airtime * 0.6).round(), description: 'MTN data bundle', counterparty: 'MTN', at: day(22)));

      // Everyday spend.
      txs.add(tx(type: TransactionType.cardPayment, naira: 48000, description: 'Groceries', counterparty: 'Shoprite', at: day(14)));
      txs.add(tx(type: TransactionType.cardPayment, naira: 22000, description: 'Fuel', counterparty: 'Total Energies', at: day(16)));
      txs.add(tx(type: TransactionType.cardPayment, naira: 16500, description: 'Bolt rides', counterparty: 'Bolt', at: day(18)));
      txs.add(tx(type: TransactionType.cardPayment, naira: 31000, description: 'Restaurant', counterparty: 'Chicken Republic', at: day(20)));

      // Freelance income, not every month.
      if (m != 2) {
        txs.add(tx(
          type: TransactionType.transfer,
          naira: m == 0 ? 450000 : 320000,
          description: 'Invoice payment',
          counterparty: 'Acme Ltd',
          at: day(24),
          credit: true,
        ));
      }
    }

    txs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return txs;
  }

  void addTransaction(AppTransaction tx) {
    state = [tx, ...state];
  }
}

final transactionsProvider =
    StateNotifierProvider<TransactionsNotifier, List<AppTransaction>>((ref) {
  return TransactionsNotifier(demo: ref.watch(demoDataProvider));
});

// --- Cards Stateful StateNotifier ---
class CardsNotifier extends StateNotifier<List<PaymentCard>> {
  /// A new account has no cards until one is created.
  CardsNotifier({bool demo = false})
      : super(demo
            ? const [
                PaymentCard(
                  id: 'card_1',
                  last4: '4821',
                  scheme: CardScheme.visa,
                  balance: Money(minorUnits: 82000, currency: 'USD'),
                ),
              ]
            : const []);

  void toggleFrozen(String cardId) {
    state = [
      for (final card in state)
        if (card.id == cardId) card.copyWith(frozen: !card.frozen) else card,
    ];
  }

  void addVirtualCard(PaymentCard card) {
    state = [...state, card];
  }
}

final cardsProvider =
    StateNotifierProvider<CardsNotifier, List<PaymentCard>>((ref) {
  return CardsNotifier(demo: ref.watch(demoDataProvider));
});

final fxRateProvider = Provider<double>((ref) => 1524.0);
