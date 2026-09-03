import 'dart:convert';

import 'package:http/http.dart' as http;

import 'business_store.dart';
import 'payment_link.dart';
import '../../core/firebase/user_sync.dart';

/// The app's end of the chaser in firebase/functions.
///
/// Everything up to now needed somebody to be holding the phone. Handing the
/// queue to a scheduled function is what makes reminders autonomous, and it
/// rides on the Firestore document this account already syncs — so there is no
/// second store to run, no service token to hand out, and no separate notion
/// of who a business is. Firebase Auth already answered that.
///
/// It is still the first time a customer's details leave the device, so it is
/// opt-in and it carries the least a reminder needs: a name, a number, what is
/// owed, when it was due, and the lawful basis for holding the number.
///
/// Not sent: invoice descriptions, emails, addresses. The statement link is
/// built here and travels as an opaque string — its contents live in the URL
/// fragment, which never reaches Firestore or any server.
class AutonomousReminders {
  static const _doc = 'collections';

  /// The scheduled worker that reads the queue. Asked before the switch is
  /// offered, so nothing is ever presented as armed when the rail behind it
  /// cannot send.
  static const chaser = String.fromEnvironment('CHASER_URL',
      defaultValue: 'https://gabis-chaser.gabis-chaser.workers.dev');

  final UserSync _sync;
  final http.Client _http;

  AutonomousReminders([UserSync? sync, http.Client? client])
      : _sync = sync ?? UserSync(),
        _http = client ?? http.Client();

  /// One row per overdue payer: what the chaser needs to decide and to write.
  static List<Map<String, dynamic>> payload(
    BusinessState state, {
    PaymentDestination? payTo,
  }) =>
      [
        for (final payer in state.defaulters)
          {
            'name': payer.name,
            'phone': payer.phone,
            'outstanding': payer.outstanding,
            'currency': 'NGN',
            'due_on': payer.nextDueDate.toIso8601String().split('T').first,
            'consent_basis': payer.consentBasis,
            'do_not_contact': payer.doNotContact ? 1 : 0,
            'portal_link':
                PortalLink.forClient(payer.name, state.invoices, payTo),
          }
      ];

  /// Pushes the queue and says whether the chaser may act on it. Returns how
  /// many people were queued, or null when the write did not land.
  Future<int?> sync(
    BusinessState state, {
    required bool autonomous,
    PaymentDestination? payTo,
  }) async {
    final debtors = payload(state, payTo: payTo);

    // Replaced wholesale rather than merged: somebody paid off or deleted in
    // the app must stop being chased, and a partial update is a way to get
    // that wrong.
    final ok = await _sync.put(_doc, {
      'autonomous': autonomous,
      'business': state.companies.isEmpty ? 'gabis' : state.companies.first.name,
      'debtors': debtors,
    });

    return ok ? debtors.length : null;
  }

  /// Whether the chaser is currently allowed to act for this account.
  Future<bool> isOn() async {
    final doc = await _sync.get(_doc);
    return doc?['autonomous'] == true;
  }

  /// What the rail can actually do today: whether it can reach Firestore at
  /// all, and whether it can send or only rehearse. Null when it cannot be
  /// reached, which is different again from reaching it and finding it unset.
  Future<ChaserStatus?> status() async {
    try {
      final response = await _http
          .get(Uri.parse('$chaser/status'))
          .timeout(const Duration(seconds: 6));
      if (response.statusCode != 200) return null;

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return ChaserStatus(
        configured: body['configured'] == true,
        sends: body['sends'] == true,
        schedule: body['schedule'] as String? ?? '',
      );
    } catch (_) {
      return null;
    }
  }
}

/// What the scheduled worker says about itself.
class ChaserStatus {
  /// It can read the queue. False means it runs and does nothing.
  final bool configured;

  /// It can send. False means it writes down what it would have sent.
  final bool sends;

  final String schedule;

  const ChaserStatus({
    required this.configured,
    required this.sends,
    required this.schedule,
  });
}
