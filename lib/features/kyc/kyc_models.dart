/// Identity verification, modelled on how Nigerian tiered KYC actually works
/// under the CBN's three-tier framework: each tier unlocks larger limits and
/// asks for correspondingly more proof.
enum KycTier {
  /// Nothing verified. Can look around, cannot hold a bank account.
  none,

  /// Phone and BVN or NIN. Enough for a NUBAN with modest limits.
  tier1,

  /// Government ID and a selfie. Higher limits.
  tier2,

  /// Proof of address. Full limits.
  tier3,
}

enum KycStatus {
  notStarted,
  inProgress,

  /// Sent to the provider, waiting on a result. Minutes, sometimes a day.
  pending,
  verified,
  rejected,
}

/// What each tier allows, in naira. These mirror the CBN tiered limits rather
/// than being invented: a user who has given only a BVN should not be told
/// they can move unlimited money.
class TierLimits {
  final int singleDeposit;
  final int dailyTransfer;
  final int maxBalance;

  const TierLimits({
    required this.singleDeposit,
    required this.dailyTransfer,
    required this.maxBalance,
  });

  static const _none = TierLimits(singleDeposit: 0, dailyTransfer: 0, maxBalance: 0);
  static const _one =
      TierLimits(singleDeposit: 50000, dailyTransfer: 50000, maxBalance: 300000);
  static const _two =
      TierLimits(singleDeposit: 200000, dailyTransfer: 200000, maxBalance: 500000);
  static const _three = TierLimits(
      singleDeposit: 5000000, dailyTransfer: 5000000, maxBalance: 999999999);

  static TierLimits of(KycTier tier) => switch (tier) {
        KycTier.none => _none,
        KycTier.tier1 => _one,
        KycTier.tier2 => _two,
        KycTier.tier3 => _three,
      };
}

/// What we keep about a verification.
///
/// Deliberately not the BVN itself. A BVN is the most sensitive number a
/// Nigerian holds; it goes to the licensed provider that is allowed to check
/// it and never into our database. We keep the last four digits so the user
/// can see which one they used, and the provider's reference so a dispute can
/// be traced.
class KycProfile {
  final KycTier tier;
  final KycStatus status;

  final String legalName;
  final String phone;
  final DateTime? dateOfBirth;

  /// Last four digits only — enough to recognise, useless if leaked.
  final String bvnLast4;
  final String ninLast4;

  final String providerReference;
  final String? rejectionReason;
  final DateTime? submittedAt;
  final DateTime? decidedAt;

  const KycProfile({
    this.tier = KycTier.none,
    this.status = KycStatus.notStarted,
    this.legalName = '',
    this.phone = '',
    this.dateOfBirth,
    this.bvnLast4 = '',
    this.ninLast4 = '',
    this.providerReference = '',
    this.rejectionReason,
    this.submittedAt,
    this.decidedAt,
  });

  bool get canOpenNairaAccount => status == KycStatus.verified && tier != KycTier.none;
  TierLimits get limits => TierLimits.of(tier);

  KycProfile copyWith({
    KycTier? tier,
    KycStatus? status,
    String? legalName,
    String? phone,
    DateTime? dateOfBirth,
    String? bvnLast4,
    String? ninLast4,
    String? providerReference,
    String? rejectionReason,
    DateTime? submittedAt,
    DateTime? decidedAt,
  }) =>
      KycProfile(
        tier: tier ?? this.tier,
        status: status ?? this.status,
        legalName: legalName ?? this.legalName,
        phone: phone ?? this.phone,
        dateOfBirth: dateOfBirth ?? this.dateOfBirth,
        bvnLast4: bvnLast4 ?? this.bvnLast4,
        ninLast4: ninLast4 ?? this.ninLast4,
        providerReference: providerReference ?? this.providerReference,
        rejectionReason: rejectionReason ?? this.rejectionReason,
        submittedAt: submittedAt ?? this.submittedAt,
        decidedAt: decidedAt ?? this.decidedAt,
      );

  Map<String, dynamic> toJson() => {
        'tier': tier.name,
        'status': status.name,
        'legalName': legalName,
        'phone': phone,
        'dateOfBirth': dateOfBirth?.toIso8601String(),
        'bvnLast4': bvnLast4,
        'ninLast4': ninLast4,
        'providerReference': providerReference,
        'rejectionReason': rejectionReason,
        'submittedAt': submittedAt?.toIso8601String(),
        'decidedAt': decidedAt?.toIso8601String(),
      };

  static KycProfile fromJson(Map<String, dynamic> m) => KycProfile(
        tier: KycTier.values.firstWhere(
            (t) => t.name == m['tier'], orElse: () => KycTier.none),
        status: KycStatus.values.firstWhere(
            (s) => s.name == m['status'], orElse: () => KycStatus.notStarted),
        legalName: (m['legalName'] as String?) ?? '',
        phone: (m['phone'] as String?) ?? '',
        dateOfBirth: m['dateOfBirth'] == null
            ? null
            : DateTime.tryParse(m['dateOfBirth'] as String),
        bvnLast4: (m['bvnLast4'] as String?) ?? '',
        ninLast4: (m['ninLast4'] as String?) ?? '',
        providerReference: (m['providerReference'] as String?) ?? '',
        rejectionReason: m['rejectionReason'] as String?,
        submittedAt: m['submittedAt'] == null
            ? null
            : DateTime.tryParse(m['submittedAt'] as String),
        decidedAt: m['decidedAt'] == null
            ? null
            : DateTime.tryParse(m['decidedAt'] as String),
      );
}

/// A Nigerian bank account issued to a verified user.
class NairaAccount {
  final String accountNumber; // NUBAN, 10 digits
  final String accountName;
  final String bankName;
  final DateTime issuedAt;

  /// False until a licensed partner has actually issued it. A number that
  /// looks real but cannot receive money is worse than no number at all, so
  /// every surface that shows this has to check.
  final bool live;

  const NairaAccount({
    required this.accountNumber,
    required this.accountName,
    required this.bankName,
    required this.issuedAt,
    this.live = false,
  });

  Map<String, dynamic> toJson() => {
        'accountNumber': accountNumber,
        'accountName': accountName,
        'bankName': bankName,
        'issuedAt': issuedAt.toIso8601String(),
        'live': live,
      };

  static NairaAccount fromJson(Map<String, dynamic> m) => NairaAccount(
        accountNumber: m['accountNumber'] as String,
        accountName: m['accountName'] as String,
        bankName: m['bankName'] as String,
        issuedAt: DateTime.parse(m['issuedAt'] as String),
        live: (m['live'] as bool?) ?? false,
      );
}
