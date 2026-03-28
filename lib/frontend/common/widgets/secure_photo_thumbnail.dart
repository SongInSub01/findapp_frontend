import 'package:flutter/material.dart';

import 'package:my_flutter_starter/data/models/app_models.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class SecurePhotoThumbnail extends StatelessWidget {
  const SecurePhotoThumbnail({
    required this.photoStatus,
    this.assetPath,
    this.size = 80,
    super.key,
  });

  final PhotoAccessStatus photoStatus;
  final String? assetPath;
  final double size;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(18);
    final compact = size < 56;
    return ClipRRect(
      borderRadius: borderRadius,
      child: Container(
        width: size,
        height: size,
        color: Colors.white,
        child: switch (photoStatus) {
          PhotoAccessStatus.locked => _buildLockedState(
              label: compact ? '잠금' : '사진 잠금 상태',
              icon: Icons.lock_outline,
              compact: compact,
            ),
          PhotoAccessStatus.pending => _buildPendingState(compact: compact),
          PhotoAccessStatus.approved => _buildApprovedState(),
        },
      ),
    );
  }

  Widget _buildLockedState({
    required String label,
    required IconData icon,
    required bool compact,
  }) {
    return Container(
      color: AppColors.borderLight,
      padding: EdgeInsets.all(compact ? 6 : 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.textTertiary, size: compact ? 14 : 20),
          SizedBox(height: compact ? 2 : 6),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: compact
                ? AppTextStyles.caption.copyWith(fontSize: 9, height: 1.1)
                : AppTextStyles.caption,
          ),
        ],
      ),
    );
  }

  Widget _buildPendingState({required bool compact}) {
    return Container(
      color: AppColors.yellowBg,
      padding: EdgeInsets.all(compact ? 6 : 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.hourglass_top_rounded,
            color: AppColors.yellow,
            size: compact ? 14 : 20,
          ),
          SizedBox(height: compact ? 2 : 6),
          Text(
            compact ? '대기' : '승인 대기 상태',
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: (compact
                    ? AppTextStyles.caption.copyWith(fontSize: 9, height: 1.1)
                    : AppTextStyles.caption)
                .copyWith(color: AppColors.yellow),
          ),
        ],
      ),
    );
  }

  Widget _buildApprovedState() {
    return Container(
      color: const Color(0xFFEFF6FF),
      child: assetPath == null
          ? const Center(
              child: Icon(Icons.image_outlined, color: AppColors.primary),
            )
          : Image.asset(
              assetPath!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Icon(Icons.broken_image_outlined, color: AppColors.textTertiary),
                );
              },
            ),
    );
  }
}
