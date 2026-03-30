import 'package:flutter/material.dart';

import 'package:my_flutter_starter/data/models/app_models.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    required this.status,
    this.small = false,
    super.key,
  });

  final ItemStatus status;
  final bool small;

  String get label {
    switch (status) {
      case ItemStatus.safe:
        return '소지 중';
      case ItemStatus.lost:
        return '분실';
      case ItemStatus.contact:
        return '연락 중';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = AppColors.status(status);
    final background = AppColors.statusBackground(status);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 8 : 10,
        vertical: small ? 4 : 5,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: small ? 5 : 6,
            height: small ? 5 : 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: (small ? AppTextStyles.caption : AppTextStyles.bodySecondary)
                .copyWith(color: color, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
