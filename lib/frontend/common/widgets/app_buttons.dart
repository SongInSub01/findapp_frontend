import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.expanded = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final style = FilledButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      minimumSize: const Size.fromHeight(52),
    );
    final child = icon == null
        ? FilledButton(
            onPressed: onPressed,
            style: style,
            child: Text(label, style: AppTextStyles.body.copyWith(color: Colors.white)),
          )
        : FilledButton.icon(
            onPressed: onPressed,
            icon: Icon(icon, size: 18),
            label: Text(label, style: AppTextStyles.body.copyWith(color: Colors.white)),
            style: style,
          );
    return expanded ? SizedBox(width: double.infinity, child: child) : child;
  }
}

class AppSecondaryButton extends StatelessWidget {
  const AppSecondaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.expanded = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final style = OutlinedButton.styleFrom(
      foregroundColor: AppColors.text,
      backgroundColor: Colors.white,
      side: const BorderSide(color: AppColors.border),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      minimumSize: const Size.fromHeight(52),
    );
    final child = icon == null
        ? OutlinedButton(
            onPressed: onPressed,
            style: style,
            child: Text(label, style: AppTextStyles.body),
          )
        : OutlinedButton.icon(
            onPressed: onPressed,
            icon: Icon(icon, size: 18),
            label: Text(label, style: AppTextStyles.body),
            style: style,
          );
    return expanded ? SizedBox(width: double.infinity, child: child) : child;
  }
}
