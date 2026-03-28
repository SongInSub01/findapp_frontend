import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTextStyles {
  static const koreanFallback = <String>[
    'Apple SD Gothic Neo',
    'Noto Sans CJK KR',
    'Noto Sans KR',
    'Malgun Gothic',
    'sans-serif',
  ];

  static const headline = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w800,
    color: AppColors.text,
    height: 1.2,
    fontFamilyFallback: koreanFallback,
  );

  static const title = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.text,
    height: 1.3,
    fontFamilyFallback: koreanFallback,
  );

  static const subtitle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.text,
    height: 1.35,
    fontFamilyFallback: koreanFallback,
  );

  static const body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.text,
    height: 1.45,
    fontFamilyFallback: koreanFallback,
  );

  static const bodySecondary = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.45,
    fontFamilyFallback: koreanFallback,
  );

  static const caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textTertiary,
    height: 1.4,
    fontFamilyFallback: koreanFallback,
  );

  static const overline = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AppColors.textSecondary,
    letterSpacing: 0.2,
    fontFamilyFallback: koreanFallback,
  );
}
