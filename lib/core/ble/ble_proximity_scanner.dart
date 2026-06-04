import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

/// 주변에서 감지된 분실물 BLE 태그 정보다.
class DetectedLostItem {
  const DetectedLostItem({
    required this.lostItemId,
    required this.lostItemTitle,
    required this.bleCode,
    required this.rssi,
    this.latitude,
    this.longitude,
  });

  final String lostItemId;
  final String lostItemTitle;
  final String bleCode;
  final int rssi;
  final double? latitude;
  final double? longitude;
}

/// B사용자 앱에서 주변 분실물 BLE 태그를 자동 스캔하고 감지 시 알림을 보낸다.
/// 앱이 포그라운드에 있을 때 주기적으로 스캔하며, 감지된 항목은 콜백으로 전달한다.
class BleProximityScanner {
  BleProximityScanner._();

  static final BleProximityScanner instance = BleProximityScanner._();

  static const _scanIntervalSeconds = 30;
  static const _scanDurationSeconds = 8;
  static const int _notificationId = 9001;

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Timer? _timer;
  bool _isScanning = false;
  bool _initialized = false;

  /// 마지막으로 등록된 스캔 대상 목록 - 백그라운드 서비스가 재사용한다.
  List<({String lostItemId, String title, String bleCode})> _wantedItems = [];

  /// 현재 스캔 대상 수 - 백그라운드 서비스가 시작 여부 판단에 사용한다.
  int get wantedItemCount => _wantedItems.length;

  /// 감지된 분실물 아이템 콜백 - 지도/앱 UI에서 구독
  final List<void Function(DetectedLostItem)> _listeners = [];

  void addListener(void Function(DetectedLostItem) listener) {
    _listeners.add(listener);
  }

  void removeListener(void Function(DetectedLostItem) listener) {
    _listeners.remove(listener);
  }

  bool get isSupportedPlatform =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  /// 알림 플러그인 초기화
  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    await _notifications.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );
    _initialized = true;
  }

  /// 스캔 시작 - 지도 화면 진입 시 호출
  Future<void> startScanning({
    required List<({String lostItemId, String title, String bleCode})> wantedItems,
  }) async {
    if (!isSupportedPlatform || wantedItems.isEmpty) return;

    // 권한 요청
    final permissions = await [
      Permission.location,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
    ].request();

    final denied = permissions.values.any(
      (s) => s.isDenied || s.isPermanentlyDenied,
    );
    if (denied) return;

    await _ensureInitialized();
    stopScanning();

    // 스캔 대상 저장 (백그라운드 서비스가 재사용)
    _wantedItems = List.unmodifiable(wantedItems);

    // 즉시 1회 스캔 후 주기 반복
    await _runScan(wantedItems);
    _timer = Timer.periodic(
      const Duration(seconds: _scanIntervalSeconds),
      (_) => _runScan(wantedItems),
    );
  }

  /// 백그라운드 서비스에서 호출 - 저장된 wantedItems로 스캔 1회 실행한다.
  void triggerScanFromBackground() {
    if (_wantedItems.isEmpty) return;
    _runScan(_wantedItems);
  }

  /// 스캔 중단 - 지도 화면 이탈 시 호출
  void stopScanning() {
    _timer?.cancel();
    _timer = null;
    FlutterBluePlus.stopScan().catchError((_) {});
  }

  Future<void> _runScan(
    List<({String lostItemId, String title, String bleCode})> wantedItems,
  ) async {
    if (_isScanning) return;
    _isScanning = true;

    try {
      // BLE 코드를 정규화해서 비교용 맵 생성
      final wanted = {
        for (final item in wantedItems)
          _normalize(item.bleCode): item,
      };

      final found = <String, int>{};
      StreamSubscription<List<ScanResult>>? sub;

      sub = FlutterBluePlus.scanResults.listen((results) {
        for (final r in results) {
          final id = _normalize(r.device.remoteId.str);
          if (wanted.containsKey(id) && !found.containsKey(id)) {
            found[id] = r.rssi;
          }
        }
      });

      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: _scanDurationSeconds),
        continuousUpdates: false,
      ).catchError((_) {});

      await Future<void>.delayed(
        const Duration(seconds: _scanDurationSeconds + 1),
      );

      await sub.cancel();
      await FlutterBluePlus.stopScan().catchError((_) {});

      if (found.isEmpty) return;

      // GPS 위치 가져오기
      final position = await _tryGetPosition();

      for (final entry in found.entries) {
        final item = wanted[entry.key]!;
        final detected = DetectedLostItem(
          lostItemId: item.lostItemId,
          lostItemTitle: item.title,
          bleCode: item.bleCode,
          rssi: entry.value,
          latitude: position?.latitude,
          longitude: position?.longitude,
        );

        // 콜백 호출
        for (final listener in List.from(_listeners)) {
          listener(detected);
        }

        // 로컬 알림 발송
        await _sendNotification(item.title);
      }
    } catch (_) {
      // 스캔 실패는 무시 - 다음 주기에 재시도
    } finally {
      _isScanning = false;
    }
  }

  Future<Position?> _tryGetPosition() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return null;
      final perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) return null;
      return await Geolocator.getCurrentPosition();
    } catch (_) {
      return null;
    }
  }

  Future<void> _sendNotification(String itemTitle) async {
    try {
      await _notifications.show(
        _notificationId,
        '근처에 분실물이 있습니다',
        '$itemTitle의 BLE 태그가 감지되었습니다. 소리를 울려 찾아주세요.',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'lost_item_proximity',
            '분실물 근접 알림',
            channelDescription: '주변에서 분실물 BLE 태그가 감지되면 알려줍니다.',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );
    } catch (_) {}
  }

  String _normalize(String value) =>
      value.toLowerCase().replaceAll(RegExp(r'[^0-9a-z]'), '');
}
