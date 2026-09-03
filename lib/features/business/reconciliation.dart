import 'dart:convert';

import 'package:http/http.dart' as http;

import 'autonomous_reminders.dart';
import 'business_store.dart';
import 'payment_link.dart';
import '../../core/firebase/user_sync.dart';

/// Money arriving, and the invoice it belongs to, without anybody being told.
///
/// This is the join that turns an invoicing app into something that knows what
/// it is owed. Until now a customer paid into one shared account, typed the
/// invoice number into the narration if they remembered, and the business found
/// out by reading a WhatsApp message. An account minted for a single invoice is
/// its own reference: the payment identifies itself, the invoice closes itself,
/// and the reminder that was queued for tomorrow stops.
///
/// It also closes the loop the collections record was missing. An attempt that
/// was followed by money is the only evidence of what actually works, and until
/// payments landed here that evidence had to be typed in by hand, which means
/// it was never typed in at all.
class Reconciliation {
  final UserSync _sync;
  final http.Client _http;

  Reconciliation([UserSync? sync, http.Client? client])
      : _sync = sync ?? UserSync(),
        _http = client ?? http.Client();

  /// Asks for an account that belongs to this invoice alone.
  ///
  /// Null when no provider is configured, which is not a failure: the invoice
  /// keeps the account the business already gives people, and reconciliation
  /// falls back to matching on the narration.
  Future<PaymentDestination?> accountFor(Invoice invoice) async {
    final token = await UserSync.idToken();
    if (token == null) return null;

    try {
      final response = await _http
          .post(
            Uri.parse('${AutonomousReminders.chaser}/accounts'),
            headers: {
              'authorization': 'Bearer $token',
              'content-type': 'application/json',
            },
            body: jsonEncode({
              'invoice': invoice.id,
              'name': invoice.client,
              'phone': invoice.clientPhone,
            }),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) return null;
      final body = jsonDecode(response.body) as Map<String, dynamic>;

      return PaymentDestination(
        bankName: body['bank'] as String? ?? '',
        accountNumber: body['account'] as String? ?? '',
        accountName: body['name'] as String? ?? invoice.client,
      );
    } catch (_) {
      return null;
    }
  }

  /// Applies whatever has arrived since the last look.
  ///
  /// Returns the invoices that were closed by it, so the caller can offer the
  /// receipts. Each payment is removed once applied; applying one twice is
  /// prevented by the invoice already being paid, not by that delete.
  Future<List<Invoice>> apply(BusinessNotifier notifier) async {
    final payments = await _sync.list('collections', 'payments');
    if (payments.isEmpty) return const [];

    final closed = <Invoice>[];

    for (final payment in payments) {
      final id = payment['invoice'] as String?;
      final amount = (payment['amount'] as num?)?.toDouble() ?? 0;
      if (id == null) continue;

      final invoice = notifier.state.invoices
          .where((i) => i.id == id && i.status != 'paid')
          .toList();

      if (invoice.isNotEmpty) {
        notifier.markInvoicePaid(id);
        // The attempt that preceded the money is the one that earned it. Which
        // language, hour and channel that was is the only thing here nobody
        // else can copy, and it is only worth anything if it is written down.
        notifier.creditLastAttempt(invoice.first.client, amount);
        closed.add(invoice.first);
      }

      await _sync.remove('collections', 'payments', payment['id'] as String);
    }

    return closed;
  }
}
