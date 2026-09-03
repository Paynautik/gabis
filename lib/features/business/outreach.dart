import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'business_store.dart';

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

  static String chaseMessage({
    required String name,
    required String company,
    required double outstanding,
    required int daysOverdue,
    String? invoiceId,
  }) {
    final ref = invoiceId == null ? '' : ' ($invoiceId)';
    final timing = daysOverdue > 0
        ? 'was due $daysOverdue ${daysOverdue == 1 ? 'day' : 'days'} ago'
        : 'is due shortly';
    return 'Hello ${name.split(' ').first}, this is $company. '
        'Your balance of ${formatFull(outstanding)}$ref $timing. '
        'You can pay from your gabis app, or reply here if you need a new date. Thank you.';
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

  static String invoiceMessage(Invoice invoice) =>
      'Hello ${invoice.client}, please find invoice ${invoice.id} for '
      '${formatFull(invoice.amount)} — ${invoice.description}. '
      'Due ${_date(invoice.due)}. Thank you.';

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
