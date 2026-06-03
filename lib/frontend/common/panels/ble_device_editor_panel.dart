import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:my_flutter_starter/app/state/app_controller.dart';
import 'package:my_flutter_starter/core/utils/formatters.dart';
import 'package:my_flutter_starter/data/models/app_models.dart';
import 'package:my_flutter_starter/data/services/photo_upload_service.dart';
import 'package:my_flutter_starter/frontend/common/panels/app_panel_scaffold.dart';
import 'package:my_flutter_starter/frontend/common/theme/app_colors.dart';
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
  late final TextEditingController _descriptionController;
  late final TextEditingController _customCategoryController;
  late String _selectedIconKey;

  /// 선택한 로컬 사진 파일 (업로드 전)
  File? _pickedImageFile;

  /// 이미 저장된 사진 URL (편집 모드)
  String? _existingImageUrl;

  bool _isSaving = false;
  bool _isUploading = false;

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
    _descriptionController = TextEditingController();
    _customCategoryController = TextEditingController();
    _selectedIconKey = device?.iconKey ?? 'wallet';
    _existingImageUrl = device?.photoAssetPath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _locationController.dispose();
    _distanceController.dispose();
    _descriptionController.dispose();
    _customCategoryController.dispose();
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
    } catch (e) {
      if (!mounted) return;
      // 업로드 실패 시 로컬 파일만 미리보기로 사용
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: source, imageQuality: 80);
      if (picked != null) {
        setState(() => _pickedImageFile = File(picked.path));
      }
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

  @override
  Widget build(BuildContext context) {
    final bool hasPhoto =
        _pickedImageFile != null || _existingImageUrl != null;

    return AppPanelScaffold(
      title: widget.device == null ? 'BLE 기기 등록' : 'BLE 기기 수정',
      subtitle: '기기 정보와 사진을 등록하면 분실 시 사람들이 찾는 데 도움이 됩니다.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 대표 사진 (필수)
          Text(
            '대표 사진 *',
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            '분실 시 다른 사람들에게는 보호 이미지로 표시됩니다.\n주인이 승인한 사람만 실제 사진을 볼 수 있습니다.',
            style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
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
                        errorBuilder: (context, error, stackTrace) => const _PhotoPlaceholder(
                          hasPhoto: false,
                        ),
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

          const SizedBox(height: 20),

          AppTextField(controller: _nameController, label: '기기 이름 *'),
          const SizedBox(height: 12),
          AppTextField(controller: _codeController, label: 'BLE 코드'),
          const SizedBox(height: 12),
          AppTextField(controller: _locationController, label: '현재 위치 설명'),
          const SizedBox(height: 12),
          AppTextField(controller: _distanceController, label: '거리 표시값'),
          const SizedBox(height: 12),

          /// 물건 설명 (필수)
          AppTextField(
            controller: _descriptionController,
            label: '물건 설명 *',
            maxLines: 3,
            hintText: '색상, 브랜드, 특징 등을 자세히 적어주세요.\n예: 검정색 삼성 갤럭시 버즈, 케이스에 흰색 스티커',
          ),
          const SizedBox(height: 16),

          Text(
            '물건 종류',
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          _CategoryGrid(
            selected: _selectedIconKey,
            onSelected: (key) => setState(() => _selectedIconKey = key),
          ),
          if (_selectedIconKey == 'item') ...[
            const SizedBox(height: 10),
            AppTextField(
              controller: _customCategoryController,
              label: '직접 입력',
              hintText: '물건 종류를 직접 입력해 주세요. 예: 스케이트보드',
            ),
          ],
          const SizedBox(height: 24),

          AppPrimaryButton(
            label: _isSaving ? '저장 중...' : '저장',
            expanded: true,
            onPressed: _isSaving || _isUploading ? null : _submit,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('기기 이름을 입력해 주세요.')),
      );
      return;
    }
    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('물건 설명을 입력해 주세요.')),
      );
      return;
    }
    if (_selectedIconKey == 'item' &&
        _customCategoryController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('물건 종류를 직접 입력해 주세요.')),
      );
      return;
    }
    if (!(_pickedImageFile != null || _existingImageUrl != null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('대표 사진을 선택해 주세요.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final String? finalImageUrl;
      if (_pickedImageFile != null) {
        finalImageUrl = _pickedImageFile!.path;
      } else {
        finalImageUrl = _existingImageUrl;
      }

      final loc = _locationController.text.trim();
      final dist = _distanceController.text.trim();
      final code = _codeController.text.trim();

      final deviceToSave = BleDevice(
        id: widget.device?.id ?? Formatters.uniqueId('d'),
        name: name,
        iconKey: _selectedIconKey,
        status: widget.device?.status ?? ItemStatus.safe,
        location: loc.isEmpty ? '내 주변 (1m)' : loc,
        lastSeen: '방금 전',
        bleCode: code.isEmpty ? 'BLE-NEW-001' : code,
        lastSignalAt: DateTime.now().toIso8601String(),
        mapX: widget.device?.mapX ?? 0.42,
        mapY: widget.device?.mapY ?? 0.52,
        distance: dist.isEmpty ? '1m' : dist,
        photoAssetPath: finalImageUrl,
      );

      await widget.controller.saveBleDevice(deviceToSave);
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
}

// 물건 종류 선택 그리드
class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({required this.selected, required this.onSelected});

  final String selected;
  final void Function(String) onSelected;

  static const _categories = [
    ('wallet',    '지갑/카드지갑',      Icons.account_balance_wallet_outlined),
    ('key',       '열쇠/키홀더',        Icons.vpn_key_outlined),
    ('bag',       '가방/백팩',          Icons.shopping_bag_outlined),
    ('earphone',  '이어폰/에어팟',      Icons.headphones_outlined),
    ('laptop',    '노트북/태블릿',      Icons.laptop_outlined),
    ('phone',     '스마트폰',           Icons.smartphone_outlined),
    ('watch',     '시계/악세서리',      Icons.watch_outlined),
    ('camera',    '카메라',             Icons.camera_alt_outlined),
    ('umbrella',  '우산',               Icons.umbrella_outlined),
    ('item',      '기타',               Icons.category_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 0.85,
      children: _categories.map((cat) {
        final (key, label, icon) = cat;
        final isSelected = selected == key;
        return GestureDetector(
          onTap: () => onSelected(key),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : const Color(0xFFF5F9FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.primary : const Color(0xFFD6E6FF),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 26,
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 10,
                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
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
          hasPhoto ? Icons.check_circle_outline_rounded : Icons.add_a_photo_outlined,
          size: 48,
          color: hasPhoto ? AppColors.primary : AppColors.textTertiary,
        ),
        const SizedBox(height: 10),
        Text(
          hasPhoto ? '사진 선택됨' : '탭하여 사진 추가',
          style: AppTextStyles.caption.copyWith(
            color: hasPhoto ? AppColors.primary : AppColors.textTertiary,
          ),
        ),
        if (!hasPhoto) ...[
          const SizedBox(height: 4),
          Text(
            '카메라 촬영 또는 갤러리 선택',
            style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
          ),
        ],
      ],
    );
  }
}
