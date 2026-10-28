import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../core/theme/app_palette.dart';
import '../models/currency.dart';

/// Parses text produced by [AmountField] (`12,500.5` → `12500.5`).
double parseAmount(String text) =>
    double.tryParse(text.replaceAll(',', '').trim()) ?? 0;

/// Pre-formats a number for an [AmountField] controller.
String formatAmountInput(double value) {
  if (value == 0) return '';
  final whole = value == value.roundToDouble();
  return NumberFormat(whole ? '#,##0' : '#,##0.##', 'en_US').format(value);
}

/// Money input with live thousands separators and a currency badge.
class AmountField extends StatelessWidget {
  const AmountField({
    super.key,
    required this.controller,
    required this.label,
    required this.currency,
    this.hint,
    this.validator,
    this.onChanged,
    this.autofocus = false,
    this.textInputAction = TextInputAction.next,
  });

  final TextEditingController controller;
  final String label;
  final Currency currency;
  final String? hint;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final bool autofocus;
  final TextInputAction textInputAction;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return TextFormField(
      controller: controller,
      autofocus: autofocus,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textInputAction: textInputAction,
      inputFormatters: [ThousandsInputFormatter()],
      validator: validator,
      onChanged: onChanged,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        fontFeatures: [FontFeature.tabularFigures()],
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint ?? '0',
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 12, right: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: p.brand.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              currency.symbol,
              style: TextStyle(
                color: p.brand,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minHeight: 0),
      ),
    );
  }
}

/// Keeps digits + one decimal point, groups thousands with commas.
class ThousandsInputFormatter extends TextInputFormatter {
  static final _group = NumberFormat('#,##0', 'en_US');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var raw = newValue.text.replaceAll(RegExp(r'[^0-9.]'), '');
    if (raw.isEmpty) return const TextEditingValue();

    final dot = raw.indexOf('.');
    String whole = dot == -1 ? raw : raw.substring(0, dot);
    String? fraction;
    if (dot != -1) {
      fraction = raw.substring(dot + 1).replaceAll('.', '');
      if (fraction.length > 2) fraction = fraction.substring(0, 2);
    }
    if (whole.length > 12) whole = whole.substring(0, 12);

    final grouped = whole.isEmpty ? '0' : _group.format(int.parse(whole));
    final text = fraction == null ? grouped : '$grouped.$fraction';
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
