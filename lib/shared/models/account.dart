import 'money.dart';

enum AccountType { personal, business }

class Account {
  final String id;
  final String currency;
  final Money balance;
  final AccountType type;
  final bool active;

  const Account({
    required this.id,
    required this.currency,
    required this.balance,
    required this.type,
    this.active = true,
  });

  Account copyWith({
    String? id,
    String? currency,
    Money? balance,
    AccountType? type,
    bool? active,
  }) {
    return Account(
      id: id ?? this.id,
      currency: currency ?? this.currency,
      balance: balance ?? this.balance,
      type: type ?? this.type,
      active: active ?? this.active,
    );
  }
}
