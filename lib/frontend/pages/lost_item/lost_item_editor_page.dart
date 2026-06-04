import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:my_flutter_starter/app/state/app_controller.dart';
import 'package:my_flutter_starter/data/models/app_models.dart';
import 'package:my_flutter_starter/data/services/photo_upload_service.dart';
import 'package:my_flutter_starter/frontend/common/theme/app_colors.dart';
import 'package:my_flutter_starter/frontend/common/theme/app_text_styles.dart';
import 'package:my_flutter_starter/frontend/common/widgets/app_buttons.dart';
import 'package:my_flutter_starter/frontend/common/widgets/app_text_field.dart';
import 'package:my_flutter_starter/frontend/pages/map/map_select_page.dart';

class LostItemEditorPage extends StatefulWidget {
  const LostItemEditorPage({
    required this.controller,
    this.existingItem,
    super.key,
  });

  final AppController controller;
  final LostItem? existingItem;

  bool get isEditMode => existingItem != null;

  @override
  State<LostItemEditorPage> createState() => _LostItemEditorPageState();
}

class _LostItemEditorPageState extends State<LostItemEditorPage> {
  late final TextEditingController _titleController;
  late final TextEditingController _detailLocationController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _rewardController;

  File? _pickedImageFile;
  String? _existingImageUrl;
  bool _isSaving = false;
  bool _isUploading = false;
  String _selectedLocation = '';
  double? _latitude;
  double? _longitude;
  late DateTime _happenedAt;

  // 사례금 선택 상태
  static const _rewardPresets = [0, 5000, 10000, 30000, 50000, 100000];
  int? _selectedRewardPreset;   // null = 기타
  bool _rewardDropdownOpen = false;

  @override
  void initState() {
    super.initState();
    final item = widget.existingItem;
    _titleController = TextEditingController(text: item?.title ?? '');
    _detailLocationController = TextEditingController();
    _descriptionController =
        TextEditingController(text: item?.description ?? '');
    final existingReward = item != null && item.reward > 0 ? item.reward : 0;
    _selectedRewardPreset = _rewardPresets.contains(existingReward) ? existingReward : null;
    _rewardController = TextEditingController(
      text: (_selectedRewardPreset == null && existingReward > 0) ? '$existingReward' : '',
    );
    _happenedAt = DateTime.now();
    _existingImageUrl = item?.photoAssetPath;
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

  Future<void> _pickImage(ImageSource source) async {
    setState(() => _isUploading = true);
    try {
      final url = await PhotoUploadService.pickAndUpload(source: source);
      if (url != null) {
        setState(() {
          _existingImageUrl = url;
          _pickedImageFile = null;
        });
      }
    } catch (_) {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: source, imageQuality: 80);
      if (picked != null) setState(() => _pickedImageFile = File(picked.path));
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _showPickerDialog() {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('카메라로 촬영'),
              onTap: () {
                Navigator.of(ctx).pop();
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('갤러리에서 선택'),
              onTap: () {
                Navigator.of(ctx).pop();
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
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

  Future<void> _selectHappenedAt() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _happenedAt,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now,
      helpText: '분실 날짜 선택',
    );
    if (!mounted || pickedDate == null) return;
    setState(() {
      _happenedAt = DateTime(pickedDate.year, pickedDate.month, pickedDate.day);
    });
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    final reward =
        _selectedRewardPreset ?? int.tryParse(_rewardController.text.replaceAll(',', '')) ?? 0;

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
      final finalImageUrl =
          _pickedImageFile?.path ?? _existingImageUrl;

      if (widget.isEditMode) {
        await widget.controller.saveLostItem(
          itemId: widget.existingItem!.id,
          title: title,
          location: _selectedLocation,
          reward: reward,
          description: _descriptionController.text.trim(),
          happenedAt: _happenedAt,
          photoAssetPath: finalImageUrl,
        );
      } else {
        await widget.controller.saveLostItem(
          title: title,
          location: _selectedLocation,
          reward: reward,
          description: _descriptionController.text.trim(),
          happenedAt: _happenedAt,
          latitude: _latitude,
          longitude: _longitude,
          photoAssetPath: finalImageUrl,
        );
      }
      setState(() => _isSaving = false);
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (error) {
      setState(() => _isSaving = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasPhoto = _pickedImageFile != null || _existingImageUrl != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.isEditMode ? '분실물 편집' : '분실물 등록',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: Color(0xFF2563EB),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFF1F5F9)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 사진
            Text(
              '분실물 사진 *',
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              '등록 후 다른 사람들에게는 보호 이미지로 표시됩니다.\n주인이 승인한 사람만 실제 사진을 볼 수 있습니다.',
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.textSecondary, height: 1.5),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _showPickerDialog,
              child: Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F9FF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: hasPhoto
                        ? AppColors.primary.withValues(alpha: 0.4)
                        : const Color(0xFFD6E6FF),
                    width: hasPhoto ? 2 : 1,
                  ),
                ),
                child: _isUploading
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 10),
                            Text('업로드 중...'),
                          ],
                        ),
                      )
                    : _pickedImageFile != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.file(
                          _pickedImageFile!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      )
                    : _existingImageUrl != null &&
                          _existingImageUrl!.startsWith('http')
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.network(
                          _existingImageUrl!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) =>
                              _PhotoPlaceholder(hasPhoto: false),
                        ),
                      )
                    : _PhotoPlaceholder(hasPhoto: hasPhoto),
              ),
            ),
            if (hasPhoto) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: _showPickerDialog,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('사진 다시 선택'),
              ),
            ],

            // 승인 안내
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F9FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFD6E6FF)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.shield_outlined,
                    size: 18,
                    color: Color(0xFF2563EB),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '사진은 잠금 상태로 등록됩니다.\n"메시지 보내기"로 연락 온 사람에게만 내가 직접 승인하면 사진이 공개됩니다.',
                      style: AppTextStyles.caption.copyWith(
                        color: const Color(0xFF2563EB),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            AppTextField(
              controller: _titleController,
              label: '분실물 이름',
              hintText: '예: 에어팟 프로',
            ),
            const SizedBox(height: 16),

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
                    const Icon(Icons.location_on,
                        size: 18, color: Color(0xFF4A90E2)),
                    const SizedBox(width: 8),
                    Expanded(
                      child:
                          Text(_selectedLocation, style: AppTextStyles.body),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),

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
                    const Icon(Icons.calendar_today_outlined,
                        size: 18, color: Color(0xFF4A90E2)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${_happenedAt.year}년 ${_happenedAt.month}월 ${_happenedAt.day}일',
                        style: AppTextStyles.body,
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded,
                        size: 18, color: Color(0xFF4A90E2)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            AppTextField(
              controller: _detailLocationController,
              label: '상세 위치 (선택)',
              hintText: '예: 본관 3층, 도서관 열람실 앞 등',
            ),
            const SizedBox(height: 16),

            AppTextField(
              controller: _descriptionController,
              label: '상세 설명',
              maxLines: 4,
              hintText: '색상, 특징, 마지막으로 본 상황 등을 입력해 주세요.',
            ),
            const SizedBox(height: 16),

            _RewardSelector(
              presets: _rewardPresets,
              selectedPreset: _selectedRewardPreset,
              isOpen: _rewardDropdownOpen,
              customController: _rewardController,
              onToggle: () => setState(() => _rewardDropdownOpen = !_rewardDropdownOpen),
              onSelect: (value) => setState(() {
                _selectedRewardPreset = value;
                _rewardDropdownOpen = false;
                if (value != null) _rewardController.clear();
              }),
            ),
            const SizedBox(height: 28),

            AppPrimaryButton(
              label: _isSaving
                  ? (widget.isEditMode ? '수정 중...' : '등록 중...')
                  : (widget.isEditMode ? '수정하기' : '분실물 등록하기'),
              expanded: true,
              onPressed: _isSaving || _isUploading ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}

/// 사례금 선택 위젯: 탭하면 프리셋 목록이 펼쳐지고 "기타" 선택 시 직접 입력 필드 노출
class _RewardSelector extends StatelessWidget {
  const _RewardSelector({
    required this.presets,
    required this.selectedPreset,
    required this.isOpen,
    required this.customController,
    required this.onToggle,
    required this.onSelect,
  });

  final List<int> presets;
  final int? selectedPreset;
  final bool isOpen;
  final TextEditingController customController;
  final VoidCallback onToggle;
  final ValueChanged<int?> onSelect;

  String _label(int value) {
    if (value == 0) return '0원 (사례금 없음)';
    if (value >= 10000) return '${value ~/ 10000}만원';
    return '${value ~/ 1000}천원';
  }

  @override
  Widget build(BuildContext context) {
    final isCustom = selectedPreset == null;
    final displayText = isCustom
        ? (customController.text.isEmpty ? '기타 (직접 입력)' : '기타: ${customController.text}원')
        : _label(selectedPreset!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 라벨
        Text(
          '사례금 (선택)',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 8),
        // 선택 버튼
        GestureDetector(
          onTap: onToggle,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F9FF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isOpen
                    ? const Color(0xFF2563EB)
                    : const Color(0xFFD6E6FF),
                width: isOpen ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.card_giftcard_rounded,
                    size: 18, color: Color(0xFF2563EB)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    displayText,
                    style: TextStyle(
                      fontSize: 15,
                      color: (isCustom && customController.text.isEmpty)
                          ? const Color(0xFF9CA3AF)
                          : const Color(0xFF111827),
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: isOpen ? 0.5 : 0,
                  duration: const Duration(milliseconds: 180),
                  child: const Icon(Icons.keyboard_arrow_down_rounded,
                      color: Color(0xFF2563EB)),
                ),
              ],
            ),
          ),
        ),
        // 펼쳐지는 목록
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          child: isOpen
              ? Container(
                  margin: const EdgeInsets.only(top: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFD6E6FF)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x14000000),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      for (final preset in presets)
                        _RewardOption(
                          label: _label(preset),
                          isSelected: selectedPreset == preset,
                          onTap: () => onSelect(preset),
                        ),
                      const Divider(height: 1),
                      _RewardOption(
                        label: '기타 (직접 입력)',
                        isSelected: isCustom,
                        onTap: () => onSelect(null),
                        icon: Icons.edit_outlined,
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
        // 기타 선택 시 직접 입력 필드
        AnimatedSize(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          child: isCustom
              ? Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: TextField(
                    controller: customController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: '금액을 직접 입력하세요 (원)',
                      filled: true,
                      fillColor: const Color(0xFFF5F9FF),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFFD6E6FF)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFFD6E6FF)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                            color: Color(0xFF2563EB), width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _RewardOption extends StatelessWidget {
  const _RewardOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFEFF6FF)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(
              icon ?? (isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded),
              size: 18,
              color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF9CA3AF),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF111827),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoPlaceholder extends StatelessWidget {
  const _PhotoPlaceholder({required this.hasPhoto});

  final bool hasPhoto;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          hasPhoto
              ? Icons.check_circle_outline_rounded
              : Icons.add_a_photo_outlined,
          size: 48,
          color: hasPhoto ? AppColors.primary : AppColors.textTertiary,
        ),
        const SizedBox(height: 10),
        Text(
          hasPhoto ? '사진 선택됨' : '탭하여 사진 추가',
          style: TextStyle(
            color: hasPhoto ? AppColors.primary : AppColors.textTertiary,
            fontSize: 13,
          ),
        ),
        if (!hasPhoto) ...[
          const SizedBox(height: 4),
          const Text(
            '카메라 촬영 또는 갤러리 선택',
            style: TextStyle(color: AppColors.textTertiary, fontSize: 12),
          ),
        ],
      ],
    );
  }
}
