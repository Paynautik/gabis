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

    test('two agreements on one day do not share an id', () {
      final notifier = BusinessNotifier()..startEmpty();
      final at = DateTime(2026, 9, 3, 14, 30);

      final first = notifier.addMilestoneInvoices(
        client: 'Adaeze Okafor',
        total: 90000,
        description: 'Brand photography',
        parts: 3,
        daysApart: 7,
        from: at,
      );

      // Deleting one puts the counter back where it was, which is how the
      // second agreement used to land on the first one's id.
      notifier.deleteInvoice(first.last.id);

      final second = notifier.addMilestoneInvoices(
        client: 'Chidi Nwosu',
        total: 60000,
        description: 'Studio hire',
        parts: 2,
        daysApart: 7,
        from: at,
      );

      expect(second.first.agreement, isNot(first.first.agreement));
      expect(
          notifier.state.invoices
              .where((i) => i.agreement == first.first.agreement)
              .map((i) => i.client)
              .toSet(),
          {'Adaeze Okafor'});
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

  group('what works', () {
    BusinessState book(List<CallLog> calls) => BusinessState(
          companies: const [],
          invoices: const [],
          calls: calls,
          filings: const [],
        );

    CallLog attempt({
      required String language,
      required bool paid,
      String name = 'Adaeze Okafor',
    }) =>
        CallLog(
          payerName: name,
          company: 'Gabis Ventures',
          amount: 50000,
          placedAt: DateTime(2026, 9, 3, 10),
          tone: 'Manual outreach',
          outcome: paid ? 'paid' : 'no_answer',
          transcript: const [],
          language: language,
        );

    test('says nothing at all on a handful of attempts', () {
      final thin = book([
        for (var i = 0; i < 6; i++)
          attempt(language: 'Pidgin', paid: i.isEven),
      ]);

      expect(thin.whatWorks, isEmpty);
      expect(thin.attemptsUntilInsight, 6);
    });

    test('names the approach that beats the average', () {
      final measured = book([
        for (var i = 0; i < 8; i++) attempt(language: 'Pidgin', paid: i < 6),
        for (var i = 0; i < 8; i++) attempt(language: 'English', paid: i < 1),
      ]);

      final insights = measured.whatWorks;
      expect(insights, isNotEmpty);

      final language =
          insights.firstWhere((i) => i.dimension == 'language');
      expect(language.label, 'Pidgin');
      expect(language.lift, greaterThan(1));
      expect(language.sentence, contains('Pidgin'));
      expect(measured.attemptsUntilInsight, 0);
    });

    test('a bucket too small to mean anything is not reported', () {
      // Two perfect attempts in Yoruba against a long English record: a real
      // rate of 100% and no evidence whatsoever.
      final lopsided = book([
        for (var i = 0; i < 14; i++) attempt(language: 'English', paid: i < 4),
        for (var i = 0; i < 2; i++) attempt(language: 'Yoruba', paid: true),
      ]);

      expect(
          lopsided.whatWorks.where((i) => i.label == 'Yoruba'), isEmpty);
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
