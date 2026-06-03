import 'package:my_flutter_starter/data/models/app_models.dart';

import 'map_kakao_bridge.dart';

enum MapFilter { all, lost, contact, safe }

enum MapSort { recent, distance }

enum MapLayerMode { city, safeZone, tracking }

enum MapMarkerType { myDevice, lostItem }

class MapMarkerViewData {
  const MapMarkerViewData({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.status,
    required this.latLng,
    required this.markerType,
    required this.distanceMeters,
    this.customOverlayContent,
    this.zIndex = 0,
  });

  final String id;
  final String name;
  final String subtitle;
  final ItemStatus status;
  final LatLng latLng;
  final MapMarkerType markerType;
  final double distanceMeters;
  final String? customOverlayContent;
  final int zIndex;

  bool get isMine => markerType == MapMarkerType.myDevice;
}

abstract final class MapMarkerBuilder {
  static const double _defaultLat = 37.5665;
  static const double _defaultLng = 126.9780;
  static const double _latScale = 0.05;
  static const double _lngScale = 0.05;
  static const int _myDeviceZIndex = 10;
  static const int _lostItemZIndex = 5;

  static List<MapMarkerViewData> fromState(
    AppState state, {
    LatLng? anchorLatLng,
  }) {
    final activeChatItemIds =
        state.chatThreads.map((thread) => thread.itemId).toSet();

    return <MapMarkerViewData>[
      ...state.myDevices
          .where((device) => device.status != ItemStatus.safe)
          .map(
        (device) => MapMarkerViewData(
          id: device.id,
          name: device.name,
          subtitle: device.location,
          status: device.status,
          latLng: toLatLng(device.mapX, device.mapY, anchorLatLng),
          markerType: MapMarkerType.myDevice,
          distanceMeters: parseDistanceMeters(device.distance),
          zIndex: _myDeviceZIndex,
        ),
      ),
      ...state.lostItems
          .where((item) => !item.isResolved && item.status != ItemStatus.safe)
          .map((item) {
        final resolvedStatus = _resolveItemStatus(
          item,
          hasActiveChat: activeChatItemIds.contains(item.id),
        );
        return MapMarkerViewData(
          id: item.id,
          name: item.title,
          subtitle: item.location,
          status: resolvedStatus,
          latLng: (item.latitude != null && item.longitude != null)
              ? LatLng(item.latitude!, item.longitude!)
              : toLatLng(item.mapX, item.mapY, anchorLatLng),
          markerType: MapMarkerType.lostItem,
          distanceMeters: parseDistanceMeters(item.distance),
          customOverlayContent: lostItemOverlayHtml(
            title: item.title,
            status: resolvedStatus,
            isMine: item.isMine,
          ),
          zIndex: _lostItemZIndex,
        );
      }),
    ];
  }

  static LatLng toLatLng(double x, double y, LatLng? anchor) {
    final baseLat = anchor?.latitude ?? _defaultLat;
    final baseLng = anchor?.longitude ?? _defaultLng;
    return LatLng(
      baseLat - ((y - 0.5) * _latScale),
      baseLng + ((x - 0.5) * _lngScale),
    );
  }

  static double parseDistanceMeters(String? text) {
    if (text == null || text.isEmpty) return 0;
    final value = double.tryParse(
      text.replaceAll(RegExp(r'[^0-9.]'), ''),
    );
    if (value == null) return 0;
    return text.toLowerCase().contains('km') ? value * 1000 : value;
  }

  static ItemStatus _resolveItemStatus(
    LostItem item, {
    required bool hasActiveChat,
  }) {
    if (hasActiveChat) return ItemStatus.contact;
    if (item.status == ItemStatus.contact) return ItemStatus.lost;
    return item.status;
  }
}

/// 분실물 마커 커스텀 오버레이 HTML
/// - 분실 중: 빨간 핀
/// - 연락 중: 노란 핀
/// - 내 물건: 파란 핀
String lostItemOverlayHtml({
  required String title,
  required ItemStatus status,
  required bool isMine,
}) {
  final String bgColor;
  final String borderColor;
  final String label;

  if (isMine) {
    bgColor = '#2563EB';
    borderColor = 'rgba(37,99,235,0.3)';
    label = '내 물건';
  } else if (status == ItemStatus.contact) {
    bgColor = '#D97706';
    borderColor = 'rgba(217,119,6,0.3)';
    label = '연락 중';
  } else {
    bgColor = '#DC2626';
    borderColor = 'rgba(220,38,38,0.3)';
    label = '분실';
  }

  // 제목 줄이기
  final shortTitle = title.length > 8 ? '${title.substring(0, 8)}...' : title;

  return '''
<div style="
  display: inline-flex;
  flex-direction: column;
  align-items: center;
  gap: 5px;
  transform: translateY(-8px);
  cursor: pointer;
">
  <div style="
    background: white;
    border: 1.5px solid $borderColor;
    border-radius: 8px;
    padding: 4px 8px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.15);
    display: flex;
    align-items: center;
    gap: 5px;
    white-space: nowrap;
  ">
    <span style="
      background: $bgColor;
      color: white;
      font-size: 9px;
      font-weight: 700;
      padding: 2px 5px;
      border-radius: 4px;
      line-height: 1.3;
    ">$label</span>
    <span style="
      font-size: 11px;
      font-weight: 600;
      color: #111827;
      line-height: 1.3;
    ">$shortTitle</span>
  </div>
  <div style="
    width: 12px;
    height: 12px;
    background: $bgColor;
    border-radius: 999px;
    border: 3px solid white;
    box-shadow: 0 0 0 2px $bgColor, 0 2px 6px rgba(0,0,0,0.25);
  "></div>
</div>
''';
}