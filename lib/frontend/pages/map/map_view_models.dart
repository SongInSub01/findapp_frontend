import 'package:my_flutter_starter/data/models/app_models.dart';

enum MapFilter { all, lost, contact, safe }

enum MapSort { recent, distance }

enum MapLayerMode { city, safeZone, tracking }

class MapMarkerViewData {
  const MapMarkerViewData({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.status,
    required this.x,
    required this.y,
    required this.isMine,
    required this.distanceValue,
  });

  final String id;
  final String name;
  final String subtitle;
  final ItemStatus status;
  final double x;
  final double y;
  final bool isMine;
  final double distanceValue;
}

abstract final class MapMarkerBuilder {
  static List<MapMarkerViewData> fromState(AppState state) {
    return <MapMarkerViewData>[
      ...state.myDevices.map(
        (device) => MapMarkerViewData(
          id: device.id,
          name: device.name,
          subtitle: device.location,
          status: device.status,
          x: device.mapX,
          y: device.mapY,
          isMine: true,
          distanceValue: _distanceToNumber(device.distance),
        ),
      ),
      ...state.lostItems.map(
        (item) => MapMarkerViewData(
          id: item.id,
          name: item.title,
          subtitle: item.location,
          status: item.status,
          x: item.mapX,
          y: item.mapY,
          isMine: false,
          distanceValue: _distanceToNumber(item.distance),
        ),
      ),
    ];
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
