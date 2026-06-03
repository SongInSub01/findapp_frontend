import 'package:flutter/material.dart';

import 'package:my_flutter_starter/app/state/app_controller.dart';
import 'package:my_flutter_starter/data/models/app_models.dart';
import 'package:my_flutter_starter/frontend/app_routes.dart';
import 'package:my_flutter_starter/frontend/pages/lost_item/lost_item_detail_page.dart';

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

  final CurrentLocation?
      currentLocation;

  final MapLayerMode layerMode;

  final ValueChanged<
          MapLayerMode>
      onLayerModeChanged;

  final ValueChanged<
          KakaoMapController>
      onMapControllerChanged;

  KakaoMapController?
      mapController;

  /// =========================
  /// 지도 컨트롤러 연결
  /// =========================

  void attachMapController(
    KakaoMapController
        controller,
  ) {

    debugPrint(
      '지도 컨트롤러 연결됨',
    );

    mapController =
        controller;

    onMapControllerChanged(
      controller,
    );

    /// =========================
    /// 지도 초기화 후
    /// 현재 위치 이동
    /// =========================

    Future.delayed(
      const Duration(
        seconds: 2,
      ),

      () {

        focusCurrentLocation();
      },
    );
  }

  void openMenu() {

    Navigator.of(
      context,
    ).pushNamed(
      AppRoutes.sideMenu,
    );
  }

  void cycleLayerMode() {

    final modes =
        MapLayerMode.values;

    final nextIndex =
        (modes.indexOf(
                      layerMode,
                    ) +
                    1) %
            modes.length;

    onLayerModeChanged(
      modes[nextIndex],
    );

    final label =
        switch (
            modes[nextIndex]) {

      MapLayerMode.city =>
        '기본 지도 레이어',

      MapLayerMode.safeZone =>
        '안전지대 레이어',

      MapLayerMode.tracking =>
        'BLE 추적 레이어',
    };

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(

      SnackBar(
        content: Text(
          '$label로 전환했습니다.',
        ),
      ),
    );
  }

/// =========================
/// 현재 위치로 이동
/// =========================

void focusCurrentLocation() {

  /// 전주대학교 기본 위치
  const LatLng defaultLocation =
      LatLng(
        35.8152,
        127.0890,
      );

  debugPrint(
    '전주대학교 기본 위치 이동',
  );

  mapController?.setCenter(
    defaultLocation,
  );
}

  Future<void> handleMarkerAction(MapMarkerViewData marker) async {
    if (marker.isMine) {
      controller.switchTab(AppTab.main);
      return;
    }

    // 분실물 마커 → 상세 페이지로 이동
    final lostItem = state.lostItems
        .where((item) => item.id == marker.id)
        .firstOrNull;

    if (lostItem == null) return;

    if (!context.mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LostItemDetailPage(item: lostItem),
      ),
    );
  }
}