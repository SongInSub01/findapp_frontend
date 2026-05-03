import 'package:flutter/material.dart';

import 'package:my_flutter_starter/data/models/app_models.dart';
import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class DeviceCard extends StatelessWidget {
  const DeviceCard({required this.device, required this.onTap, super.key});

  final BleDevice device;
  final VoidCallback onTap;

  IconData get icon {
    switch (device.iconKey) {
      case 'wallet':
        return Icons.wallet_outlined;
      case 'key':
        return Icons.key_outlined;
      case 'bag':
        return Icons.work_outline_rounded;
      default:
        return Icons.inventory_2_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = AppColors.status(device.status);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.extraLarge),
      child: Ink(
        width: 156,
        padding: const EdgeInsets.all(AppSpacing.large),
        decoration: BoxDecoration(
          color: AppColors.surfaceRaised,
          borderRadius: BorderRadius.circular(AppRadii.extraLarge),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: device.status == ItemStatus.lost
                        ? AppColors.surfaceDanger
                        : AppColors.surfaceBlue,
                    borderRadius: BorderRadius.circular(AppRadii.small),
                  ),
                  child: Icon(
                    icon,
                    color: device.status == ItemStatus.lost
                        ? AppColors.red
                        : AppColors.primary,
                  ),
                ),
                const Spacer(),
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              device.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.subtitle,
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.place_outlined,
                  size: 14,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    device.location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
