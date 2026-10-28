enum Currency {
  usd('USD', 'US Dollar', symbolPrefix: r'$'),
  eur('EUR', 'Euro', symbolPrefix: '€'),
  gbp('GBP', 'British Pound', symbolPrefix: '£'),
  mad('MAD', 'Moroccan Dirham', symbolSuffix: 'MAD');

  const Currency(
    this.code,
    this.displayName, {
    this.symbolPrefix = '',
    this.symbolSuffix,
  });

  final String code;
  final String displayName;
  final String symbolPrefix;
  final String? symbolSuffix;

  /// Short symbol for input field prefixes / badges.
  String get symbol => symbolSuffix ?? symbolPrefix;

  static Currency fromCode(String? code) => Currency.values.firstWhere(
        (c) => c.code == code,
        orElse: () => Currency.usd,
      );
}
