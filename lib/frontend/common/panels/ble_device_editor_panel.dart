import 'package:flutter/material.dart';

import 'package:my_flutter_starter/app/state/app_controller.dart';
import 'package:my_flutter_starter/core/utils/formatters.dart';
import 'package:my_flutter_starter/data/models/app_models.dart';
import 'package:my_flutter_starter/frontend/common/panels/app_panel_helpers.dart';
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
    builder: (context) => _BleEditorPanel(
      controller: controller,
      state: state,
      device: device,
    ),
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

  @override
  void initState() {
    super.initState();
    final device = widget.device;
    _nameController = TextEditingController(text: device?.name ?? '');
    _codeController = TextEditingController(text: device?.bleCode ?? '');
    _locationController = TextEditingController(text: device?.location ?? '내 주변 (1m)');
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

  @override
  Widget build(BuildContext context) {
    final base = widget.device ??
        const BleDevice(
          id: '',
          name: '새 BLE 기기',
          iconKey: 'wallet',
          status: ItemStatus.safe,
          location: '내 주변 (1m)',
          lastSeen: '방금 전',
          bleCode: 'BLE-NEW-001',
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
          const SizedBox(height: 12),
          AppTextField(controller: _locationController, label: '현재 위치 설명'),
          const SizedBox(height: 12),
          AppTextField(controller: _distanceController, label: '거리 표시값'),
          const SizedBox(height: 16),
          Text('기기 유형', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
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
          Text('상태', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
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
          Text('대표 이미지', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          AssetOptionSelector(
            options: AppAssets.devicePhotos,
            selectedAsset: _selectedPhotoAsset,
            onSelected: (asset) => setState(() => _selectedPhotoAsset = asset),
          ),
          const SizedBox(height: 18),
          AppPrimaryButton(
            label: '저장',
            expanded: true,
            onPressed: () {
              final name = _nameController.text.trim();
              final code = _codeController.text.trim();
              widget.controller.saveBleDevice(
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
                  status: _status,
                  photoAssetPath: _selectedPhotoAsset,
                ),
              );
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
