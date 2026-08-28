import 'money.dart';

enum TransactionStatus { pending, processing, completed, failed, reversed }

enum TransactionType { transfer, cardPayment, billPayment, deposit, withdrawal, fee, fx }

class AppTransaction {
  final String id;
  final TransactionType type;
  final TransactionStatus status;
  final Money amount;
  final Money? fee;
  final String? description;
  final String? counterparty;
  final DateTime createdAt;
  final bool isCredit;

  const AppTransaction({
    required this.id,
    required this.type,
    required this.status,
    required this.amount,
    this.fee,
    this.description,
    this.counterparty,
    required this.createdAt,
    this.isCredit = false,
  });
}
