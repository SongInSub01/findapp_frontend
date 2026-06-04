import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import 'ble_proximity_scanner.dart';

/// 백그라운드 isolate에서 실행되는 TaskHandler.
/// 플랫폼 채널을 쓸 수 없으므로, 30초마다 메인 isolate에 스캔 신호만 보낸다.
@pragma('vm:entry-point')
void bleBackgroundTaskEntryPoint() {
  FlutterForegroundTask.setTaskHandler(_BleBackgroundTaskHandler());
}

class _BleBackgroundTaskHandler extends TaskHandler {
  @override
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {}

  @override
  @override
  void onRepeatEvent(DateTime timestamp) {
    // 메인 isolate에 스캔 트리거 신호 전달
    FlutterForegroundTask.sendDataToMain({'action': 'ble_scan'});
  }

  @override
  @override
  Future<void> onDestroy(DateTime timestamp) async {}
}

/// 메인 isolate에서 포그라운드 서비스 시작/중단을 관리하는 싱글턴이다.
///
/// 동작 원리:
/// 1. 앱이 백그라운드로 내려가면 [startBackground] 호출 → Android Foreground Service 시작
/// 2. 서비스가 30초마다 메인 isolate로 신호를 보냄
/// 3. 메인 isolate가 신호를 받아 [BleProximityScanner.triggerScanFromBackground] 호출
/// 4. BLE 스캔은 항상 메인 isolate에서 실행됨 (플랫폼 채널 필요)
/// 5. 앱이 포그라운드로 복귀하면 [stopBackground] 호출 → 서비스 종료
class BleBackgroundService {
  BleBackgroundService._();
  static final BleBackgroundService instance = BleBackgroundService._();

  bool _isRunning = false;

  /// main() 에서 앱 시작 시 한 번 초기화한다.
  void init() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'ble_proximity_scan',
        channelName: '분실물 BLE 탐색',
        channelDescription: '백그라운드에서 주변 분실물 BLE 신호를 탐색합니다.',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: false,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(30000),
        autoRunOnBoot: false,
        allowWifiLock: false,
      ),
    );
  }

  /// 앱이 백그라운드로 내려갈 때 호출한다.
  Future<void> startBackground() async {
    if (_isRunning) return;
    if (!BleProximityScanner.instance.isSupportedPlatform) return;
    if (BleProximityScanner.instance.wantedItemCount == 0) return;

    FlutterForegroundTask.addTaskDataCallback(_onData);

    final result = await FlutterForegroundTask.startService(
      serviceId: 2001,
      notificationTitle: '분실물 BLE 탐색 중',
      notificationText: '주변에서 분실물 신호를 탐색하고 있습니다.',
      callback: bleBackgroundTaskEntryPoint,
    );

    if (result is ServiceRequestSuccess) {
      _isRunning = true;
    }
  }

  /// 앱이 포그라운드로 복귀할 때 호출한다.
  Future<void> stopBackground() async {
    if (!_isRunning) return;
    FlutterForegroundTask.removeTaskDataCallback(_onData);
    await FlutterForegroundTask.stopService();
    _isRunning = false;
  }

  void _onData(Object data) {
    if (data is Map && data['action'] == 'ble_scan') {
      BleProximityScanner.instance.triggerScanFromBackground();
    }
  }
}
