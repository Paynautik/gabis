import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/firebase/user_sync.dart';
import '../business/business_persistence_stub.dart'
    if (dart.library.js_interop) '../business/business_persistence_web.dart';
import 'kyc_models.dart';
import 'kyc_provider.dart';

class KycState {
  final KycProfile profile;
  final NairaAccount? account;
  final bool busy;

  const KycState({
    this.profile = const KycProfile(),
    this.account,
    this.busy = false,
  });

  KycState copyWith({KycProfile? profile, NairaAccount? account, bool? busy}) =>
      KycState(
        profile: profile ?? this.profile,
        account: account ?? this.account,
        busy: busy ?? this.busy,
      );
}

class KycNotifier extends StateNotifier<KycState> {
  KycNotifier() : super(const KycState()) {
    _restore();
  }

  static const _key = 'gabis.kyc.v1';

  final _provider = resolveKycProvider();
  final _sync = UserSync();

  bool get providerIsLive => _provider.isLive;
  String get providerName => _provider.name;

  void _restore() {
    final raw = readRaw(_key);
    if (raw == null) {
      _pullRemote();
      return;
    }
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      state = KycState(
        profile: KycProfile.fromJson(map['profile'] as Map<String, dynamic>),
        account: map['account'] == null
            ? null
            : NairaAccount.fromJson(map['account'] as Map<String, dynamic>),
      );
    } catch (_) {
      // Unreadable local copy is not worth guessing at.
    }
    _pullRemote();
  }

  Future<void> _pullRemote() async {
    final remote = await _sync.get('kyc');
    if (remote == null || remote['profile'] == null) return;
    state = KycState(
      profile: KycProfile.fromJson(
          Map<String, dynamic>.from(remote['profile'] as Map)),
      account: remote['account'] == null
          ? null
          : NairaAccount.fromJson(Map<String, dynamic>.from(remote['account'] as Map)),
    );
    _persistLocal();
  }

  void _persistLocal() {
    writeRaw(
      _key,
      jsonEncode({
        'profile': state.profile.toJson(),
        'account': state.account?.toJson(),
      }),
    );
  }

  void _save() {
    _persistLocal();
    _sync.put('kyc', {
      'profile': state.profile.toJson(),
      'account': state.account?.toJson(),
    });
  }

  /// Tier 1: name, date of birth and a BVN, checked against the NIBSS record.
  ///
  /// The BVN is handed to the provider and dropped: only its last four digits
  /// and the provider's reference are kept, so a breach of our database never
  /// exposes anybody's BVN.
  Future<String?> submitTier1({
    required String legalName,
    required String phone,
    required DateTime dateOfBirth,
    required String bvn,
  }) async {
    state = state.copyWith(
      busy: true,
      profile: state.profile.copyWith(
        legalName: legalName,
        phone: phone,
        dateOfBirth: dateOfBirth,
        status: KycStatus.inProgress,
        submittedAt: DateTime.now(),
      ),
    );

    final outcome = await _provider.verifyBvn(
      bvn: bvn,
      legalName: legalName,
      dateOfBirth: dateOfBirth,
    );

    state = state.copyWith(
      busy: false,
      profile: state.profile.copyWith(
        status: outcome.status,
        tier: outcome.status == KycStatus.verified ? KycTier.tier1 : KycTier.none,
        bvnLast4: bvn.length >= 4 ? bvn.substring(bvn.length - 4) : '',
        providerReference: outcome.reference,
        rejectionReason: outcome.reason,
        decidedAt: DateTime.now(),
      ),
    );
    _save();
    return outcome.status == KycStatus.verified ? null : outcome.reason;
  }

  /// Asks the banking partner for a NUBAN. Refuses unless the person is
  /// actually verified.
  Future<String?> openNairaAccount({required String email, required String bvn}) async {
    if (!state.profile.canOpenNairaAccount) {
      return 'Finish verification first.';
    }

    state = state.copyWith(busy: true);
    try {
      final account = await _provider.issueNairaAccount(
        legalName: state.profile.legalName,
        phone: state.profile.phone,
        bvn: bvn,
        email: email,
      );
      state = state.copyWith(busy: false, account: account);
      _save();
      return null;
    } on UnimplementedError {
      state = state.copyWith(busy: false);
      return 'Account issuance is not connected yet — no banking partner is live.';
    } catch (_) {
      state = state.copyWith(busy: false);
      return 'We could not open the account. Try again shortly.';
    }
  }

  void reset() {
    state = const KycState();
    removeRaw(_key);
    _sync.put('kyc', {'profile': const KycProfile().toJson(), 'account': null});
  }
}

final kycProvider =
    StateNotifierProvider<KycNotifier, KycState>((ref) => KycNotifier());
