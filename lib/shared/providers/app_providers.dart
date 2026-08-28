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
  TransactionsNotifier()
      : super([
          AppTransaction(
            id: 'tx_1',
            type: TransactionType.billPayment,
            status: TransactionStatus.completed,
            amount: const Money(minorUnits: 2500000, currency: 'NGN'),
            description: 'Netflix subscription',
            counterparty: 'Netflix',
            createdAt: DateTime.now().subtract(const Duration(hours: 3)),
          ),
          AppTransaction(
            id: 'tx_2',
            type: TransactionType.transfer,
            status: TransactionStatus.completed,
            amount: const Money(minorUnits: 45000000, currency: 'NGN'),
            description: 'Acme Invoice Payment',
            counterparty: 'Acme Ltd',
            createdAt: DateTime.now().subtract(const Duration(hours: 8)),
            isCredit: true,
          ),
          AppTransaction(
            id: 'tx_3',
            type: TransactionType.billPayment,
            status: TransactionStatus.completed,
            amount: const Money(minorUnits: 8000000, currency: 'NGN'),
            description: 'Electricity bill',
            counterparty: 'IKEDC',
            createdAt: DateTime.now().subtract(const Duration(days: 1)),
          ),
        ]);

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
