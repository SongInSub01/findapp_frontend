import 'package:flutter/material.dart';

import 'package:my_flutter_starter/data/models/app_models.dart';

abstract final class AppColors {
  static const background = Color(0xFFF8FAFC);
  static const surface = background;
  static const card = Colors.white;
  static const surfaceRaised = card;
  static const surfaceSoft = Color(0xFFF1F5F9);
  static const surfaceBlue = Color(0xFFEFF6FF);
  static const surfaceTeal = Color(0xFFEAFBF7);
  static const surfaceSuccess = greenBg;
  static const surfaceWarning = yellowBg;
  static const surfaceDanger = redBg;
  static const border = Color(0xFFE2E8F0);
  static const borderStrong = border;
  static const borderLight = Color(0xFFF1F5F9);
  static const borderSoft = borderLight;
  static const text = Color(0xFF111827);
  static const textSecondary = Color(0xFF6B7280);
  static const textTertiary = Color(0xFF9CA3AF);
  static const primary = Color(0xFF2563EB);
  static const primaryLight = Color(0xFF5B8CF5);
  static const primaryDark = Color(0xFF1D4ED8);
  static const teal = Color(0xFF14B8A6);
  static const green = Color(0xFF16A34A);
  static const greenBg = Color(0xFFDCFCE7);
  static const red = Color(0xFFDC2626);
  static const redBg = Color(0xFFFEE2E2);
  static const yellow = Color(0xFFD97706);
  static const yellowBg = Color(0xFFFEF3C7);
  static const shadow = Color(0x14000000);
  static const overlay = Color(0x80000000);

  static Color status(ItemStatus status) {
    switch (status) {
      case ItemStatus.safe:
        return green;
      case ItemStatus.lost:
        return red;
      case ItemStatus.contact:
        return yellow;
    }
  }

  static Color statusBackground(ItemStatus status) {
    switch (status) {
      case ItemStatus.safe:
        return greenBg;
      case ItemStatus.lost:
        return redBg;
      case ItemStatus.contact:
        return yellowBg;
    }
  }
}
