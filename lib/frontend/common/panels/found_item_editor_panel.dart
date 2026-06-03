import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'package:my_flutter_starter/app/state/app_controller.dart';
import 'package:my_flutter_starter/frontend/common/resources/app_assets.dart';
import 'package:my_flutter_starter/frontend/common/theme/app_colors.dart';
import 'package:my_flutter_starter/frontend/common/theme/app_text_styles.dart';
import 'package:my_flutter_starter/frontend/common/widgets/app_buttons.dart';
import 'package:my_flutter_starter/frontend/common/widgets/app_text_field.dart';

Future<void> showFoundItemEditorPanel(
  BuildContext context, {
  required AppController controller,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => _FoundItemEditorPanel(controller: controller),
  );
}

class _FoundItemEditorPanel extends StatefulWidget {
  const _FoundItemEditorPanel({required this.controller});

  final AppController controller;

  @override
  State<_FoundItemEditorPanel> createState() => _FoundItemEditorPanelState();
}

class _FoundItemEditorPanelState extends State<_FoundItemEditorPanel> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isSaving = false;
  bool _isResolvingLocation = false;
  double? _latitude;
  double? _longitude;
  double? _accuracyMeters;

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        8,
        20,
        MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('습득물 등록', style: AppTextStyles.title),
          const SizedBox(height: 12),
          AppTextField(controller: _titleController, label: '습득물 이름'),
          const SizedBox(height: 10),
          AppTextField(controller: _locationController, label: '습득 위치'),
          const SizedBox(height: 10),
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
          const SizedBox(height: 10),
          AppTextField(controller: _descriptionController, label: '특징'),
          const SizedBox(height: 16),
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
    if (title.isEmpty || location.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('이름과 위치를 입력해 주세요.')));
      return;
    }

    setState(() => _isSaving = true);
    try {
      await widget.controller.saveFoundItem(
        title: title,
        location: location,
        description: _descriptionController.text.trim(),
        photoAssetPath: AppAssets.icon,
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
