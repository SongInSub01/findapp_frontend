import 'package:flutter/material.dart';

class LatLng {
  const LatLng(this.latitude, this.longitude);

  final double latitude;
  final double longitude;
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

class Circle {
  const Circle({
    required this.circleId,
    required this.center,
    required this.radiusMeters,
    required this.strokeColor,
    required this.fillColor,
  });

  final String circleId;
  final LatLng center;
  final double radiusMeters;
  final Color strokeColor;
  final Color fillColor;
}

class KakaoMapController {
  void setCenter(LatLng latLng) {}
}

class KakaoMap extends StatelessWidget {
  const KakaoMap({
    required this.onMapCreated,
    required this.markers,
    this.circles = const [],
    required this.onMarkerTap,
    super.key,
  });

  final ValueChanged<KakaoMapController> onMapCreated;
  final List<Marker> markers;
  final List<Circle> circles;
  final void Function(String markerId, LatLng latLng, int zoomLevel)
  onMarkerTap;

  @override
  Widget build(BuildContext context) {
    final controller = KakaoMapController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onMapCreated(controller);
    });

    final accent = Theme.of(context).colorScheme.primary;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            accent.withValues(alpha: 0.16),
            const Color(0xFFF8FAFC),
            const Color(0xFFEFF6FF),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _GridPainter(accent: accent.withValues(alpha: 0.08)),
            ),
          ),
          for (final circle in circles)
            Positioned(
              left: _circleLeft(circle),
              top: _circleTop(circle),
              child: _TestRadiusCircle(
                radiusPixels: _circleRadiusPixels(circle),
                strokeColor: circle.strokeColor,
                fillColor: circle.fillColor,
              ),
            ),
          for (final marker in markers)
            Positioned(
              left: _markerLeft(marker),
              top: _markerTop(marker),
              child: _TestMarkerDot(
                label: marker.markerId == 'current-location' ? '내 위치' : '주변',
                color: marker.markerId == 'current-location'
                    ? accent
                    : const Color(0xFFF97316),
              ),
            ),
        ],
      ),
    );
  }

  double _markerLeft(Marker marker) {
    final lat = marker.latLng.latitude.toStringAsFixed(4).hashCode.abs() % 280;
    return 24 + lat.toDouble();
  }

  double _markerTop(Marker marker) {
    final lng = marker.latLng.longitude.toStringAsFixed(4).hashCode.abs() % 220;
    return 60 + lng.toDouble();
  }

  double _circleLeft(Circle circle) {
    final marker = Marker(
      markerId: circle.circleId,
      latLng: circle.center,
      width: 0,
      height: 0,
    );
    return _markerLeft(marker) - _circleRadiusPixels(circle);
  }

  double _circleTop(Circle circle) {
    final marker = Marker(
      markerId: circle.circleId,
      latLng: circle.center,
      width: 0,
      height: 0,
    );
    return _markerTop(marker) - _circleRadiusPixels(circle);
  }

  double _circleRadiusPixels(Circle circle) {
    return circle.radiusMeters.clamp(3, 100).toDouble() * 0.7 + 12;
  }
}

class _TestRadiusCircle extends StatelessWidget {
  const _TestRadiusCircle({
    required this.radiusPixels,
    required this.strokeColor,
    required this.fillColor,
  });

  final double radiusPixels;
  final Color strokeColor;
  final Color fillColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radiusPixels * 2,
      height: radiusPixels * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: fillColor.withValues(alpha: 0.22),
        border: Border.all(
          color: strokeColor.withValues(alpha: 0.85),
          width: 2,
        ),
      ),
    );
  }
}

class _TestMarkerDot extends StatelessWidget {
  const _TestMarkerDot({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xE60F172A),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
          ),
        ),
      ],
    );
  }
}

class _GridPainter extends CustomPainter {
  _GridPainter({required this.accent});

  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = accent
      ..strokeWidth = 1;

    for (double x = 0; x < size.width; x += size.width / 6) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }
    for (double y = 0; y < size.height; y += size.height / 8) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) {
    return oldDelegate.accent != accent;
  }
}
