import 'package:intl/intl.dart';

/// Amounts are stored as integer minor units (e.g. kobo, cents) to avoid
/// floating point rounding errors in financial calculations.
class Money {
  final int minorUnits;
  final String currency;

  const Money({required this.minorUnits, required this.currency});

  factory Money.zero(String currency) => Money(minorUnits: 0, currency: currency);

  double get major => minorUnits / 100;

  static const _symbols = {
    'NGN': '₦',
    'USD': '\$',
    'GHS': 'GH₵',
    'KES': 'KSh',
    'EUR': '€',
    'GBP': '£',
  };

  String get symbol => _symbols[currency] ?? '$currency ';

  String format({bool showSymbol = true}) {
    final formatted = NumberFormat('#,##0.00').format(major);
    return showSymbol ? '$symbol$formatted' : formatted;
  }

  Money copyWith({int? minorUnits, String? currency}) {
    return Money(
      minorUnits: minorUnits ?? this.minorUnits,
      currency: currency ?? this.currency,
    );
  }

  Money operator +(Money other) {
    assert(currency == other.currency, 'Cannot add different currencies');
    return copyWith(minorUnits: minorUnits + other.minorUnits);
  }

  Money operator -(Money other) {
    assert(currency == other.currency, 'Cannot subtract different currencies');
    return copyWith(minorUnits: minorUnits - other.minorUnits);
  }

  @override
  String toString() => format();
}
