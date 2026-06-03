import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

/// 주변에서 검색된 BLE 태그 한 개의 화면 표시용 정보다.
class BleTagCandidate {
  const BleTagCandidate({
    required this.device,
    required this.remoteId,
    required this.name,
    required this.rssi,
  });

  final BluetoothDevice device;
  final String remoteId;
  final String name;
  final int rssi;

  String get displayName => name.isEmpty ? 'BLE 태그 ($remoteId)' : name;
}

/// 실제 BLE 신호와 휴대폰 위치를 백엔드에 보낼 수 있는 형태로 묶는다.
class BleSignalMeasurement {
  const BleSignalMeasurement({
    required this.rssi,
    this.latitude,
    this.longitude,
    this.accuracyMeters,
    this.batteryPercent,
  });

  final int rssi;
  final double? latitude;
  final double? longitude;
  final double? accuracyMeters;
  final int? batteryPercent;
}

/// KakaoMapTest의 BLE 검색, 배터리 읽기, 소리 울리기를 기존 앱에서 재사용한다.
class BleTagService {
  static const String _pcbBleCode = 'D8:A2:49:50:EF:91';
  static final Set<String> _activeRingCodes = {};

  bool get isSupportedPlatform {
    return !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);
  }

  Future<void> requestPermissions() async {
    if (!isSupportedPlatform) {
      throw Exception(
        'BLE 검색은 Android 또는 iOS 설치 앱에서만 사용할 수 있습니다. '
        'USB로 연결한 실물 휴대폰을 선택하여 flutter run을 다시 실행해 주세요.',
      );
    }
    final permissions = await [
      Permission.location,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
    ].request();
    if (permissions.values.any((status) => status.isPermanentlyDenied)) {
      throw Exception('BLE 권한이 차단되어 있습니다. 휴대폰 설정에서 위치와 근처 기기 권한을 허용해 주세요.');
    }
    if (permissions.values.any((status) => status.isDenied)) {
      throw Exception('BLE 검색을 사용하려면 위치와 근처 기기 권한을 허용해 주세요.');
    }
  }

  Future<List<BleTagCandidate>> scanNearby({
    Duration timeout = const Duration(seconds: 6),
  }) async {
    await requestPermissions();
    await FlutterBluePlus.stopScan().catchError((_) {});

    final candidates = <String, BleTagCandidate>{};
    final subscription = FlutterBluePlus.scanResults.listen((results) {
      for (final result in results) {
        final remoteId = result.device.remoteId.str;
        candidates[remoteId] = BleTagCandidate(
          device: result.device,
          remoteId: remoteId,
          name: result.device.platformName,
          rssi: result.rssi,
        );
      }
    });

    try {
      await FlutterBluePlus.startScan(continuousUpdates: true);
      await Future<void>.delayed(timeout);
    } catch (error) {
      throw Exception(_friendlyBleErrorMessage(error));
    } finally {
      await FlutterBluePlus.stopScan().catchError((_) {});
      await subscription.cancel();
    }

    final result = candidates.values.toList()
      ..sort((left, right) => right.rssi.compareTo(left.rssi));
    return result;
  }

  Future<BleSignalMeasurement> measureRegisteredTag(String bleCode) async {
    try {
      final candidate = await _findRegisteredTag(
        bleCode,
        allowDirectAndroidFallback: true,
      );
      final position = await _tryGetCurrentPosition();
      final resolvedRssi = candidate.rssi == 0
          ? await _readConnectedRssi(candidate.device)
          : candidate.rssi;
      final batteryPercent = await _readBatteryPercent(candidate.device);

      return BleSignalMeasurement(
        rssi: resolvedRssi,
        latitude: position?.latitude,
        longitude: position?.longitude,
        accuracyMeters: position?.accuracy,
        batteryPercent: batteryPercent,
      );
    } catch (error) {
      throw Exception(_friendlyBleErrorMessage(error));
    }
  }

  Future<void> ringRegisteredTag(String bleCode) async {
    final normalizedCode = _normalize(bleCode);
    if (!_activeRingCodes.add(normalizedCode)) {
      throw Exception('이미 이 BLE 태그에 연결을 시도하고 있습니다. 잠시 후 다시 눌러 주세요.');
    }

    BluetoothDevice? connectedDevice;
    try {
      debugPrint('[BLE ring] 직접 연결 우선: $bleCode');
      var candidate = await _findRegisteredTag(
        bleCode,
        allowDirectAndroidFallback: true,
        preferDirectAndroidConnection: true,
      );
      connectedDevice = candidate.device;
      try {
        await _connect(candidate.device);
      } catch (_) {
        debugPrint('[BLE ring] 직접 연결 실패, 주변 스캔으로 재시도: $bleCode');
        await connectedDevice.disconnect().catchError((_) {});
        candidate = await _findRegisteredTag(bleCode);
        connectedDevice = candidate.device;
        await _connect(candidate.device);
      }
      await Future<void>.delayed(const Duration(milliseconds: 800));
      final services = await candidate.device.discoverServices().timeout(
        const Duration(seconds: 10),
      );
      if (_normalize(bleCode) == _normalize(_pcbBleCode) &&
          await _tryRingPcbTag(services)) {
        return;
      }
      await _disableLinkLoss(services);
      for (final service in services) {
        final serviceUuid = service.uuid.toString().toLowerCase();
        for (final characteristic in service.characteristics) {
          final characteristicUuid = characteristic.uuid
              .toString()
              .toLowerCase();
          if (serviceUuid.contains('5301') &&
              characteristicUuid.contains('5302')) {
            await characteristic.write([0x42], withoutResponse: true);
            return;
          }
          if (serviceUuid.contains('1802') &&
              characteristicUuid.contains('2a06')) {
            for (var attempt = 0; attempt < 3; attempt++) {
              await characteristic.write([0x01], withoutResponse: true);
              await Future<void>.delayed(const Duration(milliseconds: 800));
            }
            return;
          }
        }
      }
      throw Exception('이 태그에서 소리 울리기 기능을 찾지 못했습니다.');
    } catch (error) {
      throw Exception(_friendlyBleErrorMessage(error));
    } finally {
      await connectedDevice?.disconnect().catchError((_) {});
      _activeRingCodes.remove(normalizedCode);
    }
  }

  Future<BleTagCandidate> _findRegisteredTag(
    String bleCode, {
    bool allowDirectAndroidFallback = false,
    bool preferDirectAndroidConnection = false,
  }) async {
    final normalizedCode = _normalize(bleCode);
    if (preferDirectAndroidConnection &&
        allowDirectAndroidFallback &&
        defaultTargetPlatform == TargetPlatform.android &&
        _looksLikeMacAddress(bleCode)) {
      return BleTagCandidate(
        device: BluetoothDevice.fromId(bleCode),
        remoteId: bleCode,
        name: '',
        rssi: 0,
      );
    }

    final candidates = await scanNearby(timeout: const Duration(seconds: 12));
    for (final candidate in candidates) {
      if (_normalize(candidate.remoteId) == normalizedCode) {
        return candidate;
      }
    }
    if (allowDirectAndroidFallback &&
        defaultTargetPlatform == TargetPlatform.android &&
        _looksLikeMacAddress(bleCode)) {
      return BleTagCandidate(
        device: BluetoothDevice.fromId(bleCode),
        remoteId: bleCode,
        name: '',
        rssi: 0,
      );
    }
    throw Exception('등록된 BLE 태그를 주변에서 찾지 못했습니다.');
  }

  Future<Position?> _tryGetCurrentPosition() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return null;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    return Geolocator.getCurrentPosition();
  }

  Future<void> _connect(BluetoothDevice device) async {
    await FlutterBluePlus.stopScan().catchError((_) {});
    await Future<void>.delayed(const Duration(milliseconds: 400));
    await device.disconnect().catchError((_) {});
    await Future<void>.delayed(const Duration(milliseconds: 300));

    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        await device.connect(
          autoConnect: false,
          timeout: const Duration(seconds: 15),
        );
        return;
      } catch (_) {
        await device.disconnect().catchError((_) {});
        if (attempt == 2) {
          rethrow;
        }
        await Future<void>.delayed(const Duration(seconds: 2));
      }
    }
  }

  Future<int> _readConnectedRssi(BluetoothDevice device) async {
    try {
      await _connect(device);
      final rssi = await device.readRssi().timeout(const Duration(seconds: 5));
      return rssi == 0 ? -90 : rssi;
    } catch (_) {
      return -90;
    } finally {
      await device.disconnect().catchError((_) {});
    }
  }

  Future<bool> _tryRingPcbTag(List<BluetoothService> services) async {
    for (final service in services) {
      final serviceUuid = service.uuid.toString().toLowerCase();
      if (!serviceUuid.contains('5833ff01') &&
          !serviceUuid.contains('1236fccd')) {
        continue;
      }
      for (final characteristic in service.characteristics) {
        final characteristicUuid = characteristic.uuid.toString().toLowerCase();
        if (!characteristicUuid.contains('ff02') &&
            !characteristicUuid.contains('1236fccf')) {
          continue;
        }
        const command = [0x55, 0x02, 0x00, 0x00, 0x59];
        try {
          await characteristic.write(command, withoutResponse: false);
        } catch (_) {
          await characteristic.write(command, withoutResponse: true);
        }
        return true;
      }
    }
    return false;
  }

  Future<void> _disableLinkLoss(List<BluetoothService> services) async {
    for (final service in services) {
      final serviceUuid = service.uuid.toString().toLowerCase();
      for (final characteristic in service.characteristics) {
        final characteristicUuid = characteristic.uuid.toString().toLowerCase();
        if (serviceUuid.contains('1803') &&
            characteristicUuid.contains('2a06')) {
          await characteristic
              .write([0x00], withoutResponse: false)
              .catchError((_) {});
        }
        if (serviceUuid.contains('ffe0') &&
            characteristicUuid.contains('ffe2')) {
          await characteristic
              .write([0x00], withoutResponse: false)
              .catchError((_) {});
        }
      }
    }
  }

  Future<int?> _readBatteryPercent(BluetoothDevice device) async {
    try {
      await _connect(device);
      final services = await device.discoverServices();

      for (final service in services) {
        if (!service.uuid.toString().toLowerCase().contains('180f')) {
          continue;
        }
        for (final characteristic in service.characteristics) {
          if (characteristic.uuid.toString().toLowerCase().contains('2a19') &&
              characteristic.properties.read) {
            final value = await characteristic.read();
            if (value.isNotEmpty) {
              return value.first.clamp(0, 100);
            }
          }
        }
      }

      for (final service in services) {
        if (!service.uuid.toString().toLowerCase().contains('5301')) {
          continue;
        }
        BluetoothCharacteristic? writeCharacteristic;
        BluetoothCharacteristic? notifyCharacteristic;
        for (final characteristic in service.characteristics) {
          final uuid = characteristic.uuid.toString().toLowerCase();
          if (uuid.contains('5302') && characteristic.properties.write) {
            writeCharacteristic = characteristic;
          }
          if (uuid.contains('5303') && characteristic.properties.notify) {
            notifyCharacteristic = characteristic;
          }
        }
        if (notifyCharacteristic == null) {
          continue;
        }

        await notifyCharacteristic.setNotifyValue(true);
        await writeCharacteristic?.write([0x00], withoutResponse: true);
        final value = await notifyCharacteristic.lastValueStream
            .where((bytes) => bytes.isNotEmpty)
            .first
            .timeout(const Duration(seconds: 5));
        await notifyCharacteristic
            .setNotifyValue(false)
            .catchError((_) => false);
        for (final byte in value) {
          if (byte >= 1 && byte <= 100) {
            return byte;
          }
        }
      }
      return null;
    } catch (_) {
      return null;
    } finally {
      await device.disconnect().catchError((_) {});
    }
  }

  String _normalize(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'[^0-9a-z]'), '');
  }

  bool _looksLikeMacAddress(String value) {
    return RegExp(r'^([0-9a-fA-F]{2}:){5}[0-9a-fA-F]{2}$').hasMatch(value);
  }

  String _friendlyBleErrorMessage(Object error) {
    final rawMessage = error.toString().replaceFirst('Exception: ', '');
    final normalized = rawMessage.toLowerCase();

    if (rawMessage.contains('이미 이 BLE 태그') ||
        rawMessage.contains('소리 울리기 기능을 찾지 못했습니다') ||
        rawMessage.contains('등록된 BLE 태그를 주변에서 찾지 못했습니다') ||
        rawMessage.contains('BLE 권한이 차단되어 있습니다') ||
        rawMessage.contains('BLE 검색을 사용하려면')) {
      return rawMessage;
    }
    if (normalized.contains('permission') ||
        normalized.contains('권한') ||
        normalized.contains('bluetooth_connect')) {
      return 'Bluetooth 연결 권한이 없습니다. 휴대폰 설정에서 근처 기기 권한을 허용해 주세요.';
    }
    if (normalized.contains('timeout') ||
        normalized.contains('timed out') ||
        normalized.contains('timeoutexception')) {
      return 'BLE 태그 연결 시간이 초과되었습니다. 태그를 가까이 두고 Bluetooth 상태를 확인한 뒤 다시 시도해 주세요.';
    }
    if (normalized.contains('not found') ||
        normalized.contains('device_not_found')) {
      return '등록된 BLE 태그를 주변에서 찾지 못했습니다. 태그의 전원과 거리를 확인해 주세요.';
    }
    if (normalized.contains('disconnect') ||
        normalized.contains('connect') ||
        normalized.contains('android-code') ||
        normalized.contains('gatt')) {
      return 'BLE 태그에 연결하지 못했습니다. 다른 앱의 BLE 연결을 종료하고 태그를 가까이 둔 뒤 다시 시도해 주세요.';
    }

    return 'BLE 태그와 통신하지 못했습니다. Bluetooth 상태와 태그 거리를 확인한 뒤 다시 시도해 주세요.';
  }
}
