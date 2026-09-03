import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:nautik_money/features/business/business_store.dart';
import 'package:nautik_money/features/business/contact_policy.dart';
import 'package:nautik_money/features/business/outreach.dart';
import 'package:nautik_money/features/business/payment_link.dart';

Payer _payer({bool doNotContact = false}) => Payer(
      name: 'Adaeze Okafor',
      email: 'adaeze@example.com',
      totalAmount: 300000,
      installments: 1,
      nextDueDate: DateTime.now(),
      doNotContact: doNotContact,
      consentBasis: 'contract',
    );

CallLog _call({required DateTime at, String outcome = 'no_answer'}) => CallLog(
      payerName: 'Adaeze Okafor',
      company: 'Gabis Ventures',
      amount: 300000,
      placedAt: at,
      tone: 'Manual outreach',
      outcome: outcome,
      transcript: const [],
    );

void main() {
  group('ContactPolicy', () {
    // Midday, so the hours rule never decides these on its own.
    final noon = DateTime(2026, 9, 3, 12);

    test('counts the attempt so the wording can follow it', () {
      final first = ContactPolicy.check(
          payer: _payer(), priorCalls: const [], now: noon);
      expect(first.allowed, isTrue);
      expect(first.attempt, 1);

      final second = ContactPolicy.check(
        payer: _payer(),
        priorCalls: [_call(at: noon.subtract(const Duration(days: 2)))],
        now: noon,
      );
      expect(second.allowed, isTrue);
      expect(second.attempt, 2);
    });

    test('a refusal ends the automated reminders', () {
      final decision = ContactPolicy.check(
        payer: _payer(),
        priorCalls: [
          _call(at: noon.subtract(const Duration(days: 2)), outcome: 'refused'),
        ],
        now: noon,
      );
      expect(decision.allowed, isFalse);
      expect(decision.reason, contains('refused'));
    });

    test('still stops at one a day and three a week', () {
      final sameDay = ContactPolicy.check(
        payer: _payer(),
        priorCalls: [_call(at: noon.subtract(const Duration(hours: 3)))],
        now: noon,
      );
      expect(sameDay.allowed, isFalse);

      final week = ContactPolicy.check(
        payer: _payer(),
        priorCalls: [
          for (var d = 1; d <= 3; d++)
            _call(at: noon.subtract(Duration(days: d))),
        ],
        now: noon,
      );
      expect(week.allowed, isFalse);
    });
  });

  group('chaseMessage', () {
    String at(int attempt) => Outreach.chaseMessage(
          name: 'Adaeze Okafor',
          company: 'Gabis Ventures',
          outstanding: 150000,
          daysOverdue: 10,
          attempt: attempt,
        );

    test('escalates without threatening anything', () {
      expect(at(1), contains('reply here if you need a new date'));
      expect(at(2), contains('have not heard back'));
      expect(at(3), contains('last automated reminder'));
      for (final n in [1, 2, 3]) {
        expect(at(n), contains('Adaeze'));
        expect(at(n), isNot(contains('legal')));
      }
    });

    test('carries the link when there is one', () {
      final m = Outreach.chaseMessage(
        name: 'Adaeze Okafor',
        company: 'Gabis Ventures',
        outstanding: 150000,
        daysOverdue: 2,
        payLink: 'https://gabis.pages.dev/portal#abc',
      );
      expect(m, contains('https://gabis.pages.dev/portal#abc'));
    });
  });

  group('milestone invoices', () {
    test('the parts add up to the total that was agreed', () {
      final notifier = BusinessNotifier()..startEmpty();
      final parts = notifier.addMilestoneInvoices(
        client: 'Adaeze Okafor',
        total: 100000,
        description: 'Brand photography',
        parts: 3,
        daysApart: 14,
      );

      expect(parts, hasLength(3));
      expect(parts.fold<double>(0, (sum, i) => sum + i.amount), 100000);
      expect(parts.first.status, 'sent');
      expect(parts.skip(1).every((i) => i.status == 'draft'), isTrue);
      expect(parts.last.due.difference(parts.first.due).inDays, 28);
    });

    test('releasing moves only the next one', () {
      final notifier = BusinessNotifier()..startEmpty();
      final parts = notifier.addMilestoneInvoices(
        client: 'Adaeze Okafor',
        total: 90000,
        description: 'Brand photography',
        parts: 3,
        daysApart: 7,
      );

      final released = notifier.releaseNextMilestone(parts.first.agreement!);
      expect(released!.milestone, 2);
      expect(
          notifier.state.invoices
              .where((i) => i.status == 'draft')
              .map((i) => i.milestone),
          [3]);
    });
  });

  group('PortalLink', () {
    Invoice invoice(String id, String status) => Invoice(
          id: id,
          client: 'Adaeze Okafor',
          amount: 50000,
          description: 'Brand photography',
          issued: DateTime(2026, 8, 1),
          due: DateTime(2026, 8, 20),
          status: status,
        );

    test('never shows a stage that has not been billed', () {
      final link = PortalLink.forClient(
        'Adaeze Okafor',
        [invoice('M1', 'paid'), invoice('M2', 'sent'), invoice('M3', 'draft')],
        const PaymentDestination(
            bankName: 'GTBank', accountNumber: '0123456789', accountName: 'Gabis Ventures'),
      )!;

      final json = utf8.decode(base64Url.decode(link.split('#').last));
      expect(json, contains('M1'));
      expect(json, contains('M2'));
      expect(json, isNot(contains('M3')));
    });

    test('is null when the client has nothing to look at', () {
      expect(PortalLink.forClient('Nobody', [invoice('M1', 'draft')], null),
          isNull);
    });
  });
}
