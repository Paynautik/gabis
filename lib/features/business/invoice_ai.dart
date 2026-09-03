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

    final amount = _amount(text);
    if (amount == null) missing.add('amount');

    final client = _client(text);
    if (client == null) missing.add('client');

    final description = _description(text);
    if (description == null) missing.add('description');

    return InvoiceDraft(
      client: client ?? 'Client',
      amount: amount ?? 0,
      currency: RegExp(r'\$|usd', caseSensitive: false).hasMatch(text) ? 'USD' : 'NGN',
      description: description ?? 'Services rendered',
      dueInDays: _dueInDays(text),
      missing: missing,
      fromModel: false,
    );
  }

  /// "150k", "2.5m", "₦500,000", "500000".
  static double? _amount(String text) {
    final match = RegExp(
      r'(?:₦|\$)?\s*([\d][\d,]*(?:\.\d+)?)\s*([km])?\b',
      caseSensitive: false,
    ).firstMatch(text);
    if (match == null) return null;

    final base = double.tryParse(match.group(1)!.replaceAll(',', ''));
    if (base == null) return null;

    switch (match.group(2)?.toLowerCase()) {
      case 'k':
        return base * 1000;
      case 'm':
        return base * 1000000;
      default:
        return base;
    }
  }

  /// "bill Sarah …", "invoice Acme Ltd for …", "charge Deji …".
  static String? _client(String text) {
    final match = RegExp(
      r'\b(?:bill|invoice|charge)\s+([A-Z][\w&.-]*(?:\s+[A-Z][\w&.-]*)*)',
    ).firstMatch(text);
    final name = match?.group(1)?.trim();
    return (name == null || name.isEmpty) ? null : name;
  }

  /// Everything after "for", up to the terms.
  static String? _description(String text) {
    final match = RegExp(r'\bfor\s+(.+)$', caseSensitive: false).firstMatch(text);
    var value = match?.group(1)?.trim();
    if (value == null || value.isEmpty) return null;

    value = value
        .split(RegExp(r',\s*(?:net|due|payable|terms)\b', caseSensitive: false))
        .first
        .trim();
    return value.isEmpty ? null : value;
  }

  /// "net 14", "due in 7 days", "two weeks". Thirty days when unsaid.
  static int _dueInDays(String text) {
    final net = RegExp(r'\bnet\s*(\d{1,3})\b', caseSensitive: false).firstMatch(text);
    if (net != null) return int.parse(net.group(1)!);

    final days = RegExp(r'\b(\d{1,3})\s*days?\b', caseSensitive: false).firstMatch(text);
    if (days != null) return int.parse(days.group(1)!);

    if (RegExp(r'\btwo weeks\b', caseSensitive: false).hasMatch(text)) return 14;
    if (RegExp(r'\ba week\b|\bone week\b', caseSensitive: false).hasMatch(text)) return 7;

    return 30;
  }
}

final invoiceDrafterProvider = Provider<InvoiceDrafter>((ref) => InvoiceDrafter());
