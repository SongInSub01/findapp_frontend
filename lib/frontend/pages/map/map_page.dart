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

class MapPage extends StatefulWidget {
  const MapPage({required this.isVisible, super.key});

  final bool isVisible;

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  MapFilter _filter = MapFilter.all;
  final MapSort _sort = MapSort.recent;
  MapLayerMode _layerMode = MapLayerMode.city;
  double _sheetExtent = 0.28;
  Timer? _sheetExtentDebounce;
  bool _hasPrimedLocation = false;
  bool _isFetchingLocation = false;
  String? _locationHint;
  CurrentLocation? _previewCurrentLocation;
  KakaoMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _primeLocationIfNeeded();
  }

  @override
  void didUpdateWidget(covariant MapPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible && !oldWidget.isVisible) {
      _primeLocationIfNeeded();
    }
  }

  @override
  void dispose() {
    _sheetExtentDebounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.controllerOf(context);
    final state = controller.state;

    final handler = MapPageHandler(
      context: context,
      controller: controller,
      state: state,
      currentLocation: _previewCurrentLocation ?? state.currentLocation,
      layerMode: _layerMode,
      onLayerModeChanged: (value) => setState(() => _layerMode = value),
      onMapControllerChanged: (value) => setState(() => _mapController = value),
    );
    handler.mapController = _mapController;

    return MapPageBody(
      isVisible: widget.isVisible,
      state: state,
      filter: _filter,
      sort: _sort,
      layerMode: _layerMode,
      onFilterChanged: (value) => setState(() => _filter = value),
      handler: handler,
      currentLocation: _previewCurrentLocation ?? state.currentLocation,
      sheetExtent: _sheetExtent,
      onSheetExtentChanged: _queueSheetExtentUpdate,
      locationHint: _locationHint,
      isFetchingLocation: _isFetchingLocation,
      onLocateCurrentLocation: () =>
          _primeLocationIfNeeded(requestPermission: true),
    );
  }

  void _queueSheetExtentUpdate(double value) {
    _sheetExtentDebounce?.cancel();
    _sheetExtentDebounce = Timer(const Duration(milliseconds: 120), () {
      if (!mounted) {
        return;
      }
      setState(() {
        _sheetExtent = value;
      });
    });
  }

  void _primeLocationIfNeeded({bool requestPermission = false}) {
    if (_isFetchingLocation || !widget.isVisible) {
      return;
    }

    if (kIsWeb) {
      _hasPrimedLocation = true;
      if (mounted) {
        setState(() {
          _locationHint = '웹에서는 현재 위치 조회를 지원하지 않습니다.';
        });
      }
      return;
    }

    if (_hasPrimedLocation && !requestPermission) {
      return;
    }

    _hasPrimedLocation = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _syncCurrentLocation(requestPermission: requestPermission);
    });
  }

  Future<void> _syncCurrentLocation({required bool requestPermission}) async {
    if (_isFetchingLocation || !mounted) {
      return;
    }

    setState(() {
      _isFetchingLocation = true;
      _locationHint = null;
      _previewCurrentLocation = null;
    });

    try {
      final serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) {
          return;
        }
        setState(() {
          _locationHint = '위치 서비스가 꺼져 있습니다. 설정에서 켜 주세요.';
        });
        return;
      }

      var permission = await checkLocationPermission();
      if (permission == MapLocationPermission.denied && requestPermission) {
        permission = await requestLocationPermission();
      }

      if (permission == MapLocationPermission.denied) {
        if (!mounted) {
          return;
        }
        setState(() {
          _locationHint = '현재 위치를 표시하려면 권한이 필요합니다.';
        });
        return;
      }

      if (permission == MapLocationPermission.deniedForever) {
        if (!mounted) {
          return;
        }
        setState(() {
          _locationHint = '권한이 완전히 거부되어 설정 앱에서 허용해야 합니다.';
        });
        return;
      }

      final position = await getCurrentLocation();
      final resolvedLocation = CurrentLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracyMeters: position.accuracy,
        updatedAt: DateTime.now().toIso8601String(),
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _previewCurrentLocation = resolvedLocation;
      });
      _mapController?.setCenter(LatLng(position.latitude, position.longitude));
      final controller = AppScope.controllerOf(context);
      await controller.saveCurrentLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracyMeters: position.accuracy,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _locationHint = null;
        _previewCurrentLocation =
            controller.state.currentLocation ?? resolvedLocation;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _locationHint = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('현재 위치는 지도에 표시했지만 서버 저장에 실패했습니다.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isFetchingLocation = false;
        });
      }
    }
  }
}
