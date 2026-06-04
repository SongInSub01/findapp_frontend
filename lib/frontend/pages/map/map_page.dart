import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:my_flutter_starter/data/models/app_models.dart';
import 'package:my_flutter_starter/frontend/frontend_scope.dart';

import 'map_location_bridge.dart';
import 'map_kakao_bridge.dart';
import 'map_page_body.dart';
import 'map_page_handler.dart';
import 'map_view_models.dart';
import 'package:my_flutter_starter/core/ble/ble_proximity_scanner.dart';

class MapPage extends StatefulWidget {

  const MapPage({
    required this.isVisible,
    super.key,
  });

  final bool isVisible;

  @override
  State<MapPage> createState() =>
      _MapPageState();
}

class _MapPageState
    extends State<MapPage> {
  DetectedLostItem? _detectedItem;

  MapFilter _filter =
      MapFilter.all;

  final MapSort _sort =
      MapSort.recent;

  MapLayerMode _layerMode =
      MapLayerMode.city;

  double _sheetExtent = 0.28;

  Timer? _sheetExtentDebounce;

  bool _hasPrimedLocation =
      false;

  bool _isFetchingLocation =
      false;

  bool _didMoveInitialCamera =
      false;

  String? _locationHint;

  CurrentLocation?
      _previewCurrentLocation;

  KakaoMapController?
      _mapController;

  @override
  void initState() {

    super.initState();

    WidgetsBinding.instance
        .addPostFrameCallback((_) {

      _primeLocationIfNeeded(
        requestPermission: true,
      );
      _startProximityScan();
    });
  }

  @override
  void didUpdateWidget(
    covariant MapPage oldWidget,
  ) {

    super.didUpdateWidget(
      oldWidget,
    );

    if (widget.isVisible &&
        !oldWidget.isVisible) {

      _primeLocationIfNeeded(
        requestPermission: true,
      );
    }
  }

  @override
  void dispose() {

    _sheetExtentDebounce
        ?.cancel();
    BleProximityScanner.instance.stopScanning();

    super.dispose();
  }

  void _startProximityScan() {
    final controller = AppScope.controllerOf(context);
    final state = controller.state;
    // status == lost이고 bleCode가 있는 남의 분실물만 스캔 대상
    final wanted = state.lostItems
        .where((item) =>
            !item.isMine &&
            item.status == ItemStatus.lost &&
            item.bleCode != null &&
            item.bleCode!.isNotEmpty)
        .map((item) => (
              lostItemId: item.id,
              title: item.title,
              bleCode: item.bleCode!,
            ))
        .toList();

    BleProximityScanner.instance.addListener(_onDetected);
    BleProximityScanner.instance.startScanning(wantedItems: wanted);
  }

  void _onDetected(DetectedLostItem item) {
    if (!mounted) return;
    setState(() => _detectedItem = item);
  }

  @override
  Widget build(
    BuildContext context,
  ) {

    final controller =
        AppScope.controllerOf(
      context,
    );

    final state =
        controller.state;

    final currentLocation =
        _previewCurrentLocation ??
            state.currentLocation;

    /// =========================
    /// 위치 로딩 중
    /// =========================

    if (_isFetchingLocation &&
        currentLocation == null) {

      return const Scaffold(
        body: Center(
          child:
              CircularProgressIndicator(),
        ),
      );
    }

    final handler =
        MapPageHandler(

      context: context,

      controller: controller,

      state: state,

      currentLocation:
          currentLocation,

      layerMode: _layerMode,

      onLayerModeChanged:
          (value) {

        setState(() {

          _layerMode =
              value;
        });
      },

      /// =========================
      /// 중요:
      /// setState 제거
      /// =========================

      onMapControllerChanged:
          (value) {

        debugPrint(
          'mapController 저장',
        );

        _mapController =
            value;
      },
    );

    handler.mapController =
        _mapController;

    return MapPageBody(

      isVisible:
          widget.isVisible,

      state: state,

      filter: _filter,

      sort: _sort,

      layerMode: _layerMode,

      onFilterChanged:
          (value) {

        setState(() {

          _filter = value;
        });
      },

      handler: handler,

      currentLocation:
          currentLocation,

      sheetExtent:
          _sheetExtent,

      onSheetExtentChanged:
          _queueSheetExtentUpdate,

      locationHint:
          _locationHint,

      isFetchingLocation:
          _isFetchingLocation,

      onLocateCurrentLocation:
          () {

        _primeLocationIfNeeded(
          requestPermission:
              true,
        );
      },
      detectedItem: _detectedItem,
      onDetectedItemDismissed: () =>
          setState(() => _detectedItem = null),
    );
  }

  void _queueSheetExtentUpdate(
    double value,
  ) {

    _sheetExtentDebounce
        ?.cancel();

    _sheetExtentDebounce =
        Timer(
      const Duration(
        milliseconds: 120,
      ),

      () {

        if (!mounted) {
          return;
        }

        setState(() {

          _sheetExtent =
              value;
        });
      },
    );
  }

  void _primeLocationIfNeeded({
    bool requestPermission =
        false,
  }) {

    if (_isFetchingLocation ||
        !widget.isVisible) {

      return;
    }

    if (kIsWeb) {

      _hasPrimedLocation =
          true;

      if (mounted) {

        setState(() {

          _locationHint =
              '웹에서는 현재 위치 조회를 지원하지 않습니다.';
        });
      }

      return;
    }

    if (_hasPrimedLocation &&
        !requestPermission) {

      return;
    }

    _hasPrimedLocation =
        true;

    WidgetsBinding.instance
        .addPostFrameCallback((_) {

      if (!mounted) {
        return;
      }

      _syncCurrentLocation(
        requestPermission:
            requestPermission,
      );
    });
  }

  Future<void>
  _syncCurrentLocation({
    required bool
    requestPermission,
  }) async {

    if (_isFetchingLocation ||
        !mounted) {

      return;
    }

    setState(() {

      _isFetchingLocation =
          true;

      _locationHint = null;

      _previewCurrentLocation =
          null;
    });

    try {

      final serviceEnabled =
          await isLocationServiceEnabled();

      if (!serviceEnabled) {

        if (!mounted) {
          return;
        }

        setState(() {

          _locationHint =
              '위치 서비스가 꺼져 있습니다.';
        });

        return;
      }

      var permission =
          await checkLocationPermission();

      if (permission ==
              MapLocationPermission
                  .denied &&
          requestPermission) {

        permission =
            await requestLocationPermission();
      }

      if (permission ==
          MapLocationPermission
              .denied) {

        if (!mounted) {
          return;
        }

        setState(() {

          _locationHint =
              '현재 위치 권한이 필요합니다.';
        });

        return;
      }

      if (permission ==
          MapLocationPermission
              .deniedForever) {

        if (!mounted) {
          return;
        }

        setState(() {

          _locationHint =
              '설정에서 위치 권한을 허용해야 합니다.';
        });

        return;
      }

      final position =
          await getCurrentLocation();

      final resolvedLocation =
          CurrentLocation(

        latitude:
            position.latitude,

        longitude:
            position.longitude,

        accuracyMeters:
            position.accuracy,

        updatedAt:
            DateTime.now()
                .toIso8601String(),
      );

      if (!mounted) {
        return;
      }

      setState(() {

        _previewCurrentLocation =
            resolvedLocation;
      });

      /// =========================
      /// 최초 1회만 이동
      /// =========================

      if (!_didMoveInitialCamera) {

        _didMoveInitialCamera =
            true;

        Future.delayed(
          const Duration(
            seconds: 2,
          ),

          () {

            if (!mounted) {
              return;
            }

            debugPrint(
              '초기 위치 이동',
            );

            _mapController
                ?.setCenter(
              LatLng(
                position.latitude,
                position.longitude,
              ),
            );
          },
        );
      }

      final controller =
          AppScope.controllerOf(
        context,
      );

      await controller
          .saveCurrentLocation(
        latitude:
            position.latitude,

        longitude:
            position.longitude,

        accuracyMeters:
            position.accuracy,
      );

      if (!mounted) {
        return;
      }

      setState(() {

        _locationHint =
            null;

        _previewCurrentLocation =
            controller
                    .state
                    .currentLocation ??
                resolvedLocation;
      });

    } catch (e) {

      debugPrint(
        '현재 위치 에러: $e',
      );

      if (!mounted) {
        return;
      }

      setState(() {

        _locationHint =
            '현재 위치를 가져오지 못했습니다.';
      });

    } finally {

      if (mounted) {

        setState(() {

          _isFetchingLocation =
              false;
        });
      }
    }
  }
}