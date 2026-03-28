import 'package:flutter/material.dart';

import 'package:my_flutter_starter/app/state/app_controller.dart';
import 'package:my_flutter_starter/data/models/app_models.dart';
import 'package:my_flutter_starter/frontend/common/panels/app_panel_helpers.dart';
import 'package:my_flutter_starter/frontend/common/panels/app_panel_scaffold.dart';
import 'package:my_flutter_starter/frontend/common/resources/app_assets.dart';
import 'package:my_flutter_starter/frontend/common/theme/app_text_styles.dart';
import 'package:my_flutter_starter/frontend/common/widgets/app_buttons.dart';
import 'package:my_flutter_starter/frontend/common/widgets/app_text_field.dart';

Future<void> showProfileEditorPanel(
  BuildContext context, {
  required AppController controller,
  required UserProfile profile,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => _ProfileEditorPanel(
      controller: controller,
      profile: profile,
    ),
  );
}

class _ProfileEditorPanel extends StatefulWidget {
  const _ProfileEditorPanel({
    required this.controller,
    required this.profile,
  });

  final AppController controller;
  final UserProfile profile;

  @override
  State<_ProfileEditorPanel> createState() => _ProfileEditorPanelState();
}

class _ProfileEditorPanelState extends State<_ProfileEditorPanel> {
  late final TextEditingController _nameController;
  late final TextEditingController _publicNameController;
  late final TextEditingController _emailController;
  late String _selectedPhotoAsset;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _publicNameController = TextEditingController(text: widget.profile.publicName);
    _emailController = TextEditingController(text: widget.profile.email);
    _selectedPhotoAsset = widget.profile.photoAssetPath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _publicNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppPanelScaffold(
      title: '프로필 등록',
      subtitle: '실명, 공개 이름, 연락 이메일과 대표 이미지를 수정합니다.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: CircleAvatar(
              radius: 32,
              backgroundColor: const Color(0xFFEFF6FF),
              backgroundImage: AssetImage(_selectedPhotoAsset),
            ),
          ),
          const SizedBox(height: 16),
          AppTextField(controller: _nameController, label: '이름'),
          const SizedBox(height: 12),
          AppTextField(controller: _publicNameController, label: '공개 이름'),
          const SizedBox(height: 12),
          AppTextField(
            controller: _emailController,
            label: '이메일',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          Text(
            '대표 사진 선택',
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          AssetOptionSelector(
            options: AppAssets.profilePhotos,
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
                    setState(() => _isSaving = true);
                    try {
                      await widget.controller.updateProfile(
                        name: _nameController.text.trim().isEmpty
                            ? widget.profile.name
                            : _nameController.text.trim(),
                        email: _emailController.text.trim().isEmpty
                            ? widget.profile.email
                            : _emailController.text.trim(),
                        publicName: _publicNameController.text.trim().isEmpty
                            ? widget.profile.publicName
                            : _publicNameController.text.trim(),
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
