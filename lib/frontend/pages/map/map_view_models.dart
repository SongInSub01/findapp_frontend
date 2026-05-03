import 'package:my_flutter_starter/data/models/app_models.dart';

import 'map_kakao_bridge.dart';

enum MapFilter { all, lost, contact, safe }

enum MapSort { recent, distance }

enum MapLayerMode { city, safeZone, tracking }

class MapMarkerViewData {
  const MapMarkerViewData({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.status,
    required this.latLng,
    required this.isMine,
    required this.distanceValue,
    this.customOverlayContent,
    this.zIndex = 0,
  });

  final String id;
  final String name;
  final String subtitle;
  final ItemStatus status;
  final LatLng latLng; // 카카오맵 좌표 객체
  final bool isMine;
  final double distanceValue;
  final String? customOverlayContent;
  final int zIndex;
}

abstract final class MapMarkerBuilder {
  static List<MapMarkerViewData> fromState(
    AppState state, {
    LatLng? anchorLatLng,
  }) {
    final activeChatItemIds =
        state.chatThreads.map((thread) => thread.itemId).toSet();
    return <MapMarkerViewData>[
      ...state.myDevices.map(
        (device) => MapMarkerViewData(
          id: device.id,
          name: device.name,
          subtitle: device.location,
          status: device.status,
          latLng: _convertToLatLng(device.mapX, device.mapY, anchorLatLng),
          isMine: true,
          distanceValue: _distanceToNumber(device.distance),
        ),
      ),
      ...state.lostItems.map(
        (item) => MapMarkerViewData(
          id: item.id,
          name: item.title,
          subtitle: item.location,
          status: resolveMapItemStatus(
            item,
            hasActiveChat: activeChatItemIds.contains(item.id),
          ),
          latLng: _convertToLatLng(item.mapX, item.mapY, anchorLatLng),
          isMine: false,
          distanceValue: _distanceToNumber(item.distance),
        ),
      ),
    ];
  }

  static LatLng _convertToLatLng(double x, double y, LatLng? anchorLatLng) {
    final baseLat = anchorLatLng?.latitude ?? 37.5665;
    final baseLng = anchorLatLng?.longitude ?? 126.9780;
    final lat = baseLat - ((y - 0.5) * 0.05);
    final lng = baseLng + ((x - 0.5) * 0.05);
    return LatLng(lat, lng);
  }

  static double _distanceToNumber(String? text) {
    if (text == null) {
      return 0;
    }
    final value = double.tryParse(text.replaceAll(RegExp(r'[^0-9.]'), ''));
    if (value == null) {
      return 0;
    }
    return text.contains('km') ? value * 1000 : value;
  }
}

ItemStatus resolveMapItemStatus(
  LostItem item, {
  required bool hasActiveChat,
}) {
  if (hasActiveChat) {
    return ItemStatus.contact;
  }
  if (item.status == ItemStatus.contact) {
    return ItemStatus.lost;
  }
  return item.status;
}
