import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

import 'kyc_models.dart';

/// The result of asking a provider to verify somebody.
class KycOutcome {
  final KycStatus status;
  final String reference;
  final String? reason;

  const KycOutcome({required this.status, required this.reference, this.reason});
}

/// What any identity provider has to do for us.
///
/// The interface exists so the app is not written against one vendor: Dojah,
/// Smile ID, Prembly and Mono all expose the same three operations behind
/// different shapes, and the licensed bank partner that issues the NUBAN is a
/// separate contract again.
abstract class KycProvider {
  /// Whether real credentials are present. False means nothing here can
  /// verify anybody, and every surface must say so.
  bool get isLive;

  String get name;

  /// Checks a BVN against the NIBSS record. The BVN is passed straight
  /// through and never stored by us.
  Future<KycOutcome> verifyBvn({
    required String bvn,
    required String legalName,
    required DateTime dateOfBirth,
  });

  Future<KycOutcome> verifyNin({required String nin, required String legalName});

  /// Asks the banking partner for a NUBAN in this user's name.
  Future<NairaAccount> issueNairaAccount({
    required String legalName,
    required String phone,
    required String bvn,
    required String email,
  });
}

/// Dojah — the identity checks. Endpoints and payloads are the documented
/// ones; it activates the moment real keys are supplied at build time:
///
///   flutter build web --dart-define=DOJAH_APP_ID=... --dart-define=DOJAH_SECRET=...
class DojahKycProvider implements KycProvider {
  static const _appId = String.fromEnvironment('DOJAH_APP_ID');
  static const _secret = String.fromEnvironment('DOJAH_SECRET');
  static const _base = 'https://api.dojah.io';

  final http.Client _client;

  DojahKycProvider([http.Client? client]) : _client = client ?? http.Client();

  @override
  bool get isLive => _appId.isNotEmpty && _secret.isNotEmpty;

  @override
  String get name => 'Dojah';

  Map<String, String> get _headers => {
        'AppId': _appId,
        'Authorization': _secret,
        'Content-Type': 'application/json',
      };

  @override
  Future<KycOutcome> verifyBvn({
    required String bvn,
    required String legalName,
    required DateTime dateOfBirth,
  }) async {
    final dob = '${dateOfBirth.year}-${dateOfBirth.month.toString().padLeft(2, '0')}'
        '-${dateOfBirth.day.toString().padLeft(2, '0')}';
    final uri = Uri.parse('$_base/api/v1/kyc/bvn/full?bvn=$bvn');

    try {
      final res = await _client.get(uri, headers: _headers);
      if (res.statusCode != 200) {
        return KycOutcome(
          status: KycStatus.rejected,
          reference: '',
          reason: 'The BVN service could not confirm those details.',
        );
      }

      final body = jsonDecode(res.body)['entity'] as Map<String, dynamic>;
      final matchesName = _namesAgree(
          '${body['first_name'] ?? ''} ${body['last_name'] ?? ''}', legalName);
      final matchesDob = (body['date_of_birth'] as String?)?.startsWith(dob) ?? false;

      if (!matchesName) {
        return const KycOutcome(
          status: KycStatus.rejected,
          reference: '',
          reason: 'The name does not match the one on this BVN.',
        );
      }
      if (!matchesDob) {
        return const KycOutcome(
          status: KycStatus.rejected,
          reference: '',
          reason: 'The date of birth does not match this BVN.',
        );
      }

      return KycOutcome(
        status: KycStatus.verified,
        reference: (body['reference'] as String?) ?? 'dojah-bvn',
      );
    } catch (_) {
      return const KycOutcome(
        status: KycStatus.pending,
        reference: '',
        reason: 'We could not reach the verification service. We will retry.',
      );
    }
  }

  @override
  Future<KycOutcome> verifyNin({
    required String nin,
    required String legalName,
  }) async {
    final uri = Uri.parse('$_base/api/v1/kyc/nin?nin=$nin');
    try {
      final res = await _client.get(uri, headers: _headers);
      if (res.statusCode != 200) {
        return const KycOutcome(
          status: KycStatus.rejected,
          reference: '',
          reason: 'That NIN could not be confirmed.',
        );
      }
      final body = jsonDecode(res.body)['entity'] as Map<String, dynamic>;
      final agrees = _namesAgree(
          '${body['first_name'] ?? ''} ${body['surname'] ?? ''}', legalName);
      return agrees
          ? KycOutcome(
              status: KycStatus.verified,
              reference: (body['reference'] as String?) ?? 'dojah-nin')
          : const KycOutcome(
              status: KycStatus.rejected,
              reference: '',
              reason: 'The name does not match the one on this NIN.');
    } catch (_) {
      return const KycOutcome(
          status: KycStatus.pending,
          reference: '',
          reason: 'We could not reach the verification service. We will retry.');
    }
  }

  /// Account issuance belongs to the licensed partner, not to Dojah. Wired
  /// when that contract exists; until then it refuses rather than inventing
  /// a number.
  @override
  Future<NairaAccount> issueNairaAccount({
    required String legalName,
    required String phone,
    required String bvn,
    required String email,
  }) {
    throw UnimplementedError(
        'Account issuance needs the banking partner contract. Not live yet.');
  }

  /// Nigerian records order names inconsistently, so compare the parts.
  static bool _namesAgree(String fromRecord, String given) {
    Set<String> parts(String s) => s
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z ]'), '')
        .split(' ')
        .where((p) => p.length > 1)
        .toSet();

    final a = parts(fromRecord);
    final b = parts(given);
    if (a.isEmpty || b.isEmpty) return false;
    return a.intersection(b).length >= 2 || a.containsAll(b) || b.containsAll(a);
  }
}

/// Stands in until the provider contracts are signed.
///
/// It never claims a verification succeeded against a real record and never
/// returns an account number that looks like it could receive money — the
/// NUBAN it issues is in the 9999xxxxxx test range and is flagged not live,
/// so the UI has to label it.
class SandboxKycProvider implements KycProvider {
  @override
  bool get isLive => false;

  @override
  String get name => 'Sandbox';

  @override
  Future<KycOutcome> verifyBvn({
    required String bvn,
    required String legalName,
    required DateTime dateOfBirth,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (bvn.length != 11 || int.tryParse(bvn) == null) {
      return const KycOutcome(
        status: KycStatus.rejected,
        reference: '',
        reason: 'A BVN is 11 digits. Check the number and try again.',
      );
    }
    return KycOutcome(
      status: KycStatus.verified,
      reference: 'sandbox-${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  @override
  Future<KycOutcome> verifyNin({
    required String nin,
    required String legalName,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (nin.length != 11 || int.tryParse(nin) == null) {
      return const KycOutcome(
        status: KycStatus.rejected,
        reference: '',
        reason: 'A NIN is 11 digits.',
      );
    }
    return KycOutcome(
      status: KycStatus.verified,
      reference: 'sandbox-nin-${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  @override
  Future<NairaAccount> issueNairaAccount({
    required String legalName,
    required String phone,
    required String bvn,
    required String email,
  }) async {
    await Future<void>.delayed(const Duration(seconds: 1));
    // 9999 prefix: reserved-looking and obviously not a real NUBAN.
    final tail = Random().nextInt(1000000).toString().padLeft(6, '0');
    return NairaAccount(
      accountNumber: '9999$tail',
      accountName: legalName.toUpperCase(),
      bankName: 'gabis (sandbox — no bank partner yet)',
      issuedAt: DateTime.now(),
      live: false,
    );
  }
}

/// Real keys mean the real provider; otherwise the sandbox, loudly.
KycProvider resolveKycProvider() {
  final dojah = DojahKycProvider();
  return dojah.isLive ? dojah : SandboxKycProvider();
}
