import 'package:flutter_test/flutter_test.dart';
import 'package:nautik_money/features/business/invoice_ai.dart';

void main() {
  group('LocalInvoiceParser', () {
    test('reads a note pasted straight out of a chat', () {
      final d = LocalInvoiceParser.parse(
          'Tope, 08031234567, 150k, brand design balance, due next friday');
      expect(d.client, 'Tope');
      expect(d.amount, 150000);
      expect(d.phone, '08031234567');
      expect(d.dueInDays, inInclusiveRange(1, 7));
      expect(d.missing, isEmpty);
    });

    test('a phone number is never billed as an amount', () {
      final d = LocalInvoiceParser.parse('Ada 08123456789 for logo work');
      expect(d.phone, '08123456789');
      expect(d.amount, 0);
      expect(d.missing, contains('amount'));
    });

    test('handles a spaced international number and millions', () {
      final d = LocalInvoiceParser.parse(
          'invoice Acme Ltd +234 803 123 4567 2.5m for solar install, tomorrow');
      expect(d.amount, 2500000);
      expect(d.phone, '+234 803 123 4567');
      expect(d.dueInDays, 1);
    });

    test('keeps net terms working', () {
      final d = LocalInvoiceParser.parse('bill Sarah 150k for brand design, net 14');
      expect(d.client, 'Sarah');
      expect(d.dueInDays, 14);
    });

    test('refuses an implausible amount rather than inventing one', () {
      final d = LocalInvoiceParser.parse('bill Sarah 999999999999 for consulting');
      expect(d.amount, 0);
      expect(d.missing, contains('amount'));
    });
  });
}
