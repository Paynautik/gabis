import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/account.dart';
import '../models/money.dart';
import '../models/payment_card.dart';
import '../models/transaction.dart';

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);
final authStateProvider = StateProvider<bool>((ref) => false);
final isBusinessModeProvider = StateProvider<bool>((ref) => false);
final userAvatarProvider = StateProvider<String?>((ref) => null);
final userNameProvider = Provider<String>((ref) => 'Raphael');

// --- Accounts Stateful StateNotifier ---
class AccountsNotifier extends StateNotifier<List<Account>> {
  AccountsNotifier()
      : super([
          Account(
            id: 'acc_ngn',
            currency: 'NGN',
            balance: const Money(minorUnits: 125000000, currency: 'NGN'),
            type: AccountType.personal,
          ),
          Account(
            id: 'acc_usd',
            currency: 'USD',
            balance: const Money(minorUnits: 82000, currency: 'USD'),
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

final accountsProvider = StateNotifierProvider<AccountsNotifier, List<Account>>((ref) {
  return AccountsNotifier();
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
  TransactionsNotifier() : super(_seedHistory());

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

final transactionsProvider = StateNotifierProvider<TransactionsNotifier, List<AppTransaction>>((ref) {
  return TransactionsNotifier();
});

// --- Cards Stateful StateNotifier ---
class CardsNotifier extends StateNotifier<List<PaymentCard>> {
  CardsNotifier()
      : super([
          const PaymentCard(
            id: 'card_1',
            last4: '4821',
            scheme: CardScheme.visa,
            balance: Money(minorUnits: 82000, currency: 'USD'),
          ),
        ]);

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

final cardsProvider = StateNotifierProvider<CardsNotifier, List<PaymentCard>>((ref) {
  return CardsNotifier();
});

final fxRateProvider = Provider<double>((ref) => 1524.0);
