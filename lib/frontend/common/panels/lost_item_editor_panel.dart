import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

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
  bool _isResolvingLocation = false;
  double? _latitude;
  double? _longitude;
  double? _accuracyMeters;

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
      subtitle: '분실 위치와 설명을 입력하면 지도와 검색 화면에 바로 반영됩니다.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTextField(controller: _titleController, label: '분실물 이름'),
          const SizedBox(height: 12),
          AppTextField(controller: _locationController, label: '분실 장소'),
          const SizedBox(height: 12),
          AppSecondaryButton(
            label: _latitude == null ? '현재 위치 사용' : '현재 위치 적용됨',
            icon: Icons.my_location_outlined,
            expanded: true,
            onPressed: _isResolvingLocation ? null : _captureCurrentLocation,
          ),
          if (_latitude != null && _longitude != null) ...[
            const SizedBox(height: 6),
            Text(
              '${_latitude!.toStringAsFixed(6)}, '
              '${_longitude!.toStringAsFixed(6)}',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
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
            hintText: '색상, 특징, 마지막으로 확인한 장소를 적어주세요.',
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
              '사진은 기본 비공개 상태로 등록되며, 주인이 승인한 뒤에만 열람됩니다.',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 18),
          AppPrimaryButton(
            label: _isSaving ? '등록 중...' : '등록',
            expanded: true,
            onPressed: _isSaving ? null : _save,
          ),
        ],
      ),
    );
  }

  Future<void> _captureCurrentLocation() async {
    setState(() => _isResolvingLocation = true);
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception('위치 권한이 필요합니다.');
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _accuracyMeters = position.accuracy;
        if (_locationController.text.trim().isEmpty) {
          _locationController.text = '현재 위치';
        }
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isResolvingLocation = false);
      }
    }
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    final location = _locationController.text.trim();
    final reward =
        int.tryParse(_rewardController.text.replaceAll(',', '')) ?? 30000;
    if (title.isEmpty || location.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('분실물 이름과 장소를 입력해 주세요.')));
      return;
    }

    setState(() => _isSaving = true);
    try {
      await widget.controller.saveLostItem(
        title: title,
        location: location,
        reward: reward,
        description: _descriptionController.text.trim().isEmpty
            ? '앱에서 등록한 분실물입니다.'
            : _descriptionController.text.trim(),
        photoAssetPath: _selectedPhotoAsset,
        latitude: _latitude,
        longitude: _longitude,
        accuracyMeters: _accuracyMeters,
      );
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) {
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
  }
}
