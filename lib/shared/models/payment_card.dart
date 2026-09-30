import 'money.dart';

enum CardScheme { visa, mastercard }

class PaymentCard {
  final String id;
  final String last4;
  final CardScheme scheme;
  final Money balance;
  final bool frozen;

  const PaymentCard({
    required this.id,
    required this.last4,
    required this.scheme,
    required this.balance,
    this.frozen = false,
  });

  PaymentCard copyWith({bool? frozen, Money? balance}) {
    return PaymentCard(
      id: id,
      last4: last4,
      scheme: scheme,
      balance: balance ?? this.balance,
      frozen: frozen ?? this.frozen,
    );
  }
}
