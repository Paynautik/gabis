import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'business_store.dart';
import 'payment_link.dart';

/// Real ways to reach someone who owes you money.
///
/// These are device hand-offs — WhatsApp, the SMS composer, the dialler, the
/// mail client — so they work today with no backend and no telecom account.
/// Server-side sending (Africa's Talking voice/SMS, WhatsApp Business API)
/// slots in behind the same call sites when the credentials exist.
class Outreach {
  /// Africa's Talking and WhatsApp both want digits with a country code and
  /// no punctuation.
  static String normalise(String phone) {
    var p = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (p.startsWith('+')) p = p.substring(1);
    if (p.startsWith('0')) p = '234${p.substring(1)}'; // default NG
    return p;
  }

  /// The reminder, written for the attempt it actually is.
  ///
  /// A third reminder that reads exactly like the first is how a business
  /// teaches someone that reminders can be ignored; one that escalates into a
  /// threat is how it loses the customer and, under the NDPR, invites a
  /// complaint. So the tone firms up and the ask gets more specific, the last
  /// one says plainly that the automated reminders stop and a person takes
  /// over, and none of them threaten anything the business has not decided to
  /// do.
  static String chaseMessage({
    required String name,
    required String company,
    required double outstanding,
    required int daysOverdue,
    String? invoiceId,
    int attempt = 1,
    String? payLink,
  }) {
    final first = name.split(' ').first;
    final ref = invoiceId == null ? '' : ' ($invoiceId)';
    final owed = formatFull(outstanding);
    final late = daysOverdue == 1 ? '1 day' : '$daysOverdue days';
    final pay = payLink == null ? '' : '\n\nPay here: $payLink';

    if (attempt <= 1) {
      final timing = daysOverdue > 0
          ? 'was due $late ago'
          : 'is due shortly';
      return 'Hello $first, this is $company. '
          'Your balance of $owed$ref $timing. '
          'You can pay from your gabis app, or reply here if you need a new date. '
          'Thank you.$pay';
    }

    if (attempt == 2) {
      return 'Hello $first, $company again about $owed$ref, '
          '${daysOverdue > 0 ? 'now $late overdue' : 'due shortly'}. '
          'We have not heard back on the first reminder. '
          'Can you pay today, or reply with the date you will pay so we can hold it? '
          'Thank you.$pay';
    }

    return 'Hello $first. This is the last automated reminder from $company '
        'about $owed$ref, ${daysOverdue > 0 ? '$late overdue' : 'now due'}. '
        'After this someone from $company will contact you directly to agree how '
        'it will be settled. If you have already paid, reply with the date and '
        'we will match it. Thank you.$pay';
  }

  /// The proof of payment a vendor currently types by hand, or does not send
  /// at all. WhatsApp renders *asterisks* as bold, which is why it is written
  /// this way rather than as prose.
  static String receiptMessage({
    required Invoice invoice,
    required String company,
    DateTime? paidAt,
  }) {
    final at = paidAt ?? DateTime.now();
    return '*PAYMENT RECEIVED*\n'
        '\n'
        '*From:* ${invoice.client}\n'
        '*Invoice:* ${invoice.id}\n'
        '*Amount:* ${formatFull(invoice.amount)}\n'
        '*For:* ${invoice.description}\n'
        '*Date:* ${_date(at)}\n'
        '\n'
        'Received in full, nothing further is owed on this invoice. '
        'Thank you — $company.';
  }

  static String invoiceMessage(Invoice invoice, {PaymentDestination? payTo}) {
    final link = PaymentLink.forInvoice(invoice, payTo);
    return 'Hello ${invoice.client}, please find invoice ${invoice.id} for '
        '${formatFull(invoice.amount)} — ${invoice.description}. '
        'Due ${_date(invoice.due)}.'
        '${link == null ? '' : '\n\nPay here: $link'}'
        '\n\nThank you.';
  }

  static String _date(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  static Future<bool> whatsapp(String phone, String message) => _open(
      Uri.parse('https://wa.me/${normalise(phone)}?text=${Uri.encodeComponent(message)}'));

  static Future<bool> sms(String phone, String message) => _open(
      Uri.parse('sms:${phone.trim()}?body=${Uri.encodeComponent(message)}'));

  static Future<bool> call(String phone) => _open(Uri.parse('tel:${phone.trim()}'));

  static Future<bool> email(String address, String subject, String body) => _open(Uri.parse(
      'mailto:$address?subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}'));

  static Future<bool> _open(Uri uri) async {
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }

  static void toast(BuildContext context, String message, {bool ok = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: ok ? const Color(0xFF10B981) : const Color(0xFFEF4444),
      ),
    );
  }
}
