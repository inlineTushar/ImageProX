import 'package:flutter/material.dart';

abstract class AppColors {
  // Brand palette (from requirement.html)
  static const Color tawnyOwl = Color(0xFFF1947B);
  static const Color greatHornedOwl = Color(0xFFED6F72);
  static const Color burrowingOwl = Color(0xFFEA4F6C);

  static const Color screechOwl = Color(0xFF994164);
  static const Color greatGreyOwl = Color(0xFF484C6D);
  static const Color elfOwl = Color(0xFF1F1D2F);

  // Foundation
  static const Color pageBackground = Color(0xFF12121A);
  static const Color surface = Color(0xFF1A1A24);
  static const Color elevated = Color(0xFF22222E);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFA0A0A8);
  static const Color textMuted = Color(0xFF6B6B75);
  static const Color divider = Color(0xFF2C2C3A);
  static const Color error = Color(0xFFEA4F6C);

  // Theme roles
  static const Color primary = burrowingOwl;
  static const Color primaryDark = greatHornedOwl;
  static const Color accent = tawnyOwl;

  static const MaterialColor primarySwatch = Colors.pink;
}
