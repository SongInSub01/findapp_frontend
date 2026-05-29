import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart'
    as kakao;

import 'package:my_flutter_starter/core/config/kakao_map_config.dart';

bool get _isTestBinding =>
    const bool.fromEnvironment(
      'FLUTTER_TEST',
    ) ||
    SchedulerBinding.instance
        .runtimeType
        .toString()
        .contains(
          'TestWidgetsFlutterBinding',
        );

class LatLng {
  const LatLng(
    this.latitude,
    this.longitude,
  );

  final double latitude;
  final double longitude;

  kakao.LatLng toKakaoLatLng() {
    return kakao.LatLng(
      latitude,
      longitude,
    );
  }
}

class Marker {
  const Marker({
    required this.markerId,
    required this.latLng,
    required this.width,
    required this.height,
    this.customOverlayContent,
    this.zIndex = 0,
  });

  final String markerId;
  final LatLng latLng;
  final double width;
  final double height;
  final String? customOverlayContent;
  final int zIndex;
}

class KakaoMapController {
  kakao.KakaoMapController?
      _controller;

  bool _isReady = false;

  LatLng? _pendingCenter;

  void attach(
    kakao.KakaoMapController
        controller,
  ) {
    _controller = controller;

    _isReady = true;

    final pendingCenter =
        _pendingCenter;

    if (pendingCenter != null) {
      Future.delayed(
        const Duration(
          milliseconds: 250,
        ),
        () {
          controller.setCenter(
            pendingCenter
                .toKakaoLatLng(),
          );

          _pendingCenter =
              null;
        },
      );
    }
  }

  void setCenter(
    LatLng latLng,
  ) {
    if (!_isReady) {
      _pendingCenter =
          latLng;

      return;
    }

    Future.delayed(
      const Duration(
        milliseconds: 200,
      ),
      () {
        _controller?.setCenter(
          latLng.toKakaoLatLng(),
        );
      },
    );
  }
}

class KakaoMap
    extends StatefulWidget {
  const KakaoMap({
    required this.onMapCreated,
    required this.markers,
    required this.onMarkerTap,
    this.onMapTap,
    super.key,
  });

  final ValueChanged<
          KakaoMapController>
      onMapCreated;

  final List<Marker> markers;

  final void Function(
    String markerId,
    LatLng latLng,
    int zoomLevel,
  ) onMarkerTap;

  /// 지도 클릭
  final void Function(
    LatLng latLng,
  )? onMapTap;

  @override
  State<KakaoMap> createState() =>
      _KakaoMapState();
}

class _KakaoMapState
    extends State<KakaoMap> {
  final KakaoMapController
      _controller =
      KakaoMapController();

  bool _didReportController =
      false;

  bool _mapReady = false;

  @override
  void initState() {
    super.initState();

    Future.delayed(
      const Duration(
        milliseconds: 400,
      ),
      () {
        if (!mounted) {
          return;
        }

        setState(() {
          _mapReady = true;
        });
      },
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    /// 테스트/키 없음
    if (_isTestBinding ||
        !KakaoMapConfig
            .hasJavaScriptKey) {
      WidgetsBinding.instance
          .addPostFrameCallback(
        (_) {
          if (!mounted ||
              _didReportController) {
            return;
          }

          _didReportController =
              true;

          widget.onMapCreated(
            _controller,
          );
        },
      );

      return _TestMapSurface(
        markers: widget.markers,
        isFallback:
            !KakaoMapConfig
                .hasJavaScriptKey,
      );
    }

    /// 로딩
    if (!_mapReady) {
      return const Center(
        child:
            CircularProgressIndicator(),
      );
    }

    /// 실제 카카오맵
    return kakao.KakaoMap(
      onMapCreated:
          (controller) async {
        _controller.attach(
          controller,
        );

        await Future.delayed(
          const Duration(
            milliseconds: 300,
          ),
        );

        if (!_didReportController) {
          _didReportController =
              true;

          widget.onMapCreated(
            _controller,
          );
        }
      },

      /// 지도 클릭 이벤트
      onMapTap: (latLng) {
        widget.onMapTap?.call(
          LatLng(
            latLng.latitude,
            latLng.longitude,
          ),
        );
      },

      markers:
          widget.markers.isEmpty
              ? []
              : widget.markers
                    .map(
                      (marker) =>
                          kakao.Marker(
                        markerId:
                            marker
                                .markerId,

                        latLng:
                            marker
                                .latLng
                                .toKakaoLatLng(),

                        width:
                            marker
                                .width
                                .round(),

                        height:
                            marker
                                .height
                                .round(),

                        customOverlayContent:
                            marker
                                .customOverlayContent,

                        zIndex:
                            marker
                                .zIndex,
                      ),
                    )
                    .toList(),

      onMarkerTap: (
        markerId,
        latLng,
        zoomLevel,
      ) {
        widget.onMarkerTap(
          markerId,

          LatLng(
            latLng.latitude,
            latLng.longitude,
          ),

          zoomLevel,
        );
      },
    );
  }
}

class _TestMapSurface
    extends StatelessWidget {
  const _TestMapSurface({
    required this.markers,
    this.isFallback = false,
  });

  final List<Marker> markers;

  final bool isFallback;

  @override
  Widget build(
    BuildContext context,
  ) {
    final accent =
        Theme.of(context)
            .colorScheme
            .primary;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient:
            LinearGradient(
          begin:
              Alignment.topCenter,

          end:
              Alignment.bottomCenter,

          colors: [
            accent.withValues(
              alpha: 0.16,
            ),

            const Color(
              0xFFF8FAFC,
            ),

            const Color(
              0xFFEFF6FF,
            ),
          ],
        ),
      ),

      child: Stack(
        children: [
          if (isFallback)
            Positioned.fill(
              child: Center(
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(
                    horizontal: 24,
                  ),

                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),

                  decoration:
                      BoxDecoration(
                    color:
                        Colors.white
                            .withValues(
                      alpha: 0.88,
                    ),

                    borderRadius:
                        BorderRadius.circular(
                      20,
                    ),
                  ),

                  child: Text(
                    '카카오 지도 키가 없습니다.',

                    textAlign:
                        TextAlign.center,
                  ),
                ),
              ),
            ),

          for (final marker
              in markers)
            Positioned(
              left:
                  _markerLeft(
                marker,
              ),

              top:
                  _markerTop(
                marker,
              ),

              child:
                  _TestMarkerDot(
                label:
                    marker.markerId ==
                            'current-location'
                        ? '내 위치'
                        : '주변',

                color:
                    marker.markerId ==
                            'current-location'
                        ? accent
                        : const Color(
                            0xFFF97316,
                          ),
              ),
            ),
        ],
      ),
    );
  }

  double _markerLeft(
    Marker marker,
  ) {
    final lat =
        marker.latLng.latitude
            .toStringAsFixed(4)
            .hashCode
            .abs() %
        280;

    return 24 + lat.toDouble();
  }

  double _markerTop(
    Marker marker,
  ) {
    final lng =
        marker.latLng.longitude
            .toStringAsFixed(4)
            .hashCode
            .abs() %
        220;

    return 60 + lng.toDouble();
  }
}

class _TestMarkerDot
    extends StatelessWidget {
  const _TestMarkerDot({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Column(
      mainAxisSize:
          MainAxisSize.min,

      children: [
        Container(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),

          decoration:
              BoxDecoration(
            color: const Color(
              0xE60F172A,
            ),

            borderRadius:
                BorderRadius.circular(
              999,
            ),
          ),

          child: Text(
            label,

            style:
                const TextStyle(
              color:
                  Colors.white,

              fontSize: 11,

              fontWeight:
                  FontWeight.w700,
            ),
          ),
        ),

        const SizedBox(
          height: 6,
        ),

        Container(
          width: 16,
          height: 16,

          decoration:
              BoxDecoration(
            color: color,

            shape:
                BoxShape.circle,

            border: Border.all(
              color:
                  Colors.white,

              width: 3,
            ),
          ),
        ),
      ],
    );
  }
}