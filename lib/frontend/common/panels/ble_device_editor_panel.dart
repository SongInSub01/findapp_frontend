import 'package:flutter/material.dart';

import 'package:my_flutter_starter/app/state/app_controller.dart';
import 'package:my_flutter_starter/core/utils/formatters.dart';
import 'package:my_flutter_starter/data/models/app_models.dart';
import 'package:my_flutter_starter/frontend/common/panels/app_panel_helpers.dart';
import 'package:my_flutter_starter/frontend/common/panels/ble_device_scan_panel.dart';
import 'package:my_flutter_starter/frontend/common/panels/app_panel_scaffold.dart';
import 'package:my_flutter_starter/frontend/common/resources/app_assets.dart';
import 'package:my_flutter_starter/frontend/common/theme/app_text_styles.dart';
import 'package:my_flutter_starter/frontend/common/widgets/app_buttons.dart';
import 'package:my_flutter_starter/frontend/common/widgets/app_text_field.dart';

Future<void> showBleDeviceEditorPanel(
  BuildContext context, {
  required AppController controller,
  required AppState state,
  BleDevice? device,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) =>
        _BleEditorPanel(controller: controller, state: state, device: device),
  );
}

class _BleEditorPanel extends StatefulWidget {
  const _BleEditorPanel({
    required this.controller,
    required this.state,
    this.device,
  });

  final AppController controller;
  final AppState state;
  final BleDevice? device;

  @override
  State<_BleEditorPanel> createState() => _BleEditorPanelState();
}

class _BleEditorPanelState extends State<_BleEditorPanel> {
  late final TextEditingController _nameController;
  late final TextEditingController _codeController;
  late final TextEditingController _locationController;
  late final TextEditingController _distanceController;
  late ItemStatus _status;
  late String _selectedIconKey;
  late String _selectedPhotoAsset;
  bool _isSaving = false;
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    final device = widget.device;
    _nameController = TextEditingController(text: device?.name ?? '');
    _codeController = TextEditingController(text: device?.bleCode ?? '');
    _locationController = TextEditingController(
      text: device?.location ?? '내 주변 (1m)',
    );
    _distanceController = TextEditingController(text: device?.distance ?? '1m');
    _status = device?.status ?? ItemStatus.safe;
    _selectedIconKey = device?.iconKey ?? 'wallet';
    _selectedPhotoAsset = device?.photoAssetPath ?? AppAssets.icon;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _locationController.dispose();
    _distanceController.dispose();
    super.dispose();
  }

  /// 중복 BLE 코드 같은 백엔드 검증 오류를 사용자가 바로 보게 한다.
  Future<void> _showSaveError(Object error) async {
    final message = error.toString().replaceFirst('Exception: ', '');
    await showDialog<void>(
      context: context,
      useRootNavigator: true,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.info_outline_rounded),
        title: Text(widget.device == null ? 'BLE 기기 등록 안내' : 'BLE 기기 수정 안내'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final base =
        widget.device ??
        BleDevice(
          id: '',
          name: '새 BLE 기기',
          iconKey: 'wallet',
          status: ItemStatus.safe,
          location: '내 주변 (1m)',
          lastSeen: '방금 전',
          bleCode: 'BLE-NEW-001',
          lastSignalAt: DateTime.now().toIso8601String(),
          mapX: 0.42,
          mapY: 0.52,
          distance: '1m',
          photoAssetPath: AppAssets.icon,
        );

    return AppPanelScaffold(
      title: widget.device == null ? 'BLE 코드 등록' : 'BLE 기기 수정',
      subtitle: '센서 이름, 코드, 상태, 대표 이미지를 한 화면에서 관리합니다.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTextField(controller: _nameController, label: '기기 이름'),
          const SizedBox(height: 12),
          AppTextField(controller: _codeController, label: 'BLE 코드'),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _isScanning
                ? null
                : () async {
                    setState(() => _isScanning = true);
                    try {
                      final candidate = await showBleDeviceScanPanel(context);
                      if (candidate == null || !mounted) {
                        return;
                      }
                      _codeController.text = candidate.remoteId;
                      if (_nameController.text.trim().isEmpty ||
                          _nameController.text.trim() == '새 BLE 기기') {
                        _nameController.text = candidate.displayName;
                      }
                    } finally {
                      if (mounted) {
                        setState(() => _isScanning = false);
                      }
                    }
                  },
            icon: const Icon(Icons.bluetooth_searching_rounded),
            label: Text(_isScanning ? '검색 중...' : '주변 기기 검색'),
          ),
          const SizedBox(height: 12),
          AppTextField(controller: _locationController, label: '현재 위치 설명'),
          const SizedBox(height: 12),
          AppTextField(controller: _distanceController, label: '거리 표시값'),
          const SizedBox(height: 16),
          Text(
            '기기 유형',
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _selectedIconKey,
            decoration: const InputDecoration(labelText: '아이콘 유형'),
            items: const [
              DropdownMenuItem(value: 'wallet', child: Text('지갑')),
              DropdownMenuItem(value: 'key', child: Text('열쇠')),
              DropdownMenuItem(value: 'bag', child: Text('가방')),
              DropdownMenuItem(value: 'item', child: Text('일반 물건')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedIconKey = value);
              }
            },
          ),
          const SizedBox(height: 16),
          Text(
            '상태',
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ItemStatus.values
                .map(
                  (status) => ChoiceChip(
                    label: Text(statusText(status)),
                    selected: _status == status,
                    onSelected: (_) => setState(() => _status = status),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          Text(
            '대표 이미지',
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          AssetOptionSelector(
            options: AppAssets.devicePhotos,
            selectedAsset: _selectedPhotoAsset,
            onSelected: (asset) => setState(() => _selectedPhotoAsset = asset),
          ),
          const SizedBox(height: 18),
          AppPrimaryButton(
            label: _isSaving ? '저장 중...' : '저장',
            expanded: true,
            onPressed: _isSaving
                ? null
                : () async {
                    final name = _nameController.text.trim();
                    final code = _codeController.text.trim();
                    setState(() => _isSaving = true);
                    try {
                      await widget.controller.saveBleDevice(
                        base.copyWith(
                          id: widget.device?.id ?? Formatters.uniqueId('d'),
                          name: name.isEmpty ? base.name : name,
                          iconKey: _selectedIconKey,
                          bleCode: code.isEmpty ? base.bleCode : code,
                          location: _locationController.text.trim().isEmpty
                              ? base.location
                              : _locationController.text.trim(),
                          distance: _distanceController.text.trim().isEmpty
                              ? base.distance
                              : _distanceController.text.trim(),
                          lastSeen: '방금 전',
                          lastSignalAt: DateTime.now().toIso8601String(),
                          status: _status,
                          photoAssetPath: _selectedPhotoAsset,
                        ),
                      );
                      if (!context.mounted) {
                        return;
                      }
                      Navigator.of(context).pop();
                    } catch (error) {
                      if (!context.mounted) {
                        return;
                      }
                      await _showSaveError(error);
                    } finally {
                      if (mounted) {
                        setState(() => _isSaving = false);
                      }
                    }
                  },
          ),
        ],
      ),
    );
  }
}
