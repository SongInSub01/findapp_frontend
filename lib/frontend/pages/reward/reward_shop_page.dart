import 'package:flutter/material.dart';

import 'package:my_flutter_starter/data/models/app_models.dart';
import 'package:my_flutter_starter/frontend/common/theme/app_colors.dart';
import 'package:my_flutter_starter/frontend/frontend_scope.dart';

class RewardShopPage extends StatefulWidget {
  const RewardShopPage({super.key});

  @override
  State<RewardShopPage> createState() => _RewardShopPageState();
}

class _RewardShopPageState extends State<RewardShopPage> {
  String? _purchasingItemId;

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.controllerOf(context);
    final rewardStatus = controller.state.rewardStatus;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          '리워드 상점',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primary.withValues(alpha: 0.85),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '현재 보유 포인트',
                  style: TextStyle(color: Colors.white70, fontSize: 15),
                ),
                const SizedBox(height: 12),
                Text(
                  '${rewardStatus.currentPoints} P',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text(
                    '퀘스트 리워드로 적립한 포인트를 사용할 수 있습니다.',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: rewardStatus.shopItems.isEmpty
                ? const Center(child: Text('구매 가능한 리워드 상품이 없습니다.'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: rewardStatus.shopItems.length,
                    itemBuilder: (context, index) {
                      final item = rewardStatus.shopItems[index];
                      return _ShopItemCard(
                        item: item,
                        currentPoints: rewardStatus.currentPoints,
                        isPurchasing: _purchasingItemId == item.id,
                        onPurchase: () => _purchase(context, item),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _purchase(BuildContext context, RewardShopItem item) async {
    final controller = AppScope.controllerOf(context);
    setState(() => _purchasingItemId = item.id);
    try {
      await controller.purchaseRewardShopItem(item.id);
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${item.title} 구매가 완료되었습니다.')));
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _purchasingItemId = null);
      }
    }
  }
}

class _ShopItemCard extends StatelessWidget {
  const _ShopItemCard({
    required this.item,
    required this.currentPoints,
    required this.isPurchasing,
    required this.onPurchase,
  });

  final RewardShopItem item;
  final int currentPoints;
  final bool isPurchasing;
  final VoidCallback onPurchase;

  @override
  Widget build(BuildContext context) {
    final canPurchase = currentPoints >= item.pricePoints && !item.purchased;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.primary.withValues(alpha: 0.12),
            child: Icon(
              _iconForItem(item.iconKey),
              color: AppColors.primary,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.description,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                Text(
                  '${item.pricePoints}P',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: canPurchase && !isPurchasing ? onPurchase : null,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text(
              item.purchased
                  ? '구매 완료'
                  : isPurchasing
                  ? '구매 중...'
                  : '구매',
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconForItem(String iconKey) {
    switch (iconKey) {
      case 'coffee':
        return Icons.local_cafe;
      case 'store':
        return Icons.store;
      case 'delivery':
        return Icons.delivery_dining;
      case 'flash':
        return Icons.flash_on;
      case 'premium':
        return Icons.workspace_premium;
      case 'palette':
        return Icons.palette;
      default:
        return Icons.card_giftcard;
    }
  }
}
