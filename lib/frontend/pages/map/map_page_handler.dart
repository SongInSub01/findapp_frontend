import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart'; // ⭐ 1. 카카오맵 임포트 추가

import 'package:my_flutter_starter/app/state/app_controller.dart';
import 'package:my_flutter_starter/data/models/app_models.dart';
import 'package:my_flutter_starter/frontend/app_routes.dart';

import 'map_view_models.dart';

class MapPageHandler {
  MapPageHandler({
    required this.context,
    required this.controller,
    required this.state,
    required this.selectedTargetId,
    required this.layerMode,
    required this.onLayerModeChanged,
    required this.onSelectedTargetChanged,
  });

  final BuildContext context;
  final AppController controller;
  final AppState state;
  final String? selectedTargetId;
  final MapLayerMode layerMode;
  final ValueChanged<MapLayerMode> onLayerModeChanged;
  final ValueChanged<String?> onSelectedTargetChanged;

  // ⭐ 2. 카카오 지도를 조작할 수 있는 컨트롤러 변수 추가!
  KakaoMapController? mapController;

  void openMenu() {
    Navigator.of(context).pushNamed(AppRoutes.sideMenu);
  }

  void selectMarker(String? targetId) {
    onSelectedTargetChanged(
      selectedTargetId == targetId ? null : targetId,
    );
  }

  void closeDetail() {
    onSelectedTargetChanged(null);
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label로 전환했습니다.')),
    );
  }

  void focusPriorityTarget() {
    final lostMine = state.myDevices.where((device) => device.status == ItemStatus.lost);
    if (lostMine.isNotEmpty) {
      onSelectedTargetChanged(lostMine.first.id);
      return;
    }
    if (state.lostItems.isNotEmpty) {
      onSelectedTargetChanged(state.lostItems.first.id);
      return;
    }
    if (state.myDevices.isNotEmpty) {
      onSelectedTargetChanged(state.myDevices.first.id);
    }
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
      Navigator.of(context).pushNamed(AppRoutes.chatDetail, arguments: threadId);
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }
}