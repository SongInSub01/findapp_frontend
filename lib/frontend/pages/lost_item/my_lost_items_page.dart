import 'package:flutter/material.dart';

import 'package:my_flutter_starter/core/utils/formatters.dart';
import 'package:my_flutter_starter/data/models/app_models.dart';
import 'package:my_flutter_starter/frontend/pages/lost_item/lost_item_editor_page.dart';
import 'package:my_flutter_starter/frontend/common/theme/app_colors.dart';
import 'package:my_flutter_starter/frontend/common/theme/app_text_styles.dart';
import 'package:my_flutter_starter/frontend/common/widgets/app_buttons.dart';
import 'package:my_flutter_starter/frontend/common/widgets/secure_photo_thumbnail.dart';
import 'package:my_flutter_starter/frontend/frontend_scope.dart';
import 'lost_item_detail_page.dart';

class MyLostItemsPage extends StatefulWidget {
  const MyLostItemsPage({super.key});

  @override
  State<MyLostItemsPage> createState() => _MyLostItemsPageState();
}

class _MyLostItemsPageState extends State<MyLostItemsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.controllerOf(context);
    final state = controller.state;

    final myItems = state.lostItems.where((item) => item.isMine).toList();
    final activeItems =
        myItems.where((item) => !item.isResolved).toList();
    final foundItems =
        myItems.where((item) => item.isResolved).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          '내 물건 관리',
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
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF2563EB),
          unselectedLabelColor: const Color(0xFF9CA3AF),
          indicatorColor: const Color(0xFF2563EB),
          indicatorWeight: 3,
          dividerColor: const Color(0xFFF1F5F9),
          tabs: [
            Tab(text: '분실 중 (${activeItems.length})'),
            Tab(text: '찾은 물건 (${foundItems.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _ItemList(
            items: activeItems,
            emptyMessage: '현재 분실 중인 물건이 없습니다',
            isFound: false,
            onEdit: (item) => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => LostItemEditorPage(
                  controller: controller,
                  existingItem: item,
                ),
              ),
            ),
            onDelete: (item) => _confirmDelete(context, controller, item),
            onMarkFound: (item) => _confirmMarkFound(context, controller, item),
            onTap: (item) => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => LostItemDetailPage(item: item),
              ),
            ),
          ),
          _ItemList(
            items: foundItems,
            emptyMessage: '찾은 물건이 없습니다',
            isFound: true,
            onEdit: (_) {},
            onDelete: (item) => _confirmDelete(context, controller, item),
            onMarkFound: (_) {},
            onTap: (item) => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => LostItemDetailPage(item: item),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmMarkFound(
    BuildContext context,
    dynamic controller,
    LostItem item,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('찾음 처리'),
        content: Text('"${item.title}"을 찾으셨나요?\n찾음으로 처리하면 다른 사람들에게 보이지 않습니다.'),
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('찾음 처리되었습니다. 다른 사람들에게 더 이상 보이지 않습니다.')),
        );
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    dynamic controller,
    LostItem item,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('분실물 삭제'),
        content: Text('"${item.title}" 게시글을 삭제하시겠습니까?'),
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
}

class _ItemList extends StatelessWidget {
  const _ItemList({
    required this.items,
    required this.emptyMessage,
    required this.isFound,
    required this.onEdit,
    required this.onDelete,
    required this.onMarkFound,
    required this.onTap,
  });

  final List<LostItem> items;
  final String emptyMessage;
  final bool isFound;
  final void Function(LostItem) onEdit;
  final void Function(LostItem) onDelete;
  final void Function(LostItem) onMarkFound;
  final void Function(LostItem) onTap;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isFound
                  ? Icons.check_circle_outline_rounded
                  : Icons.inventory_2_outlined,
              size: 64,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style:
                  AppTextStyles.body.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _MyItemCard(
          item: item,
          isFound: isFound,
          onTap: () => onTap(item),
          onEdit: () => onEdit(item),
          onDelete: () => onDelete(item),
          onMarkFound: () => onMarkFound(item),
        );
      },
    );
  }
}

class _MyItemCard extends StatelessWidget {
  const _MyItemCard({
    required this.item,
    required this.isFound,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onMarkFound,
  });

  final LostItem item;
  final bool isFound;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onMarkFound;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isFound
              ? const Color(0xFFF0FFF4)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isFound
                ? AppColors.green.withValues(alpha: 0.3)
                : AppColors.primary.withValues(alpha: 0.2),
          ),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    SecurePhotoThumbnail(
                      photoStatus: PhotoAccessStatus.approved,
                      assetPath: item.photoAssetPath,
                      size: 72,
                    ),
                    if (isFound)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.green.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: AppTextStyles.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      _Row(icon: Icons.place_outlined, text: item.location),
                      const SizedBox(height: 4),
                      _Row(
                        icon: Icons.calendar_today_outlined,
                        text: _formatDate(item.happenedAt) ?? _formatDate(item.createdAt) ?? item.timeLabel,
                      ),
                      if (!isFound) ...[
                      const SizedBox(height: 4),
                      _Row(
                        icon: Icons.card_giftcard_rounded,
                        text: '사례금 ${Formatters.money(item.reward)}',
                        color: AppColors.primary,
                      ),
                      ],
                    ],
                  ),
                ),
                if (isFound)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      '찾음',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.green,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                else
                  _StatusChip(status: item.status),
              ],
            ),
            const SizedBox(height: 14),
            if (!isFound)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_outlined, size: 15),
                      label: const Text('편집'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onDelete,
                      icon:
                          const Icon(Icons.delete_outline_rounded, size: 15),
                      label: const Text('삭제'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.red,
                        side: const BorderSide(color: AppColors.red),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AppPrimaryButton(
                      label: '찾음',
                      icon: Icons.check_circle_outline_rounded,
                      onPressed: onMarkFound,
                      expanded: true,
                    ),
                  ),
                ],
              )
            else
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline_rounded, size: 15),
                  label: const Text('삭제'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.red,
                    side: const BorderSide(color: AppColors.red),
                  ),
                ),
              ),
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

class _Row extends StatelessWidget {
  const _Row({required this.icon, required this.text, this.color});

  final IconData icon;
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 13, color: color ?? AppColors.textTertiary),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final ItemStatus status;

  @override
  Widget build(BuildContext context) {
    final label = switch (status) {
      ItemStatus.lost => '분실 중',
      ItemStatus.contact => '연락 중',
      ItemStatus.safe => '소지 중',
    };
    final color = AppColors.status(status);
    final bg = AppColors.statusBackground(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
