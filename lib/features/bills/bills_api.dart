import 'dart:convert';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../core/firebase/user_sync.dart';

/// Whether bill payments are switched on, and whether that means real money.
class BillsConfig {
  final bool enabled;
  final bool live;
  const BillsConfig({required this.enabled, this.live = false});
  static const off = BillsConfig(enabled: false);
}

/// One data plan or TV bouquet, with its price in naira.
class BillPlan {
  final String code;
  final String name;
  final int amount;
  const BillPlan({required this.code, required this.name, required this.amount});
}

enum BillOutcome { delivered, pending, failed }

class BillPayResult {
  final BillOutcome outcome;
  final String reference;
  final String message;
  final String? token;
  final String? units;
  const BillPayResult({
    required this.outcome,
    required this.reference,
    this.message = '',
    this.token,
    this.units,
  });
}

/// What a meter or smartcard number turned out to be.
class BillAccountCheck {
  /// null means it could not be checked, which is not the same as wrong.
  final bool? valid;
  final String? name;
  final int? minAmount;
  const BillAccountCheck({this.valid, this.name, this.minAmount});
}

/// The server said no, with a code from the API ("invalid_meter", ...).
class BillsApiException implements Exception {
  final int status;
  final String code;
  const BillsApiException(this.status, this.code);

  @override
  String toString() => 'BillsApiException($status, $code)';
}

/// Talks to /api/bills, the Pages Function that holds the biller's keys. The
/// app never sees a key: it sends who is asking (the Firebase token) and what
/// they want.
class BillsApi {
  BillsApi({http.Client? client, Future<String?> Function()? token, this.base = '/api/bills'})
      : _http = client ?? http.Client(),
        _token = token ?? UserSync.idToken;

  final http.Client _http;
  final Future<String?> Function() _token;
  final String base;

  /// The Lagos-time prefix VTpass wants, then random letters and digits. Made
  /// once per payment and reused on every retry, so asking twice never pays
  /// twice.
  static String newRequestId([DateTime? now, Random? random]) {
    final lagos = (now ?? DateTime.now()).toUtc().add(const Duration(hours: 1));
    String two(int n) => n.toString().padLeft(2, '0');
    final stamp = '${lagos.year}${two(lagos.month)}${two(lagos.day)}${two(lagos.hour)}${two(lagos.minute)}';
    final r = random ?? Random.secure();
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return stamp + List.generate(10, (_) => chars[r.nextInt(chars.length)]).join();
  }

  Future<Map<String, String>> _headers() async {
    final token = await _token();
    return {
      'content-type': 'application/json',
      if (token != null) 'authorization': 'Bearer $token',
    };
  }

  Future<BillsConfig> config() async {
    try {
      final res = await _http.get(Uri.parse('$base/config')).timeout(const Duration(seconds: 8));
      if (res.statusCode != 200) return BillsConfig.off;
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      return BillsConfig(
        enabled: body['enabled'] == true,
        live: body['mode'] == 'live',
      );
    } catch (_) {
      return BillsConfig.off;
    }
  }

  Future<List<BillPlan>> plans(String serviceId) async {
    final res = await _http
        .get(Uri.parse('$base/variations?serviceID=${Uri.encodeQueryComponent(serviceId)}'), headers: await _headers())
        .timeout(const Duration(seconds: 15));
    if (res.statusCode != 200) throw BillsApiException(res.statusCode, _errorCode(res.body));
    final list = (jsonDecode(res.body) as Map<String, dynamic>)['plans'] as List<dynamic>? ?? const [];
    return [
      for (final p in list)
        BillPlan(
          code: (p as Map<String, dynamic>)['code'] as String,
          name: p['name'] as String,
          amount: (p['amount'] as num).round(),
        ),
    ];
  }

  Future<BillAccountCheck> verify({required String kind, required String provider, required String account}) async {
    try {
      final res = await _http
          .post(
            Uri.parse('$base/verify'),
            headers: await _headers(),
            body: jsonEncode({'kind': kind, 'provider': provider, 'account': account}),
          )
          .timeout(const Duration(seconds: 15));
      if (res.statusCode != 200) return const BillAccountCheck();
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      return BillAccountCheck(
        valid: body['valid'] as bool?,
        name: body['name'] as String?,
        minAmount: (body['minAmount'] as num?)?.round(),
      );
    } catch (_) {
      return const BillAccountCheck();
    }
  }

  /// Pays. A timeout or a dropped connection comes back as [BillOutcome.pending],
  /// never as failed: the payment may have gone through, and the caller must
  /// look again with the same [requestId].
  Future<BillPayResult> pay({
    required String kind,
    required String provider,
    required String account,
    required int amount,
    required String requestId,
    String? phone,
    String? planCode,
  }) async {
    try {
      final res = await _http
          .post(
            Uri.parse('$base/pay'),
            headers: await _headers(),
            body: jsonEncode({
              'kind': kind,
              'provider': provider,
              'account': account,
              'amount': amount,
              'requestId': requestId,
              if (phone != null && phone.isNotEmpty) 'phone': phone,
              'planCode': ?planCode,
            }),
          )
          .timeout(const Duration(seconds: 45));
      if (res.statusCode >= 400 && res.statusCode < 500) {
        throw BillsApiException(res.statusCode, _errorCode(res.body));
      }
      if (res.statusCode != 200) return _pending(requestId);
      return _parse(res.body, requestId);
    } on BillsApiException {
      rethrow;
    } catch (_) {
      return _pending(requestId);
    }
  }

  Future<BillPayResult> status(String requestId) async {
    try {
      final res = await _http
          .post(Uri.parse('$base/status'), headers: await _headers(), body: jsonEncode({'requestId': requestId}))
          .timeout(const Duration(seconds: 20));
      if (res.statusCode != 200) return _pending(requestId);
      return _parse(res.body, requestId);
    } catch (_) {
      return _pending(requestId);
    }
  }

  static BillPayResult _pending(String id) => BillPayResult(
        outcome: BillOutcome.pending,
        reference: id,
        message: 'We could not confirm this payment yet.',
      );

  static BillPayResult _parse(String body, String id) {
    final m = jsonDecode(body) as Map<String, dynamic>;
    return BillPayResult(
      outcome: switch (m['status']) {
        'delivered' => BillOutcome.delivered,
        'failed' => BillOutcome.failed,
        _ => BillOutcome.pending,
      },
      reference: (m['reference'] as String?) ?? id,
      message: (m['message'] as String?) ?? '',
      token: m['token'] as String?,
      units: m['units'] as String?,
    );
  }

  static String _errorCode(String body) {
    try {
      return (jsonDecode(body) as Map<String, dynamic>)['error'] as String? ?? 'error';
    } catch (_) {
      return 'error';
    }
  }
}

final billsApiProvider = Provider<BillsApi>((ref) => BillsApi());

/// Asked once when the bills screen opens.
final billsConfigProvider = FutureProvider<BillsConfig>((ref) => ref.watch(billsApiProvider).config());

/// How long to wait between looks at a payment that is still processing.
final billsPollDelayProvider = Provider<Duration>((ref) => const Duration(seconds: 4));
