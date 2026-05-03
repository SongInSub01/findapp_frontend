import 'package:flutter/material.dart';

import 'package:my_flutter_starter/data/models/app_models.dart';
import 'package:my_flutter_starter/frontend/common/resources/app_assets.dart';
import 'package:my_flutter_starter/frontend/common/theme/app_colors.dart';
import 'package:my_flutter_starter/frontend/common/theme/app_radii.dart';
import 'package:my_flutter_starter/frontend/common/theme/app_spacing.dart';
import 'package:my_flutter_starter/frontend/common/theme/app_text_styles.dart';

class PanelEmpty extends StatelessWidget {
  const PanelEmpty({
    required this.icon,
    required this.title,
    required this.subtitle,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xxLarge),
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(AppRadii.extraLarge),
      ),
      child: Column(
        children: [
          Icon(icon, size: 30, color: AppColors.primary),
          const SizedBox(height: 10),
          Text(title, style: AppTextStyles.subtitle),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}

class PanelInfoCard extends StatelessWidget {
  const PanelInfoCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.body,
    required this.trailing,
    super.key,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String body;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.large),
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(AppRadii.large),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadii.small),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(body, style: AppTextStyles.caption),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(trailing, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

class FaqTile extends StatelessWidget {
  const FaqTile({required this.question, required this.answer, super.key});

  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(AppRadii.large),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.large,
          vertical: 2,
        ),
        childrenPadding: const EdgeInsets.fromLTRB(
          AppSpacing.large,
          0,
          AppSpacing.large,
          AppSpacing.large,
        ),
        iconColor: AppColors.primary,
        collapsedIconColor: AppColors.textSecondary,
        title: Text(
          question,
          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
        ),
        children: [Text(answer, style: AppTextStyles.caption)],
      ),
    );
  }
}

class AssetOptionSelector extends StatelessWidget {
  const AssetOptionSelector({
    required this.options,
    required this.selectedAsset,
    required this.onSelected,
    this.labels = const {},
    super.key,
  });

  final List<String> options;
  final String selectedAsset;
  final ValueChanged<String> onSelected;
  final Map<String, String> labels;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options.map((assetPath) {
        final isSelected = assetPath == selectedAsset;
        return GestureDetector(
          onTap: () => onSelected(assetPath),
          child: Container(
            width: 108,
            padding: const EdgeInsets.all(AppSpacing.small),
            decoration: BoxDecoration(
              color: AppColors.surfaceRaised,
              borderRadius: BorderRadius.circular(AppRadii.large),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadii.xSmall),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Image.asset(
                      assetPath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.borderSoft,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.broken_image_outlined,
                            color: AppColors.textTertiary,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  labels[assetPath] ?? assetLabel(assetPath),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

IconData notificationIcon(NotificationType type) {
  switch (type) {
    case NotificationType.alert:
      return Icons.warning_amber_rounded;
    case NotificationType.approval:
      return Icons.image_search_rounded;
    case NotificationType.info:
      return Icons.info_outline_rounded;
    case NotificationType.report:
      return Icons.flag_outlined;
  }
}

Color notificationColor(NotificationType type) {
  switch (type) {
    case NotificationType.alert:
      return AppColors.red;
    case NotificationType.approval:
      return AppColors.green;
    case NotificationType.info:
      return AppColors.primary;
    case NotificationType.report:
      return AppColors.yellow;
  }
}

String statusText(ItemStatus status) {
  switch (status) {
    case ItemStatus.safe:
      return '소지 중';
    case ItemStatus.lost:
      return '분실';
    case ItemStatus.contact:
      return '연락 중';
  }
}

String assetLabel(String assetPath) {
  switch (assetPath) {
    case AppAssets.icon:
      return '기본 이미지';
    case AppAssets.splashIcon:
      return '보호 이미지';
    default:
      return '이미지';
  }
}
