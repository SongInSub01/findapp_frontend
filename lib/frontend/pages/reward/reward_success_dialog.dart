import 'package:flutter/material.dart';

import 'package:my_flutter_starter/frontend/common/theme/app_colors.dart';

class RewardSuccessDialog
    extends StatelessWidget {

  const RewardSuccessDialog({
    super.key,
    required this.rewardPoint,
  });

  final int rewardPoint;

  @override
  Widget build(BuildContext context) {

    return Dialog(
      backgroundColor:
          Colors.transparent,

      child: Container(
        padding:
            const EdgeInsets.all(
          28,
        ),

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius:
              BorderRadius.circular(
            28,
          ),
        ),

        child: Column(
          mainAxisSize:
              MainAxisSize.min,

          children: [

            /// =========================
            /// 아이콘
            /// =========================

            Container(
              width: 90,
              height: 90,

              decoration: BoxDecoration(
                shape: BoxShape.circle,

                color: Colors.orange
                    .withOpacity(
                  0.15,
                ),
              ),

              child: const Icon(
                Icons.card_giftcard,

                color: Colors.orange,

                size: 50,
              ),
            ),

            const SizedBox(
              height: 24,
            ),

            /// =========================
            /// 제목
            /// =========================

            const Text(
              '리워드 획득! 🎉',

              style: TextStyle(
                fontSize: 24,

                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            /// =========================
            /// 설명
            /// =========================

            Text(
              '${rewardPoint}P가 지급되었습니다.',

              textAlign:
                  TextAlign.center,

              style: TextStyle(
                color:
                    Colors.grey.shade700,

                fontSize: 15,
              ),
            ),

            const SizedBox(
              height: 26,
            ),

            /// =========================
            /// 포인트 박스
            /// =========================

            Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 14,
              ),

              decoration: BoxDecoration(
                color: Colors.orange
                    .withOpacity(
                  0.12,
                ),

                borderRadius:
                    BorderRadius.circular(
                  18,
                ),
              ),

              child: Text(
                '+${rewardPoint}P',

                style:
                    const TextStyle(
                  color: Colors.orange,

                  fontSize: 32,

                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(
              height: 30,
            ),

            /// =========================
            /// 확인 버튼
            /// =========================

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: () {

                  Navigator.pop(
                    context,
                  );
                },

                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      AppColors.primary,

                  padding:
                      const EdgeInsets.symmetric(
                    vertical: 16,
                  ),

                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      16,
                    ),
                  ),
                ),

                child: const Text(
                  '확인',

                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}