import 'package:flutter/material.dart';

import 'package:my_flutter_starter/frontend/common/theme/app_colors.dart';
import 'package:my_flutter_starter/frontend/frontend_scope.dart';

import 'reward_model.dart';
import 'reward_api.dart';

class RewardShopPage extends StatefulWidget {

  const RewardShopPage({
    super.key,
    required this.rewardStatus,
  });

  final RewardStatus rewardStatus;

  @override
  State<RewardShopPage> createState() =>
      _RewardShopPageState();
}

class _RewardShopPageState
    extends State<RewardShopPage> {

  late RewardStatus rewardStatus;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    rewardStatus = widget.rewardStatus;
  }

  IconData getItemIcon(
    String iconKey,
  ) {

    switch (iconKey) {

      case 'coffee':
        return Icons.local_cafe;

      case 'store':
        return Icons.store;

      case 'delivery':
        return Icons.delivery_dining;

      case 'flash':
        return Icons.flash_on;

      case 'premium':
        return Icons.workspace_premium;

      case 'palette':
        return Icons.palette;

      default:
        return Icons.card_giftcard;
    }
  }

  Future<void> purchaseItem(
    RewardShopItem item,
  ) async {

    try {

      setState(() {
        isLoading = true;
      });

      final state =
          AppScope.controllerOf(context)
              .state;

      final email =
          state.userProfile.email;

      final json =
          await RewardApi.purchaseItem(
        email: email,
        itemId: item.id,
      );

      setState(() {

        rewardStatus =
            RewardStatus.fromJson(
          json,
        );

        isLoading = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(
          content: Text(
            '${item.title} 구매 완료!',
          ),
        ),
      );
    } catch (e) {

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor:
          const Color(0xFFF5F7FB),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        iconTheme:
            const IconThemeData(
          color: Colors.black,
        ),

        title: const Text(
          '리워드 상점',

          style: TextStyle(
            color: Colors.black,
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),

      body: Column(
        children: [

          /// =========================
          /// 포인트 카드
          /// =========================

          Container(
            margin:
                const EdgeInsets.all(
              20,
            ),

            padding:
                const EdgeInsets.all(
              24,
            ),

            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(
                28,
              ),

              gradient:
                  LinearGradient(
                colors: [
                  AppColors.primary,

                  AppColors.primary
                      .withOpacity(
                    0.85,
                  ),
                ],
              ),
            ),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

              children: [

                const Text(
                  '현재 보유 포인트',

                  style: TextStyle(
                    color:
                        Colors.white70,

                    fontSize: 15,
                  ),
                ),

                const SizedBox(
                  height: 12,
                ),

                Text(
                  '${rewardStatus.currentPoints} P',

                  style:
                      const TextStyle(
                    color: Colors.white,

                    fontSize: 40,

                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 18,
                ),

                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),

                  decoration:
                      BoxDecoration(
                    color: Colors.white24,

                    borderRadius:
                        BorderRadius.circular(
                      14,
                    ),
                  ),

                  child: const Text(
                    '분실물 반환 성공 시 사례금의 일부가 포인트로 적립됩니다.',

                    style: TextStyle(
                      color:
                          Colors.white,

                      fontWeight:
                          FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// =========================
          /// 상품 리스트
          /// =========================

          Expanded(
            child: ListView.builder(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 20,
              ),

              itemCount:
                  rewardStatus
                      .shopItems
                      .length,

              itemBuilder:
                  (context, index) {

                final item =
                    rewardStatus
                        .shopItems[index];

                return Container(
                  margin:
                      const EdgeInsets.only(
                    bottom: 16,
                  ),

                  padding:
                      const EdgeInsets.all(
                    18,
                  ),

                  decoration:
                      BoxDecoration(
                    color: Colors.white,

                    borderRadius:
                        BorderRadius.circular(
                      24,
                    ),
                  ),

                  child: Row(
                    children: [

                      CircleAvatar(
                        radius: 30,

                        backgroundColor:
                            AppColors
                                .primary
                                .withOpacity(
                          0.12,
                        ),

                        child: Icon(
                          getItemIcon(
                            item.iconKey,
                          ),

                          color:
                              AppColors
                                  .primary,

                          size: 30,
                        ),
                      ),

                      const SizedBox(
                        width: 16,
                      ),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,

                          children: [

                            Text(
                              item.title,

                              style:
                                  const TextStyle(
                                fontWeight:
                                    FontWeight
                                        .bold,

                                fontSize: 16,
                              ),
                            ),

                            const SizedBox(
                              height: 6,
                            ),

                            Text(
                              item.description,

                              style:
                                  TextStyle(
                                color: Colors
                                    .grey
                                    .shade600,

                                fontSize: 13,
                              ),
                            ),

                            const SizedBox(
                              height: 10,
                            ),

                            Text(
                              '${item.pricePoints}P',

                              style:
                                  const TextStyle(
                                color:
                                    Colors.orange,

                                fontWeight:
                                    FontWeight
                                        .bold,

                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),

                      item.purchased

                          ? Container(
                              padding:
                                  const EdgeInsets.symmetric(
                                horizontal:
                                    16,

                                vertical:
                                    10,
                              ),

                              decoration:
                                  BoxDecoration(
                                color:
                                    Colors
                                        .green
                                        .shade100,

                                borderRadius:
                                    BorderRadius.circular(
                                  14,
                                ),
                              ),

                              child: const Text(
                                '구매 완료',

                                style:
                                    TextStyle(
                                  color:
                                      Colors
                                          .green,

                                  fontWeight:
                                      FontWeight
                                          .bold,
                                ),
                              ),
                            )

                          : ElevatedButton(
                              onPressed:
                                  isLoading
                                      ? null
                                      : () {

                                          purchaseItem(
                                            item,
                                          );
                                        },

                              style:
                                  ElevatedButton.styleFrom(
                                backgroundColor:
                                    AppColors
                                        .primary,

                                padding:
                                    const EdgeInsets.symmetric(
                                  horizontal:
                                      18,

                                  vertical:
                                      12,
                                ),

                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(
                                    14,
                                  ),
                                ),
                              ),

                              child:
                                  isLoading

                                      ? const SizedBox(
                                          width:
                                              18,

                                          height:
                                              18,

                                          child:
                                              CircularProgressIndicator(
                                            strokeWidth:
                                                2,

                                            color:
                                                Colors.white,
                                          ),
                                        )

                                      : const Text(
                                          '구매',
                                        ),
                            ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}