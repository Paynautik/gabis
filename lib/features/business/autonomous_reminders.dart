import 'dart:convert';

import 'package:http/http.dart' as http;

import 'business_store.dart';
import 'payment_link.dart';

/// The app's end of the chaser rail in workers/chaser.
///
/// Everything up to now needed somebody to be holding the phone. Handing the
/// queue to a cron job is what makes reminders autonomous, and it is also the
/// first time this app sends a customer's details anywhere, so it is opt-in,
/// it goes only when a business turns it on, and it sends the least that a
/// reminder needs: a name, a number, what is owed, when it was due, and the
/// lawful basis for having the number at all.
///
/// Not sent: invoice descriptions, emails, addresses. The statement link is
/// built here and travels as an opaque string — its contents live in the URL
/// fragment, which never reaches the worker or any server.
class AutonomousReminders {
  static const _base =
      String.fromEnvironment('CHASER_URL', defaultValue: '');
  static const _businessId =
      String.fromEnvironment('CHASER_BUSINESS_ID', defaultValue: '');
  static const _token =
      String.fromEnvironment('CHASER_TOKEN', defaultValue: '');

  /// False until the rail is wired, so the dashboard says so plainly rather
  /// than offering a switch that does nothing.
  static bool get configured =>
      _base.isNotEmpty && _businessId.isNotEmpty && _token.isNotEmpty;

  final http.Client _client;
  AutonomousReminders({http.Client? client}) : _client = client ?? http.Client();

  Map<String, String> get _headers => {
        'authorization': 'Bearer $_token',
        'x-business-id': _businessId,
        'content-type': 'application/json',
      };

  /// What the worker would be given: one row per overdue payer.
  static List<Map<String, dynamic>> payload(
    BusinessState state, {
    PaymentDestination? payTo,
  }) {
    final rows = <Map<String, dynamic>>[];
    for (final payer in state.defaulters) {
      rows.add({
        'name': payer.name,
        'phone': payer.phone,
        'outstanding': payer.outstanding,
        'currency': 'NGN',
        'due_on': payer.nextDueDate.toIso8601String().split('T').first,
        'consent_basis': payer.consentBasis,
        'do_not_contact': payer.doNotContact ? 1 : 0,
        'portal_link':
            PortalLink.forClient(payer.name, state.invoices, payTo),
      });
    }
    return rows;
  }

  /// Pushes the queue and says whether the rail may act on it. Returns the
  /// number of rows the worker accepted, or null when it refused.
  Future<int?> sync(
    BusinessState state, {
    required bool autonomous,
    PaymentDestination? payTo,
  }) async {
    if (!configured) return null;

    try {
      final response = await _client.post(
        Uri.parse('$_base/sync'),
        headers: _headers,
        body: jsonEncode({
          'autonomous': autonomous,
          'debtors': payload(state, payTo: payTo),
        }),
      );
      if (response.statusCode != 200) return null;
      return (jsonDecode(response.body)['debtors'] as num?)?.toInt();
    } catch (_) {
      return null;
    }
  }

  /// What would go out on the next pass, so it can be read before it does.
  Future<List<Map<String, dynamic>>> queue() async {
    if (!configured) return const [];
    try {
      final response =
          await _client.get(Uri.parse('$_base/queue'), headers: _headers);
      if (response.statusCode != 200) return const [];
      return ((jsonDecode(response.body)['items'] as List?) ?? [])
          .cast<Map<String, dynamic>>();
    } catch (_) {
      return const [];
    }
  }
}
