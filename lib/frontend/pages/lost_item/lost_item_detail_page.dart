import 'package:flutter/material.dart';

import 'package:my_flutter_starter/core/utils/formatters.dart';
import 'package:my_flutter_starter/data/models/app_models.dart';
import 'package:my_flutter_starter/frontend/pages/lost_item/lost_item_editor_page.dart';
import 'package:my_flutter_starter/frontend/common/theme/app_colors.dart';
import 'package:my_flutter_starter/frontend/common/theme/app_text_styles.dart';
import 'package:my_flutter_starter/frontend/common/widgets/app_buttons.dart';
import 'package:my_flutter_starter/frontend/common/widgets/secure_photo_thumbnail.dart';
import 'package:my_flutter_starter/frontend/common/widgets/status_badge.dart';
import 'package:my_flutter_starter/frontend/frontend_scope.dart';

class LostItemDetailPage extends StatelessWidget {
  const LostItemDetailPage({required this.item, super.key});

  final LostItem item;

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.controllerOf(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          '분실물 상세',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: Color(0xFF2563EB),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: const Color(0xFFF1F5F9),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          _PhotoSection(item: item),
          const SizedBox(height: 20),
          _InfoCard(item: item),
          const SizedBox(height: 16),
          _DescriptionCard(item: item),
          const SizedBox(height: 24),
          if (item.isMine) ...[
            _MyItemActions(
              onEdit: () => _showEditDialog(context, controller),
              onDelete: () => _confirmDelete(context, controller),
              onMarkFound: () => _confirmMarkFound(context, controller),
            ),
          ] else ...[
            AppPrimaryButton(
              label: '주인에게 메시지 보내기',
              icon: Icons.chat_bubble_outline_rounded,
              onPressed: () => _openChat(context, controller),
              expanded: true,
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _openChat(
    BuildContext context,
    dynamic controller,
  ) async {
    try {
      final threadId =
          await controller.openOrCreateChatForItem(item.id) as String;
      if (!context.mounted) return;
      Navigator.of(context).pushNamed('/chat-detail', arguments: threadId);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
        ),
      );
    }
  }

  void _showEditDialog(BuildContext context, dynamic controller) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LostItemEditorPage(
          controller: controller,
          existingItem: item,
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, dynamic controller) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('분실물 삭제'),
        content: const Text('이 분실물 게시글을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('삭제', style: TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      try {
        await controller.deleteLostItem(itemId: item.id);
        if (!context.mounted) return;
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('삭제되었습니다.')),
        );
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    }
  }

  Future<void> _confirmMarkFound(
    BuildContext context,
    dynamic controller,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('찾음 처리'),
        content: const Text('분실물을 찾으셨나요?\n찾음으로 처리하면 다른 사람들에게 보이지 않습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('찾음 처리'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      try {
        await controller.markLostItemFound(item: item);
        if (!context.mounted) return;
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('찾음 처리되었습니다. 내 물건 관리에서 확인하세요.'),
          ),
        );
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(e.toString().replaceFirst('Exception: ', '')),
          ),
        );
      }
    }
  }
}

class _PhotoSection extends StatelessWidget {
  const _PhotoSection({required this.item});

  final LostItem item;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          SecurePhotoThumbnail(
            photoStatus: item.isMine
                ? PhotoAccessStatus.approved
                : item.photoStatus,
            assetPath: item.photoAssetPath,
            size: 160,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                item.title,
                style: AppTextStyles.title.copyWith(fontSize: 22),
              ),
              const SizedBox(width: 10),
              if (!item.isMine) StatusBadge(status: item.status),
            ],
          ),
          if (item.isMine) ...[
            const SizedBox(height: 6),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(99),
              ),
              child: Text(
                '내 분실물',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.item});

  final LostItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('정보', style: AppTextStyles.subtitle),
          const SizedBox(height: 12),
          _DetailRow(
            icon: Icons.place_outlined,
            label: '분실 위치',
            value: item.location,
          ),
          const SizedBox(height: 10),
          _DetailRow(
            icon: Icons.calendar_today_outlined,
            label: '잃어버린 날',
            value: _formatDate(item.happenedAt) ?? _formatDate(item.createdAt) ?? item.timeLabel,
          ),
          const SizedBox(height: 10),
          _DetailRow(
            icon: Icons.near_me_outlined,
            label: '거리',
            value: item.distance,
          ),
          const SizedBox(height: 10),
          _DetailRow(
            icon: Icons.card_giftcard_rounded,
            label: '사례금',
            value: Formatters.money(item.reward),
            valueColor: AppColors.primary,
          ),
          if (!item.isMine) ...[
            const SizedBox(height: 10),
            _DetailRow(
              icon: Icons.person_outline_rounded,
              label: '등록자',
              value: item.ownerName,
            ),
          ],
        ],
      ),
    );
  }

  String? _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final dt = DateTime.parse(raw).toLocal();
      return '${dt.year}년 ${dt.month}월 ${dt.day}일';
    } catch (_) {
      return raw;
    }
  }
}

class _DescriptionCard extends StatelessWidget {
  const _DescriptionCard({required this.item});

  final LostItem item;

  @override
  Widget build(BuildContext context) {
    if (item.description.isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('상세 설명', style: AppTextStyles.subtitle),
          const SizedBox(height: 10),
          Text(
            item.description,
            style: AppTextStyles.body.copyWith(height: 1.6),
          ),
        ],
      ),
    );
  }
}

class _MyItemActions extends StatelessWidget {
  const _MyItemActions({
    required this.onEdit,
    required this.onDelete,
    required this.onMarkFound,
  });

  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onMarkFound;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppPrimaryButton(
          label: '찾음 처리',
          icon: Icons.check_circle_outline_rounded,
          onPressed: onMarkFound,
          expanded: true,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('편집'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                label: const Text('삭제'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.red,
                  side: const BorderSide(color: AppColors.red),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.textTertiary),
        const SizedBox(width: 8),
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ),
      ],
    );
  }
}
