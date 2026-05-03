import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_text_styles.dart';

class SettingTile extends StatelessWidget {
  const SettingTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailingText,
    this.onTap,
    this.toggleValue,
    this.onToggle,
    this.danger = false,
    super.key,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? trailingText;
  final VoidCallback? onTap;
  final bool? toggleValue;
  final ValueChanged<bool>? onToggle;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final iconColor = danger ? AppColors.red : AppColors.primary;
    return InkWell(
      onTap: toggleValue == null ? onTap : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: danger ? AppColors.surfaceDanger : AppColors.surfaceBlue,
                borderRadius: BorderRadius.circular(AppRadii.xSmall),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.body.copyWith(
                      color: danger ? AppColors.red : AppColors.text,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 3),
                    Text(subtitle!, style: AppTextStyles.caption),
                  ],
                ],
              ),
            ),
            if (toggleValue != null)
              Switch(value: toggleValue!, onChanged: onToggle)
            else ...[
              if (trailingText != null)
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Text(
                    trailingText!,
                    style: AppTextStyles.bodySecondary,
                  ),
                ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textTertiary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
