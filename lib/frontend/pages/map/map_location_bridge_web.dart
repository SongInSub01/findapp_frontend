enum MapLocationPermission {
  denied,
  deniedForever,
  granted,
}

class MapLocationPosition {
  const MapLocationPosition({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
  });

  final double latitude;
  final double longitude;
  final double accuracy;
}

Future<bool> isLocationServiceEnabled() async => false;

Future<MapLocationPermission> checkLocationPermission() async {
  return MapLocationPermission.denied;
}

Future<MapLocationPermission> requestLocationPermission() async {
  return MapLocationPermission.denied;
}

Future<MapLocationPosition> getCurrentLocation() async {
  throw UnsupportedError('Location is not supported on web in this app.');
}
