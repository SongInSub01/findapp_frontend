import 'package:flutter/material.dart';

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
                  backgroundImage: AssetImage(state.userProfile.photoAssetPath),
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
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: switch (layerMode) {
                        MapLayerMode.city => const Color(0xFFDDEAF7),
                        MapLayerMode.safeZone => const Color(0xFFE6F6EC),
                        MapLayerMode.tracking => const Color(0xFFE9F5FF),
                      },
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: CustomPaint(painter: _MapPainter(layerMode: layerMode)),
                  ),
                ),
                for (final marker in filteredMarkers)
                  Positioned.fill(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Stack(
                          children: [
                            Positioned(
                              left: marker.x * constraints.maxWidth - 28,
                              top: marker.y * constraints.maxHeight - 56,
                              child: _MapMarker(
                                marker: marker,
                                selected: selectedTargetId == marker.id,
                                onTap: () => handler.selectMarker(marker.id),
                              ),
                            ),
                          ],
                        );
                      },
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

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

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
  const _SortChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

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

class _MapMarker extends StatelessWidget {
  const _MapMarker({
    required this.marker,
    required this.selected,
    required this.onTap,
  });

  final MapMarkerViewData marker;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.status(marker.status);
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: selected ? 44 : 40,
            height: selected ? 44 : 40,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 2.5),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Icon(Icons.location_on_rounded, color: color, size: 22),
          ),
          if (marker.isMine)
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.text,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '나',
                style: AppTextStyles.caption.copyWith(color: Colors.white),
              ),
            )
          else
            const SizedBox(height: 4),
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              marker.name,
              style: AppTextStyles.caption.copyWith(
                color: selected ? color : AppColors.text,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
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
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
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
  const _LegendItem({
    required this.color,
    required this.label,
  });

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
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 42,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(999),
            ),
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
              IconButton(
                onPressed: onClose,
                icon: const Icon(Icons.close_rounded),
              ),
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

class _MapPainter extends CustomPainter {
  const _MapPainter({
    required this.layerMode,
  });

  final MapLayerMode layerMode;

  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()..color = const Color(0xFFBED1E9);
    final gridPaint = Paint()
      ..color = const Color(0xFFCAE0F5)
      ..strokeWidth = 1;
    final parkPaint = Paint()
      ..color = layerMode == MapLayerMode.safeZone
          ? const Color(0xFFB9E7C0)
          : const Color(0xFFD0F1D1);
    final userPaint = Paint()
      ..color = layerMode == MapLayerMode.tracking
          ? AppColors.primary
          : const Color(0xFF4F8EF7);
    final safeZoneRingPaint = Paint()
      ..color = const Color(0x4422C55E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14;

    for (double x = 0; x < size.width; x += size.width / 6) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += size.height / 6) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    canvas.drawRect(Rect.fromLTWH(size.width * 0.18, 0, 14, size.height), roadPaint);
    canvas.drawRect(Rect.fromLTWH(size.width * 0.48, 0, 14, size.height), roadPaint);
    canvas.drawRect(Rect.fromLTWH(0, size.height * 0.29, size.width, 14), roadPaint);
    canvas.drawRect(Rect.fromLTWH(0, size.height * 0.52, size.width, 14), roadPaint);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(16, 24, size.width * 0.18, size.height * 0.28),
        const Radius.circular(18),
      ),
      parkPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.68, size.height * 0.64, size.width * 0.18, size.height * 0.22),
        const Radius.circular(18),
      ),
      parkPaint,
    );

    if (layerMode == MapLayerMode.safeZone) {
      canvas.drawCircle(Offset(size.width * 0.17, size.height * 0.74), 48, safeZoneRingPaint);
      canvas.drawCircle(Offset(size.width * 0.63, size.height * 0.68), 58, safeZoneRingPaint);
    }

    canvas.drawCircle(Offset(size.width * 0.46, size.height * 0.43), 8, userPaint);
    canvas.drawCircle(Offset(size.width * 0.52, size.height * 0.25), 6, userPaint);

    if (layerMode == MapLayerMode.tracking) {
      final signalPaint = Paint()
        ..color = const Color(0x332563EB)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(Offset(size.width * 0.46, size.height * 0.43), 26, signalPaint);
      canvas.drawCircle(Offset(size.width * 0.46, size.height * 0.43), 44, signalPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _MapPainter oldDelegate) {
    return oldDelegate.layerMode != layerMode;
  }
}
