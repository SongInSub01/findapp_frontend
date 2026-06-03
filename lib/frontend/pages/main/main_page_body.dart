import 'package:flutter/material.dart';

import 'package:my_flutter_starter/data/models/app_models.dart';
import 'package:my_flutter_starter/frontend/common/theme/app_colors.dart';
import 'package:my_flutter_starter/frontend/common/theme/app_text_styles.dart';
import 'package:my_flutter_starter/frontend/common/widgets/app_buttons.dart';
import 'package:my_flutter_starter/frontend/common/widgets/device_card.dart';
import 'package:my_flutter_starter/frontend/common/widgets/lost_item_card.dart';

import 'main_page_handler.dart';

class MainPageBody extends StatelessWidget {
  const MainPageBody({required this.state, required this.handler, super.key});

  final AppState state;
  final MainPageHandler handler;

  @override
  Widget build(BuildContext context) {
    final lostCandidates = state.myDevices.where(
      (device) => device.status == ItemStatus.lost,
    );
    final lostDevice = lostCandidates.isEmpty ? null : lostCandidates.first;
    final unreadNotifications = state.notifications
        .where((item) => !item.isRead)
        .length;
    final isCompact = MediaQuery.sizeOf(context).width < 390;
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Header(
                    name: state.userProfile.name,
                    unreadNotifications: unreadNotifications,
                    onMenuTap: handler.openMenu,
                    onBellTap: handler.openNotifications,
                  ),
                  const SizedBox(height: 18),
                  if (lostDevice != null)
                    _LostAlertBanner(
                      device: lostDevice,
                      onTrackTap: () => handler.trackDevice(lostDevice.id),
                      onDismissTap: () => handler.dismissAlert(lostDevice.id),
                      isCompact: isCompact,
                    )
                  else
                    _SafeBanner(safeZoneCount: state.safeZones.length),
                  const SizedBox(height: 24),
                  _SectionHeader(
                    title: '등록된 기기',
                    actionLabel: '+ 추가',
                    onActionTap: () => handler.openBleEditor(),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 168,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: state.myDevices.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final device = state.myDevices[index];
                        return DeviceCard(
                          device: device,
                          onTap: () => handler.trackDevice(device.id),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  AppPrimaryButton(
                    label: '분실물 등록',
                    icon: Icons.add_rounded,
                    onPressed: handler.openLostItemEditor,
                    expanded: true,
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: handler.openDiscovery,
                      icon: const Icon(Icons.manage_search_rounded, size: 18),
                      label: const Text('분실·습득 탐색'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: handler.openRewardEditor,
                      icon: const Icon(Icons.card_giftcard_rounded, size: 18),
                      label: const Text('사례금 등록'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primaryDark,
                        minimumSize: const Size.fromHeight(44),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '사례금은 분실물 등록 이후에 연결해도 됩니다.',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      const Expanded(
                        child: Text('주변 분실물 리스트', style: AppTextStyles.title),
                      ),
                      IconButton(
                        onPressed: handler.refreshNearbyItems,
                        icon: const Icon(
                          Icons.refresh_rounded,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  for (final item in state.lostItems)
                    LostItemCard(
                      item: item,
                      onMessage: () => handler.openChatForLostItem(item),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.name,
    required this.unreadNotifications,
    required this.onMenuTap,
    required this.onBellTap,
  });

  final String name;
  final int unreadNotifications;
  final VoidCallback onMenuTap;
  final VoidCallback onBellTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: onMenuTap,
          borderRadius: BorderRadius.circular(20),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '환영합니다',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text('$name 님', style: AppTextStyles.title),
                ],
              ),
            ],
          ),
        ),
        const Spacer(),
        IconButton.filledTonal(
          onPressed: onBellTap,
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.text,
          ),
          icon: Stack(
            children: [
              const Icon(Icons.notifications_none_rounded),
              if (unreadNotifications > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SafeBanner extends StatelessWidget {
  const _SafeBanner({required this.safeZoneCount});

  final int safeZoneCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryLight, AppColors.primary],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '안전 모니터링 중',
                    style: AppTextStyles.caption.copyWith(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  '내 물건이\n안전하게 연결됨',
                  style: AppTextStyles.headline.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  '안심 구역 $safeZoneCount곳에서 BLE 알림이 자동 완화됩니다.',
                  style: AppTextStyles.body.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shield_outlined,
              color: Colors.white,
              size: 34,
            ),
          ),
        ],
      ),
    );
  }
}

class _LostAlertBanner extends StatelessWidget {
  const _LostAlertBanner({
    required this.device,
    required this.onTrackTap,
    required this.onDismissTap,
    required this.isCompact,
  });

  final BleDevice device;
  final VoidCallback onTrackTap;
  final VoidCallback onDismissTap;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFEE2E2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.circle, size: 8, color: AppColors.red),
              const SizedBox(width: 6),
              Text(
                '분실 경고',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.red,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              const Icon(Icons.warning_amber_rounded, color: AppColors.red),
            ],
          ),
          const SizedBox(height: 10),
          Text('${device.name}과의 연결이 끊겼습니다', style: AppTextStyles.title),
          const SizedBox(height: 6),
          Text(
            '마지막 위치: ${device.location} (${device.lastSeen})',
            style: AppTextStyles.bodySecondary,
          ),
          const SizedBox(height: 16),
          isCompact
              ? Column(
                  children: [
                    AppPrimaryButton(
                      label: '위치 추적',
                      icon: Icons.near_me_outlined,
                      onPressed: onTrackTap,
                      expanded: true,
                    ),
                    const SizedBox(height: 10),
                    AppSecondaryButton(
                      label: '오알림 처리',
                      onPressed: onDismissTap,
                      expanded: true,
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: AppPrimaryButton(
                        label: '위치 추적',
                        icon: Icons.near_me_outlined,
                        onPressed: onTrackTap,
                        expanded: true,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AppSecondaryButton(
                        label: '오알림 처리',
                        onPressed: onDismissTap,
                        expanded: true,
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onActionTap,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onActionTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title, style: AppTextStyles.title)),
        TextButton(onPressed: onActionTap, child: Text(actionLabel)),
      ],
    );
  }
}
