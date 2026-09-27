/// Consumption tax (VAT, GST or sales tax) and withholding tax for the
/// corridors gabis supports: Nigeria, Kenya, Ghana, Uganda, Tanzania,
/// South Sudan and Liberia.
///
/// Rates are the headline statutory rates and the common WHT bands. They are
/// a starting point, not tax advice: the payer's status, the service type and
/// treaty relief all move the real figure, so every screen that uses these
/// says so and lets the user override the WHT rate.
library;

class WhtBand {
  final String label;
  final double rate;
  const WhtBand(this.label, this.rate);
}

class TaxCorridor {
  final String code; // NG, KE, GH, UG, TZ, SS, LR
  final String country;
  final String authority;
  final String currency;
  final String symbol;
  final double vatRate;
  final List<WhtBand> whtBands;

  /// What the consumption tax is called there: VAT, GST, Sales tax.
  final String taxName;

  /// True where the rates here have not yet been checked against the
  /// authority's current schedule. The UI shows a "confirm with your tax
  /// adviser" note until someone verifies them and flips this off.
  final bool needsConfirmation;

  const TaxCorridor({
    required this.code,
    required this.country,
    required this.authority,
    required this.currency,
    required this.symbol,
    required this.vatRate,
    required this.whtBands,
    this.taxName = 'VAT',
    this.needsConfirmation = false,
  });

  double get whtMin => whtBands.map((b) => b.rate).reduce((a, b) => a < b ? a : b);
  double get whtMax => whtBands.map((b) => b.rate).reduce((a, b) => a > b ? a : b);
}

const taxCorridors = <TaxCorridor>[
  TaxCorridor(
    code: 'NG',
    country: 'Nigeria',
    authority: 'FIRS',
    currency: 'NGN',
    symbol: '₦',
    vatRate: 0.075,
    whtBands: [
      WhtBand('Consultancy & professional services', 0.10),
      WhtBand('Contracts & supplies', 0.05),
      WhtBand('Rent', 0.10),
      WhtBand('Commission', 0.10),
      WhtBand('Construction', 0.025),
    ],
  ),
  TaxCorridor(
    code: 'KE',
    country: 'Kenya',
    authority: 'KRA',
    currency: 'KES',
    symbol: 'KSh',
    vatRate: 0.16,
    whtBands: [
      WhtBand('Professional & management fees', 0.05),
      WhtBand('Contractual fees', 0.03),
      WhtBand('Commission', 0.10),
      WhtBand('Rent (non-residential)', 0.10),
    ],
  ),
  TaxCorridor(
    code: 'GH',
    country: 'Ghana',
    authority: 'GRA',
    currency: 'GHS',
    symbol: 'GH₵',
    vatRate: 0.15,
    whtBands: [
      WhtBand('Supply of goods', 0.03),
      WhtBand('Supply of works', 0.05),
      WhtBand('Supply of services', 0.075),
    ],
  ),
  TaxCorridor(
    code: 'UG',
    country: 'Uganda',
    authority: 'URA',
    currency: 'UGX',
    symbol: 'USh',
    vatRate: 0.18,
    whtBands: [
      WhtBand('Goods & services (resident)', 0.06),
      WhtBand('Professional fees (resident)', 0.06),
      WhtBand('Payments to non-residents', 0.15),
    ],
    needsConfirmation: true,
  ),
  TaxCorridor(
    code: 'TZ',
    country: 'Tanzania',
    authority: 'TRA',
    currency: 'TZS',
    symbol: 'TSh',
    vatRate: 0.18,
    whtBands: [
      WhtBand('Services (resident)', 0.05),
      WhtBand('Rent', 0.10),
      WhtBand('Services (non-resident)', 0.15),
    ],
    needsConfirmation: true,
  ),
  TaxCorridor(
    code: 'SS',
    country: 'South Sudan',
    authority: 'NRA',
    currency: 'SSP',
    symbol: 'SSP ',
    taxName: 'Sales tax',
    vatRate: 0.18,
    whtBands: [
      WhtBand('Contracts & services', 0.10),
      WhtBand('Payments to non-residents', 0.15),
    ],
    needsConfirmation: true,
  ),
  TaxCorridor(
    code: 'LR',
    country: 'Liberia',
    authority: 'LRA',
    currency: 'LRD',
    symbol: 'L\$',
    taxName: 'GST',
    vatRate: 0.10,
    whtBands: [
      WhtBand('Services (resident)', 0.10),
      WhtBand('Payments to non-residents', 0.15),
    ],
    needsConfirmation: true,
  ),
];

TaxCorridor corridorFor(String code) =>
    taxCorridors.firstWhere((c) => c.code == code, orElse: () => taxCorridors.first);

/// How one invoice breaks down. All amounts in minor units.
class InvoiceTax {
  final int netMinor;
  final int vatMinor;
  final int whtMinor;

  const InvoiceTax({required this.netMinor, required this.vatMinor, required this.whtMinor});

  /// What the client pays you: net plus VAT, minus the WHT they hold back
  /// and pay to the authority on your behalf.
  int get receivedMinor => netMinor + vatMinor - whtMinor;

  /// What the client is billed in total before withholding.
  int get grossMinor => netMinor + vatMinor;
}

/// WHT is charged on the net amount, never on VAT.
InvoiceTax taxInvoice({required int netMinor, required double vatRate, double whtRate = 0}) {
  return InvoiceTax(
    netMinor: netMinor,
    vatMinor: (netMinor * vatRate).round(),
    whtMinor: (netMinor * whtRate).round(),
  );
}
