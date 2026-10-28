import 'package:intl/intl.dart';

import '../../models/currency.dart';

/// Formats money in the user's chosen [Currency].
class Money {
  Money(this.currency)
      : _full = NumberFormat.currency(
          locale: 'en_US',
          symbol: currency.symbolPrefix,
          decimalDigits: 0,
        ),
        _compact = NumberFormat.compactCurrency(
          locale: 'en_US',
          symbol: currency.symbolPrefix,
          decimalDigits: 1,
        );

  final Currency currency;
  final NumberFormat _full;
  final NumberFormat _compact;

  /// `$12,400` / `12,400 MAD`
  String format(double amount) => _withSuffix(_full.format(amount));

  /// `$12.4K` / `12.4K MAD` — for axes and tight spaces.
  String compact(double amount) {
    // Small numbers read better without the K/M machinery.
    if (amount.abs() < 1000) return format(amount);
    return _withSuffix(_compact.format(amount).replaceAll('.0', ''));
  }

  String _withSuffix(String s) =>
      currency.symbolSuffix == null ? s : '$s ${currency.symbolSuffix}';
}

final _monthYear = DateFormat('MMM yyyy');
final _dayMonth = DateFormat('d MMM');
final _weekdayDayMonth = DateFormat('EEEE, d MMMM');

String formatMonthYear(DateTime d) => _monthYear.format(d);
String formatDayMonth(DateTime d) => _dayMonth.format(d);
String formatLongDate(DateTime d) => _weekdayDayMonth.format(d);

/// Human-friendly duration for a month count: `8 mo`, `2 yr`, `2 yr 4 mo`.
String formatMonthsShort(int months) {
  if (months <= 0) return 'Done';
  final years = months ~/ 12;
  final rest = months % 12;
  if (years == 0) return '$rest mo';
  if (rest == 0) return '$years yr';
  return '$years yr $rest mo';
}

/// Long form: `8 months`, `1 year`, `2 years and 4 months`.
String formatMonthsLong(int months) {
  if (months <= 0) return 'Goal reached';
  final years = months ~/ 12;
  final rest = months % 12;
  String plural(int n, String unit) => '$n $unit${n == 1 ? '' : 's'}';
  if (years == 0) return plural(rest, 'month');
  if (rest == 0) return plural(years, 'year');
  return '${plural(years, 'year')} and ${plural(rest, 'month')}';
}

String formatPercent(double fraction) =>
    '${(fraction * 100).clamp(0, 999).toStringAsFixed(0)}%';

/// `4.5%` but `4%` when whole.
String formatRate(double percent) => percent == percent.roundToDouble()
    ? '${percent.toStringAsFixed(0)}%'
    : '${percent.toStringAsFixed(1)}%';
