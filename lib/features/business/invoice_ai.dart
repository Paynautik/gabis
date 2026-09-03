import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

/// What the app got back from drafting: the fields of an invoice, plus what
/// the sentence did not say.
class InvoiceDraft {
  final String client;
  final double amount;
  final String currency;
  final String description;
  final int dueInDays;

  /// Pulled out of the same sentence when it is there, so a number pasted from
  /// a chat does not have to be typed again to send the invoice.
  final String? phone;

  /// Fields the text did not contain. The form highlights these rather than
  /// pretending a guess is an answer.
  final List<String> missing;

  /// False when the local parser produced this because drafting is not
  /// configured or the network failed.
  final bool fromModel;

  const InvoiceDraft({
    required this.client,
    required this.amount,
    required this.currency,
    required this.description,
    required this.dueInDays,
    this.phone,
    this.missing = const [],
    this.fromModel = true,
  });
}

/// Turns "bill Sarah 150k for brand design, net 14" into a draft invoice.
///
/// The model runs behind /api/invoice-draft, a Cloudflare Pages Function that
/// holds the API key — a web build cannot keep a secret, so the key is never
/// shipped to the browser. When that endpoint is not configured, or is
/// unreachable, [LocalInvoiceParser] handles the common shapes offline so the
/// button still does something useful.
class InvoiceDrafter {
  InvoiceDrafter({http.Client? client, this.endpoint = '/api/invoice-draft'})
      : _client = client ?? http.Client();

  final http.Client _client;
  final String endpoint;

  Future<InvoiceDraft> draft(String prompt) async {
    try {
      final response = await _client
          .post(
            Uri.parse(endpoint),
            headers: const {'content-type': 'application/json'},
            body: jsonEncode({'prompt': prompt}),
          )
          .timeout(const Duration(seconds: 25));

      if (response.statusCode != 200) return LocalInvoiceParser.parse(prompt);

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return InvoiceDraft(
        client: (body['client'] as String? ?? '').trim(),
        amount: (body['amount'] as num? ?? 0).toDouble(),
        currency: body['currency'] as String? ?? 'NGN',
        description: (body['description'] as String? ?? '').trim(),
        dueInDays: (body['due_in_days'] as num? ?? 30).toInt(),
        phone: (body['phone'] as String?)?.trim().isEmpty ?? true
            ? null
            : (body['phone'] as String).trim(),
        missing: (body['missing'] as List? ?? const [])
            .map((e) => e.toString())
            .toList(),
      );
    } catch (_) {
      return LocalInvoiceParser.parse(prompt);
    }
  }
}

/// The offline half: the shapes people actually type, without a round trip.
///
/// It is deliberately literal — it reads amounts, terms and a name out of the
/// sentence and admits what it could not find, rather than guessing.
class LocalInvoiceParser {
  static InvoiceDraft parse(String prompt) {
    final text = prompt.trim();
    final missing = <String>[];

    // The phone comes out first, and the rest is read from what is left. A
    // number left in the text is eleven digits the amount reader would
    // otherwise happily bill somebody for.
    final phone = _phone(text);
    var rest = phone == null ? text : text.replaceFirst(phone, ' ');

    final amountMatch = _amountMatch(rest);
    final amount = _amountOf(amountMatch);
    if (amount == null) {
      missing.add('amount');
    } else {
      rest = rest.replaceFirst(amountMatch!.group(0)!, ' ');
    }

    // Two shapes, because people write both: a sentence ("bill Sarah 150k for
    // brand design") and a chat note ("Tope, 150k, brand design balance").
    var client = _clientFromVerb(rest);
    var description = _descriptionFromFor(rest);

    final segments = _segments(rest);
    client ??= segments.isEmpty ? null : segments.first;
    if (description == null && segments.length > 1) {
      final tail = segments.skip(1).where((s) => !_isTermsPhrase(s)).toList();
      if (tail.isNotEmpty) description = tail.join(' — ');
    }

    if (client == null) missing.add('client');
    if (description == null) missing.add('description');

    return InvoiceDraft(
      client: client ?? 'Client',
      amount: amount ?? 0,
      currency: RegExp(r'\$|usd', caseSensitive: false).hasMatch(rest) ? 'USD' : 'NGN',
      description: description ?? 'Services rendered',
      dueInDays: _dueInDays(text),
      phone: phone,
      missing: missing,
      fromModel: false,
    );
  }

  /// What is left once the phone and the amount are out, split the way people
  /// punctuate a note.
  static List<String> _segments(String text) => text
      .split(RegExp(r'[,;:|\n]|\s+[-–]\s+'))
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty && !RegExp(r'^[\d\s.,-]+$').hasMatch(s))
      .toList();

  /// "due next friday", "net 14" — terms, not a description of the work.
  static bool _isTermsPhrase(String segment) => RegExp(
        r'^(due|net|payable|terms|by)\b',
        caseSensitive: false,
      ).hasMatch(segment.trim());

  /// Nigerian mobile numbers as people actually paste them: +234 803 123 4567,
  /// 234-803-123-4567, 08031234567.
  static String? _phone(String text) {
    final match = RegExp(r'(?:\+?234|0)[\s.-]?[789][01]\d(?:[\s.-]?\d){7}')
        .firstMatch(text);
    return match?.group(0)?.trim();
  }

  /// An invoice for more than a hundred million naira typed into a one-line
  /// note is a parse error, not a windfall.
  static const _sane = 100000000.0;

  /// "150k", "2.5m", "₦500,000", "500000".
  static RegExpMatch? _amountMatch(String text) => RegExp(
        r'(?:₦|\$)?\s*([\d][\d,]*(?:\.\d+)?)\s*([km])?\b',
        caseSensitive: false,
      ).firstMatch(text);

  static double? _amountOf(RegExpMatch? match) {
    if (match == null) return null;

    final base = double.tryParse(match.group(1)!.replaceAll(',', ''));
    if (base == null) return null;

    final value = switch (match.group(2)?.toLowerCase()) {
      'k' => base * 1000,
      'm' => base * 1000000,
      _ => base,
    };

    return value > _sane ? null : value;
  }

  /// "bill Sarah …", "invoice Acme Ltd for …", "charge Deji …".
  static String? _clientFromVerb(String text) {
    final match = RegExp(
      r'\b(?:bill|invoice|charge)\s+([A-Z][\w&.-]*(?:\s+[A-Z][\w&.-]*)*)',
    ).firstMatch(text);
    final name = match?.group(1)?.trim();
    return (name == null || name.isEmpty) ? null : name;
  }

  /// Everything after "for", up to the terms.
  static String? _descriptionFromFor(String text) {
    final match = RegExp(r'\bfor\s+(.+)$', caseSensitive: false).firstMatch(text);
    var value = match?.group(1)?.trim();
    if (value == null || value.isEmpty) return null;

    value = value
        .split(RegExp(r',\s*(?:net|due|payable|terms)\b', caseSensitive: false))
        .first
        .trim();
    return value.isEmpty ? null : value;
  }

  /// "net 14", "due in 7 days", "two weeks", "next friday", "tomorrow".
  /// Thirty days when unsaid.
  static int _dueInDays(String text) {
    final net = RegExp(r'\bnet\s*(\d{1,3})\b', caseSensitive: false).firstMatch(text);
    if (net != null) return int.parse(net.group(1)!);

    final days = RegExp(r'\b(\d{1,3})\s*days?\b', caseSensitive: false).firstMatch(text);
    if (days != null) return int.parse(days.group(1)!);

    final lower = text.toLowerCase();
    if (lower.contains('tomorrow')) return 1;
    if (lower.contains('end of the week') || lower.contains('end of week')) {
      return _daysUntil(DateTime.friday);
    }
    if (lower.contains('two weeks') || lower.contains('next fortnight')) return 14;
    if (lower.contains('a week') || lower.contains('one week') ||
        lower.contains('next week')) {
      return 7;
    }
    if (lower.contains('month')) return 30;

    // "next friday", "on monday" — the named day people actually agree to.
    const names = {
      'monday': DateTime.monday,
      'tuesday': DateTime.tuesday,
      'wednesday': DateTime.wednesday,
      'thursday': DateTime.thursday,
      'friday': DateTime.friday,
      'saturday': DateTime.saturday,
      'sunday': DateTime.sunday,
    };
    for (final entry in names.entries) {
      if (lower.contains(entry.key)) return _daysUntil(entry.value);
    }

    return 30;
  }

  /// Days from today to the next occurrence of a weekday. Today's own weekday
  /// means a week away, not zero — "pay me friday" said on a Friday is next
  /// Friday, not this afternoon.
  static int _daysUntil(int weekday, {DateTime? from}) {
    final now = from ?? DateTime.now();
    final delta = (weekday - now.weekday + 7) % 7;
    return delta == 0 ? 7 : delta;
  }
}

final invoiceDrafterProvider = Provider<InvoiceDrafter>((ref) => InvoiceDrafter());
