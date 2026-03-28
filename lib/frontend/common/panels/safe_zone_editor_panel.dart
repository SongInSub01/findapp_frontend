import 'package:flutter/material.dart';

import 'package:my_flutter_starter/app/state/app_controller.dart';
import 'package:my_flutter_starter/data/models/app_models.dart';
import 'package:my_flutter_starter/frontend/common/panels/app_panel_scaffold.dart';
import 'package:my_flutter_starter/frontend/common/widgets/app_buttons.dart';
import 'package:my_flutter_starter/frontend/common/widgets/app_text_field.dart';

Future<void> showSafeZoneEditorPanel(
  BuildContext context, {
  required AppController controller,
  SafeZone? zone,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => _SafeZoneEditorPanel(
      controller: controller,
      zone: zone,
    ),
  );
}

class _SafeZoneEditorPanel extends StatefulWidget {
  const _SafeZoneEditorPanel({
    required this.controller,
    this.zone,
  });

  final AppController controller;
  final SafeZone? zone;

  @override
  State<_SafeZoneEditorPanel> createState() => _SafeZoneEditorPanelState();
}

class _SafeZoneEditorPanelState extends State<_SafeZoneEditorPanel> {
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final TextEditingController _radiusController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.zone?.name ?? '');
    _addressController = TextEditingController(text: widget.zone?.address ?? '');
    _radiusController = TextEditingController(
      text: widget.zone?.radiusMeters.toString() ?? '50',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _radiusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final radius = int.tryParse(_radiusController.text.trim()) ?? widget.zone?.radiusMeters ?? 50;
    return AppPanelScaffold(
      title: widget.zone == null ? '안전지대 추가' : '안전지대 수정',
      subtitle: '안심 구역에서는 BLE 거리 알림이 울리지 않도록 설정합니다.',
      child: Column(
        children: [
          AppTextField(controller: _nameController, label: '구역 이름'),
          const SizedBox(height: 12),
          AppTextField(controller: _addressController, label: '주소'),
          const SizedBox(height: 12),
          AppTextField(
            controller: _radiusController,
            label: '반경 (m)',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 18),
          AppPrimaryButton(
            label: _isSaving ? '저장 중...' : '저장',
            expanded: true,
            onPressed: _isSaving
                ? null
                : () async {
                    setState(() => _isSaving = true);
                    try {
                      await widget.controller.saveSafeZone(
                        SafeZone(
                          id: widget.zone?.id ?? '',
                          name: _nameController.text.trim().isEmpty
                              ? (widget.zone?.name ?? '새 안심 구역')
                              : _nameController.text.trim(),
                          address: _addressController.text.trim().isEmpty
                              ? (widget.zone?.address ?? '주소 미입력')
                              : _addressController.text.trim(),
                          radiusMeters: radius,
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(error.toString().replaceFirst('Exception: ', '')),
                        ),
                      );
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
