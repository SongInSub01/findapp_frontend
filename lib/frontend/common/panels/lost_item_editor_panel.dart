import 'package:flutter/material.dart';

import 'package:my_flutter_starter/app/state/app_controller.dart';
import 'package:my_flutter_starter/data/models/app_models.dart';
import 'package:my_flutter_starter/frontend/common/panels/app_panel_helpers.dart';
import 'package:my_flutter_starter/frontend/common/panels/app_panel_scaffold.dart';
import 'package:my_flutter_starter/frontend/common/resources/app_assets.dart';
import 'package:my_flutter_starter/frontend/common/theme/app_text_styles.dart';
import 'package:my_flutter_starter/frontend/common/widgets/app_buttons.dart';
import 'package:my_flutter_starter/frontend/common/widgets/app_text_field.dart';

import 'package:my_flutter_starter/frontend/pages/map/map_select_page.dart';

Future<void> showLostItemEditorPanel(
  BuildContext context, {
  required AppController controller,
  LostItem? existingItem,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: Colors.white,
    builder: (context) => _LostItemEditorPanel(
      controller: controller,
      existingItem: existingItem,
    ),
  );
}

class _LostItemEditorPanel extends StatefulWidget {
  const _LostItemEditorPanel({
    required this.controller,
    this.existingItem,
  });

  final AppController controller;
  final LostItem? existingItem;

  bool get isEditMode => existingItem != null;

  @override
  State<_LostItemEditorPanel> createState() => _LostItemEditorPanelState();
}

class _LostItemEditorPanelState extends State<_LostItemEditorPanel> {
  late final TextEditingController _titleController;
  late final TextEditingController _detailLocationController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _rewardController;

  late String _selectedPhotoAsset;
  bool _isSaving = false;
  String _selectedLocation = '';
  double? _latitude;
  double? _longitude;
  late DateTime _happenedAt;

  @override
  void initState() {
    super.initState();
    final item = widget.existingItem;
    _titleController = TextEditingController(text: item?.title ?? '');
    _detailLocationController = TextEditingController();
    _descriptionController = TextEditingController(text: item?.description ?? '');
    _rewardController = TextEditingController(
      text: item != null && item.reward > 0 ? '${item.reward}' : '',
    );
    _selectedPhotoAsset = item?.photoAssetPath ?? AppAssets.splashIcon;
    _happenedAt = DateTime.now();

    if (item != null) {
      _selectedLocation = item.location;
      if (item.happenedAt != null) {
        try {
          _happenedAt = DateTime.parse(item.happenedAt!).toLocal();
        } catch (_) {}
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _detailLocationController.dispose();
    _descriptionController.dispose();
    _rewardController.dispose();
    super.dispose();
  }

  Future<void> _selectHappenedAt() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _happenedAt,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now,
      helpText: '분실 날짜 선택',
    );
    if (!context.mounted || pickedDate == null) return;
    setState(() {
      _happenedAt = DateTime(pickedDate.year, pickedDate.month, pickedDate.day);
    });
  }

  Future<void> _selectLocation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MapSelectPage()),
    );
    if (result != null) {
      setState(() {
        _selectedLocation = result['address'] as String;
        _latitude = result['lat'] as double?;
        _longitude = result['lng'] as double?;
      });
    }
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    final reward = int.tryParse(
          _rewardController.text.replaceAll(',', ''),
        ) ??
        0;

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('분실물 이름을 입력해 주세요.')),
      );
      return;
    }
    if (_selectedLocation.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('분실 위치를 선택해 주세요.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      if (widget.isEditMode) {
        await widget.controller.updateLostItem(
          itemId: widget.existingItem!.id,
          title: title,
          location: _selectedLocation,
          reward: reward,
          description: _descriptionController.text.trim(),
          detailLocation: _detailLocationController.text.trim(),
          happenedAt: _happenedAt,
          photoAssetPath: _selectedPhotoAsset,
        );
      } else {
        await widget.controller.saveLostItem(
          title: title,
          location: _selectedLocation,
          reward: reward,
          description: _descriptionController.text.trim(),
          detailLocation: _detailLocationController.text.trim(),
          happenedAt: _happenedAt,
          photoAssetPath: _selectedPhotoAsset,
        );
      }

      if (!context.mounted) return;
      Navigator.of(context).pop();
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppPanelScaffold(
      title: widget.isEditMode ? '분실물 편집' : '분실물 등록',
      subtitle: '분실물 정보를 입력해 주세요.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 사진 선택
          Text(
            '대표 이미지',
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          AssetOptionSelector(
            options: AppAssets.lostItemPhotos,
            selectedAsset: _selectedPhotoAsset,
            onSelected: (asset) {
              setState(() => _selectedPhotoAsset = asset);
            },
          ),

          const SizedBox(height: 20),

          /// 분실물 이름
          AppTextField(
            controller: _titleController,
            label: '분실물 이름',
            hintText: '예: 에어팟 프로',
          ),

          const SizedBox(height: 16),

          /// 위치 선택
          Text(
            '분실 위치',
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: OutlinedButton.icon(
              onPressed: _selectLocation,
              icon: const Icon(Icons.location_on_outlined),
              label: Text(
                _selectedLocation.isEmpty ? '위치 선택하기' : '위치 다시 선택',
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF4A90E2),
                side: const BorderSide(color: Color(0xFFD6E6FF)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          if (_selectedLocation.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F9FF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 18,
                    color: Color(0xFF4A90E2),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(_selectedLocation, style: AppTextStyles.body),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),

          /// 분실 시간
          Text(
            '분실 시간',
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: _selectHappenedAt,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F9FF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFD6E6FF)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 18,
                    color: Color(0xFF4A90E2),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${_happenedAt.year}년 ${_happenedAt.month}월 ${_happenedAt.day}일',
                      style: AppTextStyles.body,
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: Color(0xFF4A90E2),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          /// 상세 위치
          AppTextField(
            controller: _detailLocationController,
            label: '상세 위치 (선택)',
            hintText: '예: 본관 3층, 도서관 열람실 앞 등',
          ),

          const SizedBox(height: 16),

          /// 상세 설명
          AppTextField(
            controller: _descriptionController,
            label: '상세 설명',
            maxLines: 4,
            hintText: '색상, 특징, 마지막으로 본 상황 등을 입력해 주세요.',
          ),

          const SizedBox(height: 16),

          /// 사례금
          AppTextField(
            controller: _rewardController,
            label: '사례금 (선택)',
            hintText: '예: 30000',
            keyboardType: TextInputType.number,
          ),

          const SizedBox(height: 16),

          /// 보호 안내
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F9FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.shield_outlined,
                  size: 18,
                  color: Color(0xFF4A90E2),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '승인 전까지 사진은 보호됩니다.',
                    style: AppTextStyles.caption.copyWith(
                      color: const Color(0xFF4A90E2),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          /// 등록/수정 버튼
          AppPrimaryButton(
            label: _isSaving
                ? (widget.isEditMode ? '수정 중...' : '등록 중...')
                : (widget.isEditMode ? '수정하기' : '분실물 등록하기'),
            expanded: true,
            onPressed: _isSaving ? null : _submit,
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
