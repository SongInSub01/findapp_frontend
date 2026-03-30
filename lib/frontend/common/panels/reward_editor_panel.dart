import 'package:flutter/material.dart';

import 'package:my_flutter_starter/app/state/app_controller.dart';
import 'package:my_flutter_starter/core/utils/formatters.dart';
import 'package:my_flutter_starter/data/models/app_models.dart';
import 'package:my_flutter_starter/frontend/common/panels/app_panel_scaffold.dart';
import 'package:my_flutter_starter/frontend/common/theme/app_colors.dart';
import 'package:my_flutter_starter/frontend/common/theme/app_text_styles.dart';
import 'package:my_flutter_starter/frontend/common/widgets/app_buttons.dart';
import 'package:my_flutter_starter/frontend/common/widgets/app_text_field.dart';

Future<void> showRewardEditorPanel(
  BuildContext context, {
  required AppController controller,
  required AppState state,
  String? initialItemId,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => _RewardEditorPanel(
      controller: controller,
      state: state,
      initialItemId: initialItemId,
    ),
  );
}

class _RewardEditorPanel extends StatefulWidget {
  const _RewardEditorPanel({
    required this.controller,
    required this.state,
    this.initialItemId,
  });

  final AppController controller;
  final AppState state;
  final String? initialItemId;

  @override
  State<_RewardEditorPanel> createState() => _RewardEditorPanelState();
}

class _RewardEditorPanelState extends State<_RewardEditorPanel> {
  late final TextEditingController _rewardController;
  late String _selectedItemId;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final initialItem = widget.state.lostItems.firstWhere(
      (item) => item.id == widget.initialItemId,
      orElse: () => widget.state.lostItems.first,
    );
    _selectedItemId = initialItem.id;
    _rewardController = TextEditingController(text: initialItem.reward.toString());
  }

  @override
  void dispose() {
    _rewardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedItem = widget.state.lostItems.firstWhere((item) => item.id == _selectedItemId);
    return AppPanelScaffold(
      title: '사례금 등록',
      subtitle: '분실물별 사례금을 조정하고 채팅 화면에도 동일하게 반영합니다.',
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            initialValue: _selectedItemId,
            decoration: const InputDecoration(labelText: '대상 분실물'),
            items: [
              for (final item in widget.state.lostItems)
                DropdownMenuItem(value: item.id, child: Text(item.title)),
            ],
            onChanged: (value) {
              if (value == null) {
                return;
              }
              final item = widget.state.lostItems.firstWhere((entry) => entry.id == value);
              setState(() {
                _selectedItemId = value;
                _rewardController.text = item.reward.toString();
              });
            },
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: _rewardController,
            label: '사례금',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '현재 ${selectedItem.title} 사례금: ${Formatters.money(selectedItem.reward)}',
              style: AppTextStyles.caption.copyWith(color: AppColors.primary),
            ),
          ),
          const SizedBox(height: 18),
          AppPrimaryButton(
            label: _isSaving ? '저장 중...' : '저장',
            expanded: true,
            onPressed: _isSaving
                ? null
                : () async {
                    final reward = int.tryParse(_rewardController.text.replaceAll(',', ''));
                    if (reward == null) {
                      return;
                    }
                    setState(() => _isSaving = true);
                    try {
                      await widget.controller.updateReward(_selectedItemId, reward);
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
