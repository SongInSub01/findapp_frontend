import 'package:geolocator/geolocator.dart';

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

Future<bool> isLocationServiceEnabled() {
  return Geolocator.isLocationServiceEnabled();
}

Future<MapLocationPermission> checkLocationPermission() async {
  final permission = await Geolocator.checkPermission();
  return switch (permission) {
    LocationPermission.denied => MapLocationPermission.denied,
    LocationPermission.deniedForever => MapLocationPermission.deniedForever,
    _ => MapLocationPermission.granted,
  };
}

Future<MapLocationPermission> requestLocationPermission() async {
  final permission = await Geolocator.requestPermission();
  return switch (permission) {
    LocationPermission.denied => MapLocationPermission.denied,
    LocationPermission.deniedForever => MapLocationPermission.deniedForever,
    _ => MapLocationPermission.granted,
  };
}

Future<MapLocationPosition> getCurrentLocation() async {
  final position = await Geolocator.getCurrentPosition(
    locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
  );
  return MapLocationPosition(
    latitude: position.latitude,
    longitude: position.longitude,
    accuracy: position.accuracy,
  );
}
