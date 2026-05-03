import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:my_flutter_starter/data/models/app_models.dart';
import 'package:my_flutter_starter/core/utils/formatters.dart';
import 'package:my_flutter_starter/frontend/common/theme/app_colors.dart';
import 'package:my_flutter_starter/frontend/common/theme/app_text_styles.dart';
import 'package:my_flutter_starter/frontend/common/widgets/app_buttons.dart';
import 'package:my_flutter_starter/frontend/common/widgets/secure_photo_thumbnail.dart';
import 'package:my_flutter_starter/frontend/common/widgets/status_badge.dart';

import 'map_kakao_bridge.dart';
import 'map_page_handler.dart';
import 'map_platform_io.dart' if (dart.library.html) 'map_platform_web.dart';
import 'map_view_models.dart';

class MapPageBody extends StatelessWidget {
  const MapPageBody({
    required this.isVisible,
    required this.state,
    required this.currentLocation,
    required this.sheetExtent,
    required this.onSheetExtentChanged,
    required this.locationHint,
    required this.isFetchingLocation,
    required this.onLocateCurrentLocation,
    required this.filter,
    required this.sort,
    required this.layerMode,
    required this.onFilterChanged,
    required this.handler,
    super.key,
  });

  final bool isVisible;
  final AppState state;
  final CurrentLocation? currentLocation;
  final double sheetExtent;
  final ValueChanged<double> onSheetExtentChanged;
  final String? locationHint;
  final bool isFetchingLocation;
  final VoidCallback onLocateCurrentLocation;
  final MapFilter filter;
  final MapSort sort;
  final MapLayerMode layerMode;
  final ValueChanged<MapFilter> onFilterChanged;
  final MapPageHandler handler;

  @override
  Widget build(BuildContext context) {
    final currentLatLng = currentLocation == null
        ? null
        : LatLng(currentLocation!.latitude, currentLocation!.longitude);
    final markers = [
      ...MapMarkerBuilder.fromState(state, anchorLatLng: currentLatLng),
      if (currentLatLng != null)
        MapMarkerViewData(
          id: 'current-location',
          name: '내 위치',
          subtitle: '현재 GPS 위치',
          status: ItemStatus.safe,
          latLng: currentLatLng,
          isMine: true,
          distanceValue: 0,
          customOverlayContent: _currentLocationOverlayContent(),
          zIndex: 999,
        ),
    ];
    final filteredMarkers = markers.where((marker) {
      switch (filter) {
        case MapFilter.all:
          return true;
        case MapFilter.lost:
          return marker.status == ItemStatus.lost;
        case MapFilter.contact:
          return marker.status == ItemStatus.contact;
        case MapFilter.safe:
          return marker.status == ItemStatus.safe;
      }
    }).toList();
    final currentLocationMarkers = markers
        .where((marker) => marker.id == 'current-location')
        .toList();
    final visibleMarkers = [
      ...filteredMarkers.where((marker) => marker.id != 'current-location'),
      ...currentLocationMarkers.take(1),
    ];

    if (sort == MapSort.distance) {
      visibleMarkers.sort((a, b) => a.distanceValue.compareTo(b.distanceValue));
    }

    final activeChatItemIds = state.chatThreads
        .map((thread) => thread.itemId)
        .toSet();
    final visibleLostItems = _visibleLostItems(
      state.lostItems,
      activeChatItemIds: activeChatItemIds,
      filter: filter,
      sort: sort,
    );
    final supportsMapSurface = kIsWeb || supportsNativeKakaoMap;

    if (!isVisible) {
      return const SizedBox.shrink();
    }

    final isDarkTheme = state.alertSettings.mapTheme == MapThemeMode.dark;
    final palette = _MapThemePalette.forMode(isDarkTheme);

    return SafeArea(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: isDarkTheme
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF0B1220),
                    Color(0xFF111827),
                    Color(0xFF0F172A),
                  ],
                )
              : const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFF7FAFF),
                    Color(0xFFF8FAFC),
                    AppColors.background,
                  ],
                ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final sheetMinSize = supportsMapSurface ? 0.20 : 0.18;
            final sheetMaxSize = supportsMapSurface ? 0.84 : 0.92;
            final resolvedSheetExtent = sheetExtent
                .clamp(sheetMinSize, sheetMaxSize)
                .toDouble();
            final sheetInitialSize = resolvedSheetExtent;
            final useSnap = supportsMapSurface;
            final sheetSnapSizes = useSnap
                ? <double>{
                    sheetMinSize,
                    sheetInitialSize,
                    sheetMaxSize,
                  }.toList()
                : null;
            final sheetDockHeight = constraints.maxHeight * resolvedSheetExtent;
            return Stack(
              children: [
                Positioned.fill(
                  child: supportsMapSurface
                      ? Stack(
                          children: [
                            KakaoMap(
                              onMapCreated: (controller) {
                                handler.attachMapController(controller);
                              },
                              markers: visibleMarkers
                                  .map(
                                    (m) => Marker(
                                      markerId: m.id,
                                      latLng: m.latLng,
                                      width: m.id == 'current-location'
                                          ? 28
                                          : 40,
                                      height: m.id == 'current-location'
                                          ? 40
                                          : 40,
                                      customOverlayContent:
                                          m.customOverlayContent,
                                      zIndex: m.zIndex,
                                    ),
                                  )
                                  .toList(),
                              onMarkerTap: (markerId, latLng, zoomLevel) {
                                if (markerId == 'current-location') {
                                  handler.focusCurrentLocation();
                                  return;
                                }
                                final tappedMarker = visibleMarkers
                                    .where((marker) => marker.id == markerId)
                                    .toList();
                                if (tappedMarker.isEmpty) {
                                  return;
                                }
                                unawaited(
                                  handler.handleMarkerAction(
                                    tappedMarker.first,
                                  ),
                                );
                              },
                            ),
                            Positioned.fill(
                              child: IgnorePointer(
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        palette.mapWash.withValues(alpha: 0.10),
                                        Colors.transparent,
                                        palette.mapWash.withValues(
                                          alpha: isDarkTheme ? 0.18 : 0.08,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : _MapUnavailableView(
                          palette: palette,
                          itemCount: visibleMarkers.length,
                          onHomeTap: () =>
                              handler.controller.switchTab(AppTab.main),
                        ),
                ),
                Positioned(
                  top: 8,
                  right: 16,
                  child: _MapAvatarButton(
                    palette: palette,
                    photoAssetPath: state.userProfile.photoAssetPath,
                    initials: state.userProfile.initials,
                    onTap: handler.openMenu,
                  ),
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  top: 0,
                  child: SafeArea(
                    bottom: false,
                    child: _StatusRail(
                      palette: palette,
                      filter: filter,
                      layerMode: layerMode,
                      onFilterChanged: onFilterChanged,
                      onLayerModeTap: handler.cycleLayerMode,
                    ),
                  ),
                ),
                Positioned.fill(
                  child: NotificationListener<DraggableScrollableNotification>(
                    onNotification: (notification) {
                      if (notification.depth == 0) {
                        onSheetExtentChanged(notification.extent);
                      }
                      return false;
                    },
                    child: DraggableScrollableSheet(
                      expand: false,
                      minChildSize: sheetMinSize,
                      initialChildSize: sheetInitialSize,
                      maxChildSize: sheetMaxSize,
                      shouldCloseOnMinExtent: true,
                      snap: useSnap,
                      snapSizes: sheetSnapSizes,
                      builder: (context, scrollController) {
                        return _NearbySheet(
                          palette: palette,
                          scrollController: scrollController,
                          items: visibleLostItems,
                          activeChatItemIds: activeChatItemIds,
                          currentLocation: currentLocation,
                          locationHint: locationHint,
                          isFetchingLocation: isFetchingLocation,
                          onRefresh: handler.controller.refreshNearbyItems,
                          onTapItem: handler.handleMarkerAction,
                          onLocateCurrentLocation: onLocateCurrentLocation,
                          onOpenSettings: () =>
                              handler.controller.switchTab(AppTab.setting),
                          anchorLatLng: currentLatLng,
                        );
                      },
                    ),
                  ),
                ),
                Positioned(
                  right: 16,
                  bottom: sheetDockHeight + 18,
                  child: FloatingActionButton.small(
                    heroTag: 'locate_map',
                    backgroundColor: palette.fabBackground,
                    foregroundColor: palette.fabForeground,
                    onPressed: currentLatLng == null
                        ? onLocateCurrentLocation
                        : handler.focusCurrentLocation,
                    child: const Icon(Icons.my_location_outlined),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _MapUnavailableView extends StatelessWidget {
  const _MapUnavailableView({
    required this.palette,
    required this.itemCount,
    required this.onHomeTap,
  });

  final _MapThemePalette palette;
  final int itemCount;
  final VoidCallback onHomeTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: palette.cardBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: palette.cardBorder),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: palette.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.map_outlined,
                  color: AppColors.primary,
                  size: 34,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '지도는 현재 기기에서 미리보기를 준비 중입니다',
                textAlign: TextAlign.center,
                style: AppTextStyles.subtitle.copyWith(
                  color: palette.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '주변 분실물 $itemCount건을 확인할 수 있지만, 이 기기에서는 실제 지도 타일을 표시하지 못합니다.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySecondary.copyWith(
                  color: palette.secondaryText,
                ),
              ),
              const SizedBox(height: 18),
              AppPrimaryButton(
                label: '홈 탭으로 돌아가기',
                icon: Icons.home_rounded,
                onPressed: onHomeTap,
                expanded: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MapAvatarButton extends StatelessWidget {
  const _MapAvatarButton({
    required this.palette,
    required this.photoAssetPath,
    required this.initials,
    required this.onTap,
  });

  final _MapThemePalette palette;
  final String photoAssetPath;
  final String initials;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: palette.cardBackground,
          shape: BoxShape.circle,
          border: Border.all(color: palette.cardBorder),
          boxShadow: [
            BoxShadow(
              color: palette.shadow,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipOval(
          child: photoAssetPath.isNotEmpty
              ? Image.asset(
                  photoAssetPath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _AvatarFallback(
                      palette: palette,
                      initials: initials,
                    );
                  },
                )
              : _AvatarFallback(palette: palette, initials: initials),
        ),
      ),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback({required this.palette, required this.initials});

  final _MapThemePalette palette;
  final String initials;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: palette.cardBackground,
      alignment: Alignment.center,
      child: Text(
        initials,
        style: AppTextStyles.body.copyWith(
          color: palette.secondaryText,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _StatusRail extends StatelessWidget {
  const _StatusRail({
    required this.palette,
    required this.filter,
    required this.layerMode,
    required this.onFilterChanged,
    required this.onLayerModeTap,
  });

  final _MapThemePalette palette;
  final MapFilter filter;
  final MapLayerMode layerMode;
  final ValueChanged<MapFilter> onFilterChanged;
  final VoidCallback onLayerModeTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      decoration: BoxDecoration(
        color: palette.cardBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: palette.cardBorder),
        boxShadow: [
          BoxShadow(
            color: palette.shadow,
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _StatusRailChip(
                    palette: palette,
                    icon: Icons.select_all_rounded,
                    label: '전체',
                    selected: filter == MapFilter.all,
                    onTap: () => onFilterChanged(MapFilter.all),
                  ),
                  _StatusRailChip(
                    palette: palette,
                    icon: Icons.inventory_2_outlined,
                    label: '분실',
                    selected: filter == MapFilter.lost,
                    onTap: () => onFilterChanged(MapFilter.lost),
                  ),
                  _StatusRailChip(
                    palette: palette,
                    icon: Icons.support_agent_rounded,
                    label: '연락중',
                    selected: filter == MapFilter.contact,
                    onTap: () => onFilterChanged(MapFilter.contact),
                  ),
                  _StatusRailChip(
                    palette: palette,
                    icon: Icons.verified_outlined,
                    label: '소지중',
                    selected: filter == MapFilter.safe,
                    onTap: () => onFilterChanged(MapFilter.safe),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: onLayerModeTap,
            borderRadius: BorderRadius.circular(18),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: palette.chipBackground,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: palette.cardBorder),
              ),
              child: Icon(
                switch (layerMode) {
                  MapLayerMode.city => Icons.layers_outlined,
                  MapLayerMode.safeZone => Icons.privacy_tip_outlined,
                  MapLayerMode.tracking => Icons.radar_outlined,
                },
                size: 18,
                color: palette.secondaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusRailChip extends StatelessWidget {
  const _StatusRailChip({
    required this.palette,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final _MapThemePalette palette;
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: selected ? palette.chipSelected : palette.chipBackground,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? palette.chipSelected : palette.cardBorder,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 14,
                color: selected
                    ? palette.chipSelectedText
                    : palette.secondaryText,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: selected
                      ? palette.chipSelectedText
                      : palette.secondaryText,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NearbySheet extends StatelessWidget {
  const _NearbySheet({
    required this.palette,
    required this.scrollController,
    required this.items,
    required this.activeChatItemIds,
    required this.currentLocation,
    required this.locationHint,
    required this.isFetchingLocation,
    required this.onRefresh,
    required this.onTapItem,
    required this.onLocateCurrentLocation,
    required this.onOpenSettings,
    required this.anchorLatLng,
  });

  final _MapThemePalette palette;
  final ScrollController scrollController;
  final List<LostItem> items;
  final Set<String> activeChatItemIds;
  final CurrentLocation? currentLocation;
  final String? locationHint;
  final bool isFetchingLocation;
  final VoidCallback onRefresh;
  final ValueChanged<MapMarkerViewData> onTapItem;
  final VoidCallback onLocateCurrentLocation;
  final VoidCallback onOpenSettings;
  final LatLng? anchorLatLng;

  @override
  Widget build(BuildContext context) {
    final itemCount = items.length;
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: palette.cardBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          border: Border(top: BorderSide(color: palette.cardBorder)),
          boxShadow: [
            BoxShadow(
              color: palette.shadow,
              blurRadius: 28,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: CustomScrollView(
          controller: scrollController,
          primary: false,
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 24,
                    child: Center(
                      child: Container(
                        key: const Key('map-sheet-drag-handle'),
                        width: 52,
                        height: 5,
                        decoration: BoxDecoration(
                          color: palette.dragHandle,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 12, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '주변 분실물 $itemCount건',
                            style: AppTextStyles.headline.copyWith(
                              fontSize: 22,
                              color: palette.textPrimary,
                            ),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: onRefresh,
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          label: const Text('새로고침'),
                          style: TextButton.styleFrom(
                            foregroundColor: palette.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '지도에서 선택한 분실 정보와 가까운 카드가 먼저 보이도록 정리했습니다.',
                        style: AppTextStyles.caption.copyWith(
                          color: palette.secondaryText,
                        ),
                      ),
                    ),
                  ),
                  if (currentLocation == null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: _LocationPermissionBanner(
                        palette: palette,
                        hint: locationHint,
                        isFetchingLocation: isFetchingLocation,
                        onLocateCurrentLocation: onLocateCurrentLocation,
                        onOpenSettings: onOpenSettings,
                      ),
                    ),
                ],
              ),
            ),
            if (items.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _NearbyEmptyState(
                  palette: palette,
                  onLocateCurrentLocation: onLocateCurrentLocation,
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                sliver: SliverList.separated(
                  itemCount: items.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _NearbyItemCard(
                      palette: palette,
                      item: item,
                      activeChatItemIds: activeChatItemIds,
                      anchorLatLng: anchorLatLng,
                      onTap: () =>
                          onTapItem(_lostItemMarkerData(item, anchorLatLng)),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NearbyEmptyState extends StatelessWidget {
  const _NearbyEmptyState({
    required this.palette,
    required this.onLocateCurrentLocation,
  });

  final _MapThemePalette palette;
  final VoidCallback onLocateCurrentLocation;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: palette.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                color: palette.primary,
                size: 34,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              '지금 조건에 맞는 분실물이 없어요',
              textAlign: TextAlign.center,
              style: AppTextStyles.subtitle.copyWith(
                color: palette.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '필터를 바꾸거나 현재 위치를 다시 불러오면 주변 카드가 다시 나타납니다.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySecondary.copyWith(
                color: palette.secondaryText,
              ),
            ),
            const SizedBox(height: 16),
            AppPrimaryButton(
              label: '현재 위치 다시 불러오기',
              icon: Icons.my_location_outlined,
              onPressed: onLocateCurrentLocation,
              expanded: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationPermissionBanner extends StatelessWidget {
  const _LocationPermissionBanner({
    required this.palette,
    required this.hint,
    required this.isFetchingLocation,
    required this.onLocateCurrentLocation,
    required this.onOpenSettings,
  });

  final _MapThemePalette palette;
  final String? hint;
  final bool isFetchingLocation;
  final VoidCallback onLocateCurrentLocation;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: palette.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: palette.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: palette.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.gps_fixed_rounded,
              color: palette.primary,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isFetchingLocation ? '현재 위치를 불러오는 중' : '현재 위치 권한이 필요해요',
                  style: AppTextStyles.body.copyWith(
                    color: palette.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (hint != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    hint!,
                    style: AppTextStyles.caption.copyWith(
                      color: palette.secondaryText,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: isFetchingLocation ? null : onLocateCurrentLocation,
            child: const Text('불러오기'),
          ),
        ],
      ),
    );
  }
}

class _NearbyItemCard extends StatelessWidget {
  const _NearbyItemCard({
    required this.palette,
    required this.item,
    required this.activeChatItemIds,
    required this.anchorLatLng,
    required this.onTap,
  });

  final _MapThemePalette palette;
  final LostItem item;
  final Set<String> activeChatItemIds;
  final LatLng? anchorLatLng;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasActiveChat = activeChatItemIds.contains(item.id);
    final displayStatus = resolveMapItemStatus(
      item,
      hasActiveChat: hasActiveChat,
    );
    final actionLabel = hasActiveChat ? '채팅 보기' : '연락하기';
    final actionText = hasActiveChat
        ? '이미 시작된 채팅으로 바로 들어갑니다.'
        : '탭하면 채팅을 만들고 바로 연결합니다.';
    final photoNote = hasActiveChat
        ? switch (item.photoStatus) {
            PhotoAccessStatus.approved => '연락 중. 주인 허가 후 사진을 바로 확인할 수 있습니다.',
            PhotoAccessStatus.pending => '연락 중. 사진 승인 대기 상태입니다.',
            PhotoAccessStatus.locked => '연락 중. 사진은 잠금 상태입니다.',
          }
        : switch (item.photoStatus) {
            PhotoAccessStatus.approved => '승인 완료. 주인 허가 후 사진을 확인할 수 있습니다.',
            PhotoAccessStatus.pending => '승인 대기 중. 주인 확인이 끝나면 사진이 열립니다.',
            PhotoAccessStatus.locked => '사진 잠금 상태. 먼저 주인에게 연락해 주세요.',
          };
    final noteColor = palette.photoNoteForeground(item.photoStatus);
    final noteBackground = palette.photoNoteBackground(item.photoStatus);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: palette.cardBackground,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: palette.cardBorder),
          boxShadow: [
            BoxShadow(
              color: palette.shadow,
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 88,
                  height: 88,
                  child: SecurePhotoThumbnail(
                    photoStatus: item.photoStatus,
                    assetPath: item.photoAssetPath,
                    size: 88,
                  ),
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
                              style: AppTextStyles.subtitle.copyWith(
                                color: palette.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          StatusBadge(status: displayStatus, small: true),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _MetaLine(
                        icon: Icons.place_outlined,
                        text: item.location,
                        textColor: palette.secondaryText,
                      ),
                      const SizedBox(height: 4),
                      _MetaLine(
                        icon: Icons.schedule_outlined,
                        text: '${item.timeLabel} · ${item.distance}',
                        textColor: palette.secondaryText,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.card_giftcard_rounded,
                            size: 15,
                            color: palette.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '사례금 ${Formatters.money(item.reward)}',
                            style: AppTextStyles.caption.copyWith(
                              color: palette.primary,
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
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: noteBackground,
                borderRadius: BorderRadius.circular(14),
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
                    color: noteColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      photoNote,
                      style: AppTextStyles.caption.copyWith(color: noteColor),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              decoration: BoxDecoration(
                color: palette.primary.withValues(
                  alpha: hasActiveChat ? 0.12 : 0.08,
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: palette.primary.withValues(alpha: 0.18),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 16,
                    color: palette.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '$actionLabel · $actionText',
                      style: AppTextStyles.caption.copyWith(
                        color: palette.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: palette.primary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaLine extends StatelessWidget {
  const _MetaLine({
    required this.icon,
    required this.text,
    required this.textColor,
  });

  final IconData icon;
  final String text;
  final Color textColor;

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
            style: AppTextStyles.caption.copyWith(color: textColor),
          ),
        ),
      ],
    );
  }
}

class _MapThemePalette {
  const _MapThemePalette({
    required this.isDarkMode,
    required this.primary,
    required this.cardBackground,
    required this.cardBorder,
    required this.dragHandle,
    required this.chipBackground,
    required this.chipSelected,
    required this.chipSelectedText,
    required this.secondaryText,
    required this.textPrimary,
    required this.mapWash,
    required this.fabBackground,
    required this.fabForeground,
    required this.safeColor,
    required this.lostColor,
    required this.contactColor,
    required this.shadow,
  });

  final bool isDarkMode;
  final Color primary;
  final Color cardBackground;
  final Color cardBorder;
  final Color dragHandle;
  final Color chipBackground;
  final Color chipSelected;
  final Color chipSelectedText;
  final Color secondaryText;
  final Color textPrimary;
  final Color mapWash;
  final Color fabBackground;
  final Color fabForeground;
  final Color safeColor;
  final Color lostColor;
  final Color contactColor;
  final Color shadow;

  factory _MapThemePalette.forMode(bool isDarkTheme) {
    if (isDarkTheme) {
      return _MapThemePalette(
        isDarkMode: true,
        primary: AppColors.primary,
        cardBackground: AppColors.card,
        cardBorder: AppColors.border,
        dragHandle: AppColors.border,
        chipBackground: AppColors.card,
        chipSelected: AppColors.primary,
        chipSelectedText: Colors.white,
        secondaryText: AppColors.textSecondary,
        textPrimary: AppColors.text,
        mapWash: const Color(0xFFF1F5F9),
        fabBackground: Colors.white,
        fabForeground: AppColors.text,
        safeColor: const Color(0xFF22C55E),
        lostColor: AppColors.red,
        contactColor: AppColors.yellow,
        shadow: AppColors.shadow,
      );
    }
    return _MapThemePalette(
      isDarkMode: false,
      primary: AppColors.primary,
      cardBackground: Colors.white,
      cardBorder: AppColors.borderLight,
      dragHandle: AppColors.border,
      chipBackground: Colors.white,
      chipSelected: AppColors.primary,
      chipSelectedText: Colors.white,
      secondaryText: AppColors.textSecondary,
      textPrimary: AppColors.text,
      mapWash: const Color(0xFFF7FAFC),
      fabBackground: Colors.white,
      fabForeground: AppColors.text,
      safeColor: const Color(0xFF22C55E),
      lostColor: AppColors.red,
      contactColor: AppColors.yellow,
      shadow: AppColors.shadow,
    );
  }

  Color statusBackground(ItemStatus status) {
    switch (status) {
      case ItemStatus.safe:
        return safeColor.withValues(alpha: 0.16);
      case ItemStatus.lost:
        return lostColor.withValues(alpha: 0.16);
      case ItemStatus.contact:
        return contactColor.withValues(alpha: 0.18);
    }
  }

  Color photoNoteBackground(PhotoAccessStatus status) {
    switch (status) {
      case PhotoAccessStatus.approved:
        return successSurface;
      case PhotoAccessStatus.pending:
        return warningSurface;
      case PhotoAccessStatus.locked:
        return neutralSurface;
    }
  }

  Color photoNoteForeground(PhotoAccessStatus status) {
    switch (status) {
      case PhotoAccessStatus.approved:
        return successText;
      case PhotoAccessStatus.pending:
        return warningText;
      case PhotoAccessStatus.locked:
        return secondaryText;
    }
  }

  Color get successSurface =>
      isDarkMode ? const Color(0xFF123524) : const Color(0xFFDCFCE7);
  Color get warningSurface =>
      isDarkMode ? const Color(0xFF3A2811) : const Color(0xFFFEF3C7);
  Color get neutralSurface =>
      isDarkMode ? const Color(0xFF172033) : const Color(0xFFF1F5F9);
  Color get successText =>
      isDarkMode ? const Color(0xFF86EFAC) : AppColors.green;
  Color get warningText =>
      isDarkMode ? const Color(0xFFFBBF24) : AppColors.yellow;
}

String _currentLocationOverlayContent() {
  return '''
<div style="
  display: inline-flex;
  flex-direction: column;
  align-items: center;
  gap: 6px;
  transform: translateY(-4px);
">
  <div style="
    width: 18px;
    height: 18px;
    border-radius: 999px;
    background: #2563EB;
    border: 4px solid rgba(37, 99, 235, 0.18);
    box-shadow: 0 0 0 8px rgba(37, 99, 235, 0.12);
  "></div>
  <div style="
    padding: 4px 8px;
    border-radius: 999px;
    background: rgba(15, 23, 42, 0.88);
    color: white;
    font-size: 12px;
    font-weight: 700;
    line-height: 1;
    white-space: nowrap;
  ">내 위치</div>
</div>
''';
}

List<LostItem> _visibleLostItems(
  List<LostItem> items, {
  required Set<String> activeChatItemIds,
  required MapFilter filter,
  required MapSort sort,
}) {
  final filtered = items.where((item) {
    final displayStatus = resolveMapItemStatus(
      item,
      hasActiveChat: activeChatItemIds.contains(item.id),
    );
    return switch (filter) {
      MapFilter.all => true,
      MapFilter.lost => displayStatus == ItemStatus.lost,
      MapFilter.contact => displayStatus == ItemStatus.contact,
      MapFilter.safe => displayStatus == ItemStatus.safe,
    };
  }).toList();

  if (sort == MapSort.distance) {
    filtered.sort(
      (a, b) =>
          _distanceValue(a.distance).compareTo(_distanceValue(b.distance)),
    );
  }

  return filtered;
}

double _distanceValue(String text) {
  final parsed = double.tryParse(text.replaceAll(RegExp(r'[^0-9.]'), ''));
  if (parsed == null) {
    return 0;
  }
  return text.contains('km') ? parsed * 1000 : parsed;
}

MapMarkerViewData _lostItemMarkerData(LostItem item, LatLng? anchorLatLng) {
  return MapMarkerViewData(
    id: item.id,
    name: item.title,
    subtitle: item.location,
    status: item.status,
    latLng: _convertToLatLng(item.mapX, item.mapY, anchorLatLng),
    isMine: false,
    distanceValue: _distanceValue(item.distance),
  );
}

LatLng _convertToLatLng(double x, double y, LatLng? anchorLatLng) {
  final baseLat = anchorLatLng?.latitude ?? 37.5665;
  final baseLng = anchorLatLng?.longitude ?? 126.9780;
  final lat = baseLat - ((y - 0.5) * 0.05);
  final lng = baseLng + ((x - 0.5) * 0.05);
  return LatLng(lat, lng);
}
