import 'dart:math' as math;

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

class MapRadiusViewData {
  const MapRadiusViewData({
    required this.id,
    required this.center,
    required this.radiusMeters,
  });

  final String id;
  final LatLng center;
  final double radiusMeters;
}

abstract final class MapMarkerBuilder {
  static List<MapMarkerViewData> fromState(
    AppState state, {
    LatLng? anchorLatLng,
  }) {
    final activeChatItemIds = state.chatThreads
        .map((thread) => thread.itemId)
        .toSet();
    return <MapMarkerViewData>[
      ...state.myDevices.map(
        (device) => MapMarkerViewData(
          id: device.id,
          name: device.name,
          subtitle: device.location,
          status: device.status,
          latLng: _resolveLatLng(
            latitude: device.lastDetectedLatitude,
            longitude: device.lastDetectedLongitude,
            mapX: device.mapX,
            mapY: device.mapY,
            anchorLatLng: anchorLatLng,
          ),
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
          latLng: _resolveLatLng(
            latitude: item.latitude,
            longitude: item.longitude,
            mapX: item.mapX,
            mapY: item.mapY,
            anchorLatLng: anchorLatLng,
          ),
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

  static LatLng _resolveLatLng({
    required double? latitude,
    required double? longitude,
    required double mapX,
    required double mapY,
    required LatLng? anchorLatLng,
  }) {
    if (latitude != null && longitude != null) {
      return LatLng(latitude, longitude);
    }
    return _convertToLatLng(mapX, mapY, anchorLatLng);
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

abstract final class MapRadiusBuilder {
  static List<MapRadiusViewData> fromState(AppState state) {
    return state.myDevices
        .where(
          (device) =>
              device.lastDetectedLatitude != null &&
              device.lastDetectedLongitude != null,
        )
        .map(
          (device) => MapRadiusViewData(
            id: 'ble-radius-${device.id}',
            center: LatLng(
              device.lastDetectedLatitude!,
              device.lastDetectedLongitude!,
            ),
            radiusMeters: _estimatedRadiusMeters(device),
          ),
        )
        .toList();
  }

  static double _estimatedRadiusMeters(BleDevice device) {
    final rssi = device.lastRssi;
    final gpsAccuracy = device.lastDetectedAccuracyMeters ?? 0;
    if (rssi == null) {
      return math.max(gpsAccuracy, 15).clamp(3, 100).toDouble();
    }

    const measuredPower = -59;
    const pathLossExponent = 2.5;
    final signalDistance = math
        .pow(10, (measuredPower - rssi) / (10 * pathLossExponent))
        .toDouble();
    return math.max(signalDistance, gpsAccuracy).clamp(3, 100).toDouble();
  }
}

ItemStatus resolveMapItemStatus(LostItem item, {required bool hasActiveChat}) {
  if (hasActiveChat) {
    return ItemStatus.contact;
  }
  if (item.status == ItemStatus.contact) {
    return ItemStatus.lost;
  }
  return item.status;
}
