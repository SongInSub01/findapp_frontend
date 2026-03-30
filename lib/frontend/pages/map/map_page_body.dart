import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart'; // 카카오 맵 임포트

import 'package:my_flutter_starter/data/models/app_models.dart';
import 'package:my_flutter_starter/frontend/common/theme/app_colors.dart';
import 'package:my_flutter_starter/frontend/common/theme/app_text_styles.dart';
import 'package:my_flutter_starter/frontend/common/widgets/app_buttons.dart';
import 'package:my_flutter_starter/frontend/common/widgets/status_badge.dart';

import 'map_page_handler.dart';
import 'map_view_models.dart';

class MapPageBody extends StatelessWidget {
  const MapPageBody({
    required this.state,
    required this.filter,
    required this.sort,
    required this.layerMode,
    required this.selectedTargetId,
    required this.onFilterChanged,
    required this.onSortChanged,
    required this.handler,
    super.key,
  });

  final AppState state;
  final MapFilter filter;
  final MapSort sort;
  final MapLayerMode layerMode;
  final String? selectedTargetId;
  final ValueChanged<MapFilter> onFilterChanged;
  final ValueChanged<MapSort> onSortChanged;
  final MapPageHandler handler;

  @override
  Widget build(BuildContext context) {
    final markers = MapMarkerBuilder.fromState(state);
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

    if (sort == MapSort.distance) {
      filteredMarkers.sort((a, b) => a.distanceValue.compareTo(b.distanceValue));
    }

    final selectedCandidates = markers.where((marker) => marker.id == selectedTargetId);
    final selectedMarker = selectedCandidates.isEmpty ? null : selectedCandidates.first;

    return SafeArea(
      child: Column(
        children: [
          // 상단 헤더
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              children: [
                IconButton(
                  onPressed: handler.openMenu,
                  icon: const Icon(Icons.menu_rounded),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE8FFFB),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.track_changes_rounded, color: AppColors.teal, size: 18),
                      ),
                      const SizedBox(width: 8),
                      Text('찾아줘', style: AppTextStyles.title.copyWith(color: AppColors.teal)),
                    ],
                  ),
                ),
                CircleAvatar(
                  backgroundColor: AppColors.teal,
                  backgroundImage: state.userProfile.photoAssetPath.isNotEmpty
                      ? AssetImage(state.userProfile.photoAssetPath)
                      : null,
                  child: state.userProfile.photoAssetPath.isEmpty
                      ? Text(
                          state.userProfile.initials,
                          style: AppTextStyles.body.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        )
                      : null,
                ),
              ],
            ),
          ),
          // 필터 및 레이어 모드
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _FilterChip(
                          label: '전체',
                          selected: filter == MapFilter.all,
                          onTap: () => onFilterChanged(MapFilter.all),
                        ),
                        _FilterChip(
                          label: '분실',
                          selected: filter == MapFilter.lost,
                          onTap: () => onFilterChanged(MapFilter.lost),
                        ),
                        _FilterChip(
                          label: '연락중',
                          selected: filter == MapFilter.contact,
                          onTap: () => onFilterChanged(MapFilter.contact),
                        ),
                        _FilterChip(
                          label: '소지중',
                          selected: filter == MapFilter.safe,
                          onTap: () => onFilterChanged(MapFilter.safe),
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton.filledTonal(
                  onPressed: handler.cycleLayerMode,
                  style: IconButton.styleFrom(backgroundColor: Colors.white),
                  icon: Icon(
                    switch (layerMode) {
                      MapLayerMode.city => Icons.layers_outlined,
                      MapLayerMode.safeZone => Icons.privacy_tip_outlined,
                      MapLayerMode.tracking => Icons.radar_outlined,
                    },
                  ),
                ),
              ],
            ),
          ),
          // 정렬
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                _SortChip(
                  label: '최근순',
                  selected: sort == MapSort.recent,
                  onTap: () => onSortChanged(MapSort.recent),
                ),
                _SortChip(
                  label: '거리순',
                  selected: sort == MapSort.distance,
                  onTap: () => onSortChanged(MapSort.distance),
                ),
                const Spacer(),
                Text(
                  switch (layerMode) {
                    MapLayerMode.city => '도시 레이어',
                    MapLayerMode.safeZone => '안전지대 레이어',
                    MapLayerMode.tracking => '추적 레이어',
                  },
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          
          // 🔥 실제 카카오 지도 영역 🔥
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: KakaoMap(
                      onMapCreated: (controller) {
                        handler.mapController = controller;
                      },
                      markers: filteredMarkers.map((m) => Marker(
                        markerId: m.id,
                        latLng: m.latLng, // 뷰 모델에 추가된 latLng 사용!
                        width: 40,
                        height: 40,
                      )).toList(),
                      onMarkerTap: (markerId, latLng, zoomLevel) {
                        handler.selectMarker(markerId);
                      },
                    ),
                  ),
                ),
                Positioned(
                  left: 24,
                  bottom: 24,
                  child: _LegendCard(),
                ),
                Positioned(
                  right: 24,
                  bottom: 24,
                  child: FloatingActionButton.small(
                    heroTag: 'locate_map',
                    backgroundColor: Colors.white,
                    onPressed: handler.focusPriorityTarget,
                    child: const Icon(Icons.navigation_outlined, color: AppColors.primary),
                  ),
                ),
                if (selectedMarker != null)
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 88,
                    child: _MapDetailCard(
                      marker: selectedMarker,
                      onClose: handler.closeDetail,
                      onPrimaryTap: () => handler.handleMarkerAction(selectedMarker),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------
// 아래는 UI 구성에 필요한 칩(Chip)과 상세 카드(Card) 컴포넌트들입니다.
// 가짜 지도 그리는 코드는 모두 삭제되었습니다!
// ---------------------------------------------------------

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.teal,
        backgroundColor: Colors.white,
        labelStyle: AppTextStyles.caption.copyWith(
          color: selected ? Colors.white : AppColors.textSecondary,
          fontWeight: FontWeight.w700,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  const _SortChip({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.primary,
        backgroundColor: Colors.white,
        labelStyle: AppTextStyles.caption.copyWith(
          color: selected ? Colors.white : AppColors.textSecondary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _LegendCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: AppColors.shadow, blurRadius: 14, offset: Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _LegendItem(color: AppColors.green, label: '소지중'),
          SizedBox(height: 6),
          _LegendItem(color: AppColors.red, label: '분실'),
          SizedBox(height: 6),
          _LegendItem(color: AppColors.yellow, label: '연락중'),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}

class _MapDetailCard extends StatelessWidget {
  const _MapDetailCard({
    required this.marker,
    required this.onClose,
    required this.onPrimaryTap,
  });

  final MapMarkerViewData marker;
  final VoidCallback onClose;
  final VoidCallback onPrimaryTap;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.status(marker.status);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(color: AppColors.shadow, blurRadius: 18, offset: Offset(0, 8)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 42,
            height: 4,
            decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(999)),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.statusBackground(marker.status),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.location_pin, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(marker.name, style: AppTextStyles.subtitle),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        StatusBadge(status: marker.status, small: true),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            marker.isMine ? '내 물건' : '주변 분실물',
                            style: AppTextStyles.caption,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(onPressed: onClose, icon: const Icon(Icons.close_rounded)),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(marker.subtitle, style: AppTextStyles.bodySecondary),
          ),
          const SizedBox(height: 12),
          AppPrimaryButton(
            label: marker.isMine ? '내 물건 상태 보기' : '주인에게 메시지 보내기',
            icon: marker.isMine ? Icons.inventory_2_outlined : Icons.chat_bubble_outline_rounded,
            onPressed: onPrimaryTap,
            expanded: true,
          ),
        ],
      ),
    );
  }
}