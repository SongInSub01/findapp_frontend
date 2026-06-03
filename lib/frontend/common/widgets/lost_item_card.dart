import 'package:flutter/material.dart';

import 'package:my_flutter_starter/core/utils/formatters.dart';
import 'package:my_flutter_starter/data/models/app_models.dart';
import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'app_buttons.dart';
import 'secure_photo_thumbnail.dart';
import 'status_badge.dart';

class LostItemCard extends StatelessWidget {
  const LostItemCard({
    required this.item,
    required this.onMessage,
    required this.onTap,
    this.onEdit,
    super.key,
  });

  final LostItem item;
  final VoidCallback onMessage;
  final VoidCallback onTap;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.medium),
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
          border: item.isMine
              ? Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  width: 1.5,
                )
              : null,
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SecurePhotoThumbnail(
                  photoStatus: item.isMine
                      ? PhotoAccessStatus.approved
                      : item.photoStatus,
                  assetPath: item.photoAssetPath,
                  size: 92,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.subtitle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (item.isMine)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(99),
                              ),
                              child: Text(
                                '내 물건',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            )
                          else
                            StatusBadge(status: item.status, small: true),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _MetaLine(
                        icon: Icons.place_outlined,
                        text: item.location,
                      ),
                      const SizedBox(height: 4),
                      _MetaLine(
                        icon: Icons.calendar_today_outlined,
                        text: _formatDate(item.happenedAt) ?? _formatDate(item.createdAt) ?? item.timeLabel,
                      ),
                      const SizedBox(height: 4),
                      _MetaLine(
                        icon: Icons.near_me_outlined,
                        text: item.distance,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.card_giftcard_rounded,
                            size: 14,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '사례금 ${Formatters.money(item.reward)}',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (!item.isMine) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.medium,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: item.photoStatus == PhotoAccessStatus.approved
                      ? AppColors.surfaceSuccess
                      : item.photoStatus == PhotoAccessStatus.pending
                      ? AppColors.surfaceWarning
                      : AppColors.surfaceSoft,
                  borderRadius: BorderRadius.circular(AppRadii.xSmall),
                ),
                child: Row(
                  children: [
                    Icon(
                      item.photoStatus == PhotoAccessStatus.approved
                          ? Icons.verified_outlined
                          : item.photoStatus == PhotoAccessStatus.pending
                          ? Icons.hourglass_top_rounded
                          : Icons.lock_outline,
                      size: 16,
                      color: item.photoStatus == PhotoAccessStatus.approved
                          ? AppColors.green
                          : item.photoStatus == PhotoAccessStatus.pending
                          ? AppColors.yellow
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.photoStatus == PhotoAccessStatus.approved
                            ? '승인 완료 상태: 주인 허가 후 사진 열람 가능'
                            : item.photoStatus == PhotoAccessStatus.pending
                            ? '승인 대기 상태: 메시지 확인 후 사진 공개 여부가 결정됩니다'
                            : '사진 잠금 상태: 먼저 주인에게 메시지를 보내야 합니다',
                        style: AppTextStyles.caption.copyWith(
                          color: item.photoStatus == PhotoAccessStatus.approved
                              ? AppColors.green
                              : item.photoStatus == PhotoAccessStatus.pending
                              ? AppColors.yellow
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              AppPrimaryButton(
                label: '주인에게 메시지 보내기',
                icon: Icons.chat_bubble_outline_rounded,
                onPressed: onMessage,
                expanded: true,
              ),
            ] else ...[
              AppPrimaryButton(
                label: '상세보기',
                icon: Icons.arrow_forward_rounded,
                onPressed: onTap,
                expanded: true,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String? _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final dt = DateTime.parse(raw).toLocal();
      return '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return null;
    }
  }
}

class _MetaLine extends StatelessWidget {
  const _MetaLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textTertiary),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption,
          ),
        ),
      ],
    );
  }
}
