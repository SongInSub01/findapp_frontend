import 'package:flutter/material.dart';

import 'package:my_flutter_starter/app/state/app_controller.dart';
import 'package:my_flutter_starter/frontend/common/panels/app_panel_helpers.dart';
import 'package:my_flutter_starter/frontend/common/panels/app_panel_scaffold.dart';
import 'package:my_flutter_starter/frontend/common/resources/app_assets.dart';
import 'package:my_flutter_starter/frontend/common/theme/app_colors.dart';
import 'package:my_flutter_starter/frontend/common/theme/app_text_styles.dart';
import 'package:my_flutter_starter/frontend/common/widgets/app_buttons.dart';
import 'package:my_flutter_starter/frontend/common/widgets/app_text_field.dart';

Future<void> showLostItemEditorPanel(
  BuildContext context, {
  required AppController controller,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => _LostItemEditorPanel(controller: controller),
  );
}

class _LostItemEditorPanel extends StatefulWidget {
  const _LostItemEditorPanel({required this.controller});

  final AppController controller;

  @override
  State<_LostItemEditorPanel> createState() => _LostItemEditorPanelState();
}

class _LostItemEditorPanelState extends State<_LostItemEditorPanel> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _rewardController = TextEditingController(
    text: '30000',
  );
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedPhotoAsset = AppAssets.splashIcon;
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _rewardController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppPanelScaffold(
      title: '분실물 등록',
      subtitle: '분실 위치, 설명, 사례금과 보호 이미지를 입력해 탐색 흐름을 시작합니다.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTextField(controller: _titleController, label: '분실물 이름'),
          const SizedBox(height: 12),
          AppTextField(controller: _locationController, label: '분실 장소'),
          const SizedBox(height: 12),
          AppTextField(
            controller: _rewardController,
            label: '사례금',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: _descriptionController,
            label: '상세 설명',
            maxLines: 4,
            hintText: '색상, 특징, 마지막 확인 장소 등을 적어주세요.',
          ),
          const SizedBox(height: 16),
          Text(
            '대표 이미지 선택',
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          AssetOptionSelector(
            options: AppAssets.lostItemPhotos,
            selectedAsset: _selectedPhotoAsset,
            onSelected: (asset) => setState(() => _selectedPhotoAsset = asset),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.borderLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              '사진은 기본 잠금 상태로 등록되며, 주인 승인 후에만 열람할 수 있습니다.',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 18),
          AppPrimaryButton(
            label: _isSaving ? '등록 중...' : '등록',
            expanded: true,
            onPressed: _isSaving
                ? null
                : () async {
                    final title = _titleController.text.trim();
                    final location = _locationController.text.trim();
                    final reward =
                        int.tryParse(
                          _rewardController.text.replaceAll(',', ''),
                        ) ??
                        30000;
                    if (title.isEmpty || location.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('분실물 이름과 분실 장소를 입력해 주세요.'),
                        ),
                      );
                      return;
                    }
                    setState(() => _isSaving = true);
                    try {
                      await widget.controller.saveLostItem(
                        title: title,
                        location: location,
                        reward: reward,
                        description: _descriptionController.text.trim().isEmpty
                            ? 'BLE 감지 후 등록된 분실물입니다.'
                            : _descriptionController.text.trim(),
                        photoAssetPath: _selectedPhotoAsset,
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
                          content: Text(
                            error.toString().replaceFirst('Exception: ', ''),
                          ),
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
