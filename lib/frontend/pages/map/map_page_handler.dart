import 'package:flutter/material.dart';

import 'package:my_flutter_starter/app/state/app_controller.dart';
import 'package:my_flutter_starter/data/models/app_models.dart';
import 'package:my_flutter_starter/frontend/app_routes.dart';

import 'map_kakao_bridge.dart';
import 'map_view_models.dart';

class MapPageHandler {
  MapPageHandler({
    required this.context,
    required this.controller,
    required this.state,
    required this.currentLocation,
    required this.layerMode,
    required this.onLayerModeChanged,
    required this.onMapControllerChanged,
  });

  final BuildContext context;
  final AppController controller;
  final AppState state;
  final CurrentLocation? currentLocation;
  final MapLayerMode layerMode;
  final ValueChanged<MapLayerMode> onLayerModeChanged;
  final ValueChanged<KakaoMapController> onMapControllerChanged;

  KakaoMapController? mapController;

  void attachMapController(KakaoMapController controller) {
    mapController = controller;
    onMapControllerChanged(controller);
    focusCurrentLocation();
  }

  void openMenu() {
    Navigator.of(context).pushNamed(AppRoutes.sideMenu);
  }

  void cycleLayerMode() {
    final modes = MapLayerMode.values;
    final nextIndex = (modes.indexOf(layerMode) + 1) % modes.length;
    onLayerModeChanged(modes[nextIndex]);
    final label = switch (modes[nextIndex]) {
      MapLayerMode.city => '기본 지도 레이어',
      MapLayerMode.safeZone => '안전지대 레이어',
      MapLayerMode.tracking => 'BLE 추적 레이어',
    };
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$label로 전환했습니다.')));
  }

  void focusCurrentLocation() {
    final location = currentLocation;
    if (location == null) {
      return;
    }
    mapController?.setCenter(LatLng(location.latitude, location.longitude));
  }

  Future<void> handleMarkerAction(MapMarkerViewData marker) async {
    if (marker.isMine) {
      controller.switchTab(AppTab.main);
      return;
    }
    try {
      final threadId = await controller.openOrCreateChatForItem(marker.id);
      if (!context.mounted) {
        return;
      }
      Navigator.of(
        context,
      ).pushNamed(AppRoutes.chatDetail, arguments: threadId);
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    }
  }
}
