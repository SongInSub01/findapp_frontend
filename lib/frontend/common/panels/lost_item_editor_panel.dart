import 'package:flutter/material.dart';

import 'package:my_flutter_starter/app/state/app_controller.dart';
import 'package:my_flutter_starter/frontend/common/panels/app_panel_helpers.dart';
import 'package:my_flutter_starter/frontend/common/panels/app_panel_scaffold.dart';
import 'package:my_flutter_starter/frontend/common/resources/app_assets.dart';
import 'package:my_flutter_starter/frontend/common/theme/app_colors.dart';
import 'package:my_flutter_starter/frontend/common/theme/app_text_styles.dart';
import 'package:my_flutter_starter/frontend/common/widgets/app_buttons.dart';
import 'package:my_flutter_starter/frontend/common/widgets/app_text_field.dart';

import 'package:my_flutter_starter/frontend/pages/map/map_select_page.dart';

Future<void> showLostItemEditorPanel(
  BuildContext context, {
  required AppController controller,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: Colors.transparent,

    builder: (context) =>
        _LostItemEditorPanel(
          controller: controller,
        ),
  );
}

class _LostItemEditorPanel
    extends StatefulWidget {
  const _LostItemEditorPanel({
    required this.controller,
  });

  final AppController controller;

  @override
  State<_LostItemEditorPanel>
  createState() =>
      _LostItemEditorPanelState();
}

class _LostItemEditorPanelState
    extends State<_LostItemEditorPanel> {
  final TextEditingController
  _titleController =
      TextEditingController();

  final TextEditingController
  _descriptionController =
      TextEditingController();

  final TextEditingController
  _rewardController =
      TextEditingController();

  String _selectedPhotoAsset =
      AppAssets.splashIcon;

  bool _isSaving = false;

  String _selectedLocation =
      '';

  double? _latitude;
  double? _longitude;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _rewardController.dispose();

    super.dispose();
  }

  Future<void> _selectLocation() async {
    final result = await Navigator.push(
      context,

      MaterialPageRoute(
        builder: (_) =>
            const MapSelectPage(),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedLocation =
            result['address'];

        _latitude = result['lat'];
        _longitude = result['lng'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppPanelScaffold(
      title: '분실물 등록',

      subtitle:
          '분실물 정보를 입력해 주세요.',

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          /// 사진 선택
          Text(
            '대표 이미지',

            style: AppTextStyles.body
                .copyWith(
                  fontWeight:
                      FontWeight.w700,
                ),
          ),

          const SizedBox(height: 10),

          AssetOptionSelector(
            options:
                AppAssets.lostItemPhotos,

            selectedAsset:
                _selectedPhotoAsset,

            onSelected: (asset) {
              setState(() {
                _selectedPhotoAsset =
                    asset;
              });
            },
          ),

          const SizedBox(height: 20),

          /// 분실물 이름
          AppTextField(
            controller:
                _titleController,

            label: '분실물 이름',

            hintText:
                '예: 에어팟 프로',
          ),

          const SizedBox(height: 16),

          /// 위치 선택
          Text(
            '분실 위치',

            style: AppTextStyles.body
                .copyWith(
                  fontWeight:
                      FontWeight.w700,
                ),
          ),

          const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            height: 54,

            child: OutlinedButton.icon(
              onPressed:
                  _selectLocation,

              icon: const Icon(
                Icons
                    .location_on_outlined,
              ),

              label: Text(
                _selectedLocation
                        .isEmpty
                    ? '위치 선택하기'
                    : '위치 다시 선택',
              ),

              style:
                  OutlinedButton.styleFrom(
                    foregroundColor:
                        const Color(
                          0xFF4A90E2,
                        ),

                    side:
                        const BorderSide(
                          color: Color(
                            0xFFD6E6FF,
                          ),
                        ),

                    shape:
                        RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                                16,
                              ),
                        ),
                  ),
            ),
          ),

          if (_selectedLocation
              .isNotEmpty) ...[
            const SizedBox(height: 10),

            Container(
              width: double.infinity,

              padding:
                  const EdgeInsets.all(
                    14,
                  ),

              decoration: BoxDecoration(
                color: const Color(
                  0xFFF5F9FF,
                ),

                borderRadius:
                    BorderRadius.circular(
                      16,
                    ),
              ),

              child: Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 18,
                    color: Color(
                      0xFF4A90E2,
                    ),
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: Text(
                      _selectedLocation,

                      style:
                          AppTextStyles
                              .body,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),

          /// 설명
          AppTextField(
            controller:
                _descriptionController,

            label: '상세 설명',

            maxLines: 4,

            hintText:
                '색상, 특징, 마지막으로 본 장소 등을 입력해 주세요.',
          ),

          const SizedBox(height: 16),

          /// 사례금
          AppTextField(
            controller:
                _rewardController,

            label: '사례금 (선택)',

            hintText:
                '예: 30000',

            keyboardType:
                TextInputType.number,
          ),

          const SizedBox(height: 16),

          /// 보호 안내
          Container(
            width: double.infinity,

            padding:
                const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),

            decoration: BoxDecoration(
              color: const Color(
                0xFFF5F9FF,
              ),

              borderRadius:
                  BorderRadius.circular(
                    16,
                  ),
            ),

            child: Row(
              children: [
                const Icon(
                  Icons.shield_outlined,
                  size: 18,
                  color: Color(
                    0xFF4A90E2,
                  ),
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: Text(
                    '승인 전까지 사진은 보호됩니다.',

                    style: AppTextStyles
                        .caption
                        .copyWith(
                          color:
                              const Color(
                                0xFF4A90E2,
                              ),

                          fontWeight:
                              FontWeight
                                  .w700,
                        ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          /// 등록 버튼
          AppPrimaryButton(
            label:
                _isSaving
                ? '등록 중...'
                : '분실물 등록하기',

            expanded: true,

            onPressed:
                _isSaving
                ? null
                : () async {
                    final title =
                        _titleController
                            .text
                            .trim();

                    final reward =
                        int.tryParse(
                          _rewardController
                              .text
                              .replaceAll(
                                ',',
                                '',
                              ),
                        ) ??
                        0;

                    if (title.isEmpty) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        const SnackBar(
                          content: Text(
                            '분실물 이름을 입력해 주세요.',
                          ),
                        ),
                      );

                      return;
                    }

                    if (_selectedLocation
                        .isEmpty) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        const SnackBar(
                          content: Text(
                            '분실 위치를 선택해 주세요.',
                          ),
                        ),
                      );

                      return;
                    }

                    setState(() {
                      _isSaving = true;
                    });

                    try {
                      await widget
                          .controller
                          .saveLostItem(
                            title: title,

                            location:
                                _selectedLocation,

                            reward:
                                reward,

                            description:
                                _descriptionController
                                        .text
                                        .trim()
                                        .isEmpty
                                ? 'BLE 감지 후 등록된 분실물입니다.'
                                : _descriptionController
                                      .text
                                      .trim(),

                            photoAssetPath:
                                _selectedPhotoAsset,
                          );

                      if (!context
                          .mounted) {
                        return;
                      }

                      Navigator.of(
                        context,
                      ).pop();
                    } catch (error) {
                      if (!context
                          .mounted) {
                        return;
                      }

                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        SnackBar(
                          content: Text(
                            error
                                .toString()
                                .replaceFirst(
                                  'Exception: ',
                                  '',
                                ),
                          ),
                        ),
                      );
                    } finally {
                      if (mounted) {
                        setState(() {
                          _isSaving =
                              false;
                        });
                      }
                    }
                  },
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}