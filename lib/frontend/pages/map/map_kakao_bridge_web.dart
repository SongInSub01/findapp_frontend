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

class KakaoMapController {
  void setCenter(LatLng latLng) {}
}

class KakaoMap extends StatelessWidget {
  const KakaoMap({
    required this.onMapCreated,
    required this.markers,
    required this.onMarkerTap,
    super.key,
  });

  final ValueChanged<KakaoMapController> onMapCreated;
  final List<Marker> markers;
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
          for (final marker in markers)
            Positioned(
              left: _markerLeft(marker),
              top: _markerTop(marker),
              child: _TestMarkerDot(
                label: marker.markerId == 'current-location'
                    ? '내 위치'
                    : '주변',
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
    final lng =
        marker.latLng.longitude.toStringAsFixed(4).hashCode.abs() % 220;
    return 60 + lng.toDouble();
  }
}

class _TestMarkerDot extends StatelessWidget {
  const _TestMarkerDot({
    required this.label,
    required this.color,
  });

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
