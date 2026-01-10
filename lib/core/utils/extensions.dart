import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// String kengaytmalari
extension StringExtension on String {
  /// Hex string ni Color ga aylantirish
  Color toColor() {
    final hexCode = replaceAll('#', '').replaceAll('0x', '').replaceAll('0X', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }
}

/// Double kengaytmalari
extension DoubleExtension on double {
  /// Narxni formatlash (so'm bilan)
  String toCurrency() {
    final formatter = NumberFormat('#,###', 'uz_UZ');
    return '${formatter.format(this)} so\'m';
  }
}

/// DateTime kengaytmalari
extension DateTimeExtension on DateTime {
  /// Sanani formatlash
  String toFormattedDate() {
    return DateFormat('dd.MM.yyyy').format(this);
  }

  /// Sana va vaqtni formatlash
  String toFormattedDateTime() {
    return DateFormat('dd.MM.yyyy HH:mm').format(this);
  }
}
