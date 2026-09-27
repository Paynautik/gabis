import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The seams where a licensed partner plugs in.
///
/// gabis does not hold customer money itself. Stablecoin settlement, escrow
/// custody, tax remittance and live exchange rates each belong to a regulated
/// partner. Every screen talks to these interfaces only, so going live is a
/// matter of writing one class per partner and changing [partnerModeProvider]
/// — no screen changes.
///
/// Until a partner is signed, each rail runs in [PartnerMode.sandbox]: the
/// flows are real, the state is real and persisted, but no money moves and
/// every result is labelled as a sandbox result in the UI.
/// See docs/PARTNERS.md for what each partner has to provide.
enum PartnerMode { sandbox, live }

/// Which mode the app runs its partner rails in. Stays sandbox until the
/// live adapters exist; flipping it without them would be a lie in the UI.
final partnerModeProvider = Provider<PartnerMode>((ref) => PartnerMode.sandbox);

class PartnerResult {
  final bool ok;
  final String reference;
  final String message;
  final bool sandbox;

  const PartnerResult({
    required this.ok,
    required this.reference,
    required this.message,
    required this.sandbox,
  });
}

String _ref(String prefix) {
  final r = math.Random();
  final n = List.generate(8, (_) => r.nextInt(36).toRadixString(36)).join();
  return '$prefix-${n.toUpperCase()}';
}

// ── Stablecoin (USDC) ─────────────────────────────────────────────────────

/// A USDC wallet and the off-ramp to local currency.
/// Live partner candidates: a licensed stablecoin issuer or on/off-ramp.
abstract class StablecoinRail {
  String get name;

  /// Where a client abroad pays. For a live partner this is a deposit
  /// address or a virtual USD account that settles to USDC.
  Future<String> depositAddress(String userId);

  /// Quote for turning USDC (in cents) into [currency] (in minor units).
  /// The quote is only honoured until [RateQuote.expiresAt].
  Future<RateQuote> quote({required int usdcCents, required String currency});

  Future<PartnerResult> convert(RateQuote quote);
}

class RateQuote {
  final int usdcCents;
  final String currency;
  final double rate;
  final DateTime expiresAt;

  const RateQuote({
    required this.usdcCents,
    required this.currency,
    required this.rate,
    required this.expiresAt,
  });

  int get outMinor => (usdcCents * rate).round();
  bool get expired => DateTime.now().isAfter(expiresAt);
}

// ── Escrow custody ────────────────────────────────────────────────────────

/// Steps a party signs on a funded escrow. Mirrors ORPay's EscrowAction.
enum EscrowStep { release, refund, dispute, dispatch, claim }

class EscrowOpened {
  final PartnerResult result;
  final String? partnerId;

  /// Where the buyer pays in. Null in sandbox, where funding is simulated.
  final String? fundingUrl;
  const EscrowOpened(this.result, {this.partnerId, this.fundingUrl});
}

/// Holds a buyer's payment until the parties settle it.
///
/// The partner's key can open an escrow and cancel it before funding, and
/// nothing more. Once funded, money moves only when the buyer, seller or
/// arbiter signs the step themselves, so [stepUrl] hands back a link for them
/// to sign; the outcome arrives later from the partner's webhook. A stolen
/// gabis key therefore cannot empty anyone's escrow.
abstract class EscrowCustodian {
  String get name;

  Future<EscrowOpened> open({
    required String title,
    required String seller,
    required int amountMinor,
    int shipByDays = 14,
  });

  /// Withdraws an escrow the buyer has not funded yet.
  Future<PartnerResult> cancel(String partnerId);

  /// Link for this user to sign [step]. Null means the custodian applies the
  /// step itself (sandbox only).
  Future<String?> stepUrl(String partnerId, EscrowStep step);
}

// ── Tax remittance ────────────────────────────────────────────────────────

/// Files and pays tax to an authority (FIRS, KRA, GRA, URA, TRA, NRA, LRA). Live partner:
/// an authorised tax-payment gateway for each authority.
abstract class TaxRemitter {
  String get name;
  Future<PartnerResult> remit({
    required String authority,
    required String taxType,
    required int amountMinor,
    required String currency,
    required String period,
  });
}

// ── Exchange rates ────────────────────────────────────────────────────────

/// Interbank rates. Live partner: a market-data feed or the FX partner's
/// own rate API.
abstract class FxRateFeed {
  String get name;

  /// Units of [quote] per 1 [base]. USD→NGN returns naira per dollar.
  Future<double> rate(String base, String quote);
}

// ── Sandbox implementations ───────────────────────────────────────────────

/// Reference rates for the sandbox only. They are round, plausible figures,
/// not market data, and the UI says so wherever they appear.
const sandboxReferenceRates = <String, double>{
  'USD/NGN': 1500,
  'USD/KES': 129,
  'USD/GHS': 15.5,
  'USD/UGX': 3700,
  'USD/TZS': 2600,
  'USD/SSP': 4500,
  'USD/LRD': 190,
  'USD/GBP': 0.79,
  'USD/EUR': 0.92,
};

class SandboxFxFeed implements FxRateFeed {
  final math.Random _r;
  SandboxFxFeed([int? seed]) : _r = math.Random(seed);

  @override
  String get name => 'Sandbox rates';

  @override
  Future<double> rate(String base, String quote) async {
    final key = '$base/$quote';
    final ref = sandboxReferenceRates[key] ??
        (sandboxReferenceRates['$quote/$base'] != null
            ? 1 / sandboxReferenceRates['$quote/$base']!
            : 1.0);
    // ±1% wander so the FX agent has something to watch.
    return ref * (1 + (_r.nextDouble() - 0.5) * 0.02);
  }
}

class SandboxStablecoinRail implements StablecoinRail {
  final FxRateFeed feed;
  SandboxStablecoinRail(this.feed);

  @override
  String get name => 'Sandbox USDC';

  @override
  Future<String> depositAddress(String userId) async =>
      'sandbox-usdc:${userId.hashCode.toUnsigned(32).toRadixString(16)}';

  @override
  Future<RateQuote> quote({required int usdcCents, required String currency}) async {
    final r = await feed.rate('USD', currency);
    return RateQuote(
      usdcCents: usdcCents,
      currency: currency,
      rate: r,
      expiresAt: DateTime.now().add(const Duration(seconds: 30)),
    );
  }

  @override
  Future<PartnerResult> convert(RateQuote quote) async {
    if (quote.expired) {
      return PartnerResult(
          ok: false, reference: '', message: 'Quote expired. Get a new rate.', sandbox: true);
    }
    return PartnerResult(
        ok: true, reference: _ref('SBX-FX'), message: 'Converted (sandbox)', sandbox: true);
  }
}

class SandboxEscrowCustodian implements EscrowCustodian {
  @override
  String get name => 'Sandbox escrow';

  @override
  Future<EscrowOpened> open({
    required String title,
    required String seller,
    required int amountMinor,
    int shipByDays = 14,
  }) async {
    final id = _ref('SBX-ESC');
    return EscrowOpened(
      PartnerResult(ok: true, reference: id, message: 'Escrow opened (sandbox)', sandbox: true),
      partnerId: id,
    );
  }

  @override
  Future<PartnerResult> cancel(String partnerId) async =>
      PartnerResult(ok: true, reference: partnerId, message: 'Escrow cancelled (sandbox)', sandbox: true);

  @override
  Future<String?> stepUrl(String partnerId, EscrowStep step) async => null;
}

class SandboxTaxRemitter implements TaxRemitter {
  @override
  String get name => 'Sandbox tax gateway';

  @override
  Future<PartnerResult> remit({
    required String authority,
    required String taxType,
    required int amountMinor,
    required String currency,
    required String period,
  }) async =>
      PartnerResult(
          ok: true,
          reference: _ref('SBX-$authority'),
          message: '$taxType for $period filed with $authority (sandbox)',
          sandbox: true);
}

// ── Providers ─────────────────────────────────────────────────────────────
// Each one returns the sandbox today. A live adapter slots in here, chosen by
// partnerModeProvider, and nothing else in the app changes.

final fxRateFeedProvider = Provider<FxRateFeed>((ref) => SandboxFxFeed());

final stablecoinRailProvider = Provider<StablecoinRail>(
    (ref) => SandboxStablecoinRail(ref.watch(fxRateFeedProvider)));

final escrowCustodianProvider =
    Provider<EscrowCustodian>((ref) => SandboxEscrowCustodian());

final taxRemitterProvider = Provider<TaxRemitter>((ref) => SandboxTaxRemitter());

// ── Live adapters ─────────────────────────────────────────────────────────

/// Escrow through ORPay (OpenReserve), via the Cloud Functions in
/// firebase/functions/src/escrow.ts: createEscrow, cancelEscrow and
/// escrowAction. The escrow's state after funding comes from ORPay's webhook
/// (orpayWebhook), which updates escrows/{id} in Firestore.
///
/// Selected by [escrowCustodianProvider] once partner mode is live.
class OpenReserveEscrowCustodian implements EscrowCustodian {
  /// Calls a Cloud Function and returns its data. Injected so this class has
  /// no Firebase import and can be tested.
  final Future<Map<String, dynamic>> Function(String name, Map<String, dynamic> data) call;
  OpenReserveEscrowCustodian(this.call);

  @override
  String get name => 'ORPay';

  @override
  Future<EscrowOpened> open({
    required String title,
    required String seller,
    required int amountMinor,
    int shipByDays = 14,
  }) async {
    try {
      final r = await call('createEscrow', {
        'itemName': title,
        'amount': amountMinor / 100,
        'seller': seller,
        'shipByDays': shipByDays,
      });
      return EscrowOpened(
        PartnerResult(ok: true, reference: '${r['orpayId']}', message: 'Escrow opened. Fund it in ORPay to start.', sandbox: false),
        partnerId: '${r['id']}',
        fundingUrl: r['fundingUrl'] as String?,
      );
    } catch (e) {
      return EscrowOpened(PartnerResult(ok: false, reference: '', message: 'ORPay: $e', sandbox: false));
    }
  }

  @override
  Future<PartnerResult> cancel(String partnerId) async {
    try {
      final r = await call('cancelEscrow', {'id': partnerId});
      return PartnerResult(ok: true, reference: partnerId, message: 'Escrow ${r['status'] ?? 'cancelled'}', sandbox: false);
    } catch (e) {
      return PartnerResult(ok: false, reference: partnerId, message: '$e', sandbox: false);
    }
  }

  @override
  Future<String?> stepUrl(String partnerId, EscrowStep step) async {
    final r = await call('escrowAction', {'id': partnerId, 'action': step.name});
    return r['url'] as String?;
  }
}
