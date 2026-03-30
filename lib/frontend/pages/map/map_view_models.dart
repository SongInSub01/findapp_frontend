import 'package:my_flutter_starter/data/models/app_models.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart'; // 카카오맵 플러그인 임포트

enum MapFilter { all, lost, contact, safe }

enum MapSort { recent, distance }

enum MapLayerMode { city, safeZone, tracking }

class MapMarkerViewData {
  const MapMarkerViewData({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.status,
    required this.latLng, // 🔥 기존 x, y를 지우고 카카오맵용 latLng로 통합!
    required this.isMine,
    required this.distanceValue,
  });

  final String id;
  final String name;
  final String subtitle;
  final ItemStatus status;
  final LatLng latLng; // 카카오맵 좌표 객체
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
          // 🔥 기존 mapX, mapY를 서울 시청 근처 위경도로 변환
          latLng: _convertToLatLng(device.mapX, device.mapY),
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
          // 🔥 여기서도 변환 함수 적용
          latLng: _convertToLatLng(item.mapX, item.mapY),
          isMine: false,
          distanceValue: _distanceToNumber(item.distance),
        ),
      ),
    ];
  }

  // 💡 마법의 함수: 기존 비율(0~1) 좌표를 서울 시청(37.5665, 126.9780) 주변의 실제 위도/경도로 흩뿌려줍니다.
  // (나중에 백엔드에서 진짜 위도/경도 데이터를 주면, 이 함수를 지우고 진짜 데이터를 바로 넣으시면 됩니다.)
  static LatLng _convertToLatLng(double x, double y) {
    // y값이 작을수록 위쪽이므로 위도(lat)는 빼주고, x값은 경도(lng)에 더해줍니다.
    final lat = 37.5665 - ((y - 0.5) * 0.05);
    final lng = 126.9780 + ((x - 0.5) * 0.05);
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