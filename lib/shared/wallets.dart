/// The currencies a gabis account can hold: the seven African corridors gabis
/// operates in, plus the five global currencies clients most often pay in.
///
/// One list, so the accounts screen, the homepage and the marketing pages
/// cannot drift apart again. Account details for each depend on the banking
/// partner behind it; [details] is what the wallet screen shows.
class WalletCurrency {
  final String code;
  final String name;
  final String flag;
  final String symbol;
  final bool african;
  final String details;

  const WalletCurrency(this.code, this.name, this.flag, this.symbol, this.details, {this.african = false});
}

const walletCurrencies = <WalletCurrency>[
  WalletCurrency('NGN', 'Nigerian naira', '🇳🇬', '₦', 'Local account number (NIP)', african: true),
  WalletCurrency('KES', 'Kenyan shilling', '🇰🇪', 'KSh', 'M-Pesa and local bank transfers', african: true),
  WalletCurrency('GHS', 'Ghanaian cedi', '🇬🇭', 'GH₵', 'Mobile money and GhIPSS', african: true),
  WalletCurrency('UGX', 'Ugandan shilling', '🇺🇬', 'USh', 'Mobile money and local bank', african: true),
  WalletCurrency('TZS', 'Tanzanian shilling', '🇹🇿', 'TSh', 'Mobile money and local bank', african: true),
  WalletCurrency('SSP', 'South Sudanese pound', '🇸🇸', 'SSP ', 'Local bank transfer', african: true),
  WalletCurrency('LRD', 'Liberian dollar', '🇱🇷', 'L\$', 'Mobile money and local bank', african: true),
  WalletCurrency('USD', 'US dollar', '🇺🇸', '\$', 'US account and routing number (ACH, wire)'),
  WalletCurrency('GBP', 'British pound', '🇬🇧', '£', 'UK sort code and account number'),
  WalletCurrency('EUR', 'Euro', '🇪🇺', '€', 'SEPA IBAN'),
  WalletCurrency('CAD', 'Canadian dollar', '🇨🇦', 'C\$', 'Canadian transit and account number'),
  WalletCurrency('JPY', 'Japanese yen', '🇯🇵', '¥', 'Japanese bank transfer (Zengin)'),
];

WalletCurrency? walletFor(String code) {
  for (final w in walletCurrencies) {
    if (w.code == code) return w;
  }
  return null;
}
