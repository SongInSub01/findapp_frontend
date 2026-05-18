import 'package:flutter/material.dart';

import 'package:my_flutter_starter/frontend/common/theme/app_colors.dart';
import 'package:my_flutter_starter/frontend/frontend_scope.dart';

import 'package:my_flutter_starter/frontend/pages/reward/reward_benefit_page.dart';
import 'package:my_flutter_starter/frontend/pages/reward/reward_shop_page.dart';
import 'package:my_flutter_starter/frontend/pages/reward/reward_success_dialog.dart';

import 'package:my_flutter_starter/frontend/pages/reward/reward_model.dart';
import 'package:my_flutter_starter/frontend/pages/reward/reward_api.dart';

class RewardPage extends StatefulWidget {
  const RewardPage({super.key});

  @override
  State<RewardPage> createState() =>
      _RewardPageState();
}

class _RewardPageState
    extends State<RewardPage> {

  RewardStatus? rewardStatus;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance
        .addPostFrameCallback((_) {

      loadReward();
    });
  }

  Future<void> loadReward() async {

    try {

      final state =
          AppScope.controllerOf(context)
              .state;

      final email =
          state.userProfile.email;

      print('현재 이메일: $email');

      final json =
          await RewardApi.getRewardStatus(
        email: email,
      );

      print('리워드 응답: $json');

      setState(() {

        rewardStatus =
            RewardStatus.fromJson(json);

        isLoading = false;
      });

    } catch (e, stackTrace) {

      print('리워드 에러 발생');
      print(e);
      print(stackTrace);

      setState(() {
        isLoading = false;
      });
    }
  }

  IconData getQuestIcon(
    String iconKey,
  ) {

    switch (iconKey) {

      case 'search':
        return Icons.search;

      case 'camera':
        return Icons.camera_alt;

      case 'chat':
        return Icons.chat;

      default:
        return Icons.card_giftcard;
    }
  }

  @override
  Widget build(BuildContext context) {

    final state =
        AppScope.controllerOf(context)
            .state;

    final userName =
        state.userProfile.name;

    if (isLoading) {
      return const Scaffold(
        body: Center(
          child:
              CircularProgressIndicator(),
        ),
      );
    }

    if (rewardStatus == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            '리워드를 불러오지 못했습니다.',
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor:
          const Color(0xFFF5F7FB),

      appBar: AppBar(
        title: const Text('리워드'),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [

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
                    const LinearGradient(
                  colors: [
                    Color(0xFF1E293B),
                    Color(0xFF0F172A),
                  ],
                ),
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                children: [

                  Text(
                    '$userName님',

                    style:
                        const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 24,
                  ),

                  const Text(
                    '보유 포인트',

                    style: TextStyle(
                      color:
                          Colors.white70,
                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  Text(
                    '${rewardStatus!.currentPoints} P',

                    style:
                        const TextStyle(
                      color: Colors.amber,
                      fontSize: 40,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  LinearProgressIndicator(
                    value:
                        rewardStatus!
                            .progress,
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  Text(
                    '${rewardStatus!.streakDays}일 연속 활동 중 🔥',

                    style:
                        const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 20,
              ),

              child: Row(
                children: [

                  Expanded(
                    child: GestureDetector(
                      onTap: () {

                        Navigator.push(
                          context,

                          MaterialPageRoute(
                            builder:
                                (_) =>
                                    RewardShopPage(
                              rewardStatus:
                                  rewardStatus!,
                            ),
                          ),
                        );
                      },

                      child: const _ActionCard(
                        icon: Icons.store,
                        title:
                            '포인트 상점',
                        color: Colors.blue,
                      ),
                    ),
                  ),

                  const SizedBox(
                    width: 16,
                  ),

                  Expanded(
                    child: GestureDetector(
                      onTap: () {

                        Navigator.push(
                          context,

                          MaterialPageRoute(
                            builder:
                                (_) =>
                                    RewardBenefitPage(
                              benefits:
                                  rewardStatus!
                                      .benefits,
                            ),
                          ),
                        );
                      },

                      child: const _ActionCard(
                        icon:
                            Icons.emoji_events,
                        title:
                            '등급 혜택',
                        color:
                            Colors.orange,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            ListView.builder(
              itemCount:
                  rewardStatus!
                      .quests
                      .length,

              shrinkWrap: true,

              physics:
                  const NeverScrollableScrollPhysics(),

              itemBuilder:
                  (context, index) {

                final quest =
                    rewardStatus!
                        .quests[index];

                return Container(
                  margin:
                      const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
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
                      20,
                    ),
                  ),

                  child: Row(
                    children: [

                      CircleAvatar(
                        child: Icon(
                          getQuestIcon(
                            quest.iconKey,
                          ),
                        ),
                      ),

                      const SizedBox(
                        width: 14,
                      ),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,

                          children: [

                            Text(
                              quest.title,
                            ),

                            const SizedBox(
                              height: 6,
                            ),

                            Text(
                              quest.progressLabel,
                            ),
                          ],
                        ),
                      ),

                      quest.claimed

                          ? const Text(
                              '수령 완료',
                            )

                          : ElevatedButton(
                              onPressed:
                                  quest
                                          .completed
                                      ? () async {

                                          try {

                                            final state =
                                                AppScope.controllerOf(
                                                  context,
                                                ).state;

                                            final email =
                                                state
                                                    .userProfile
                                                    .email;

                                            final json =
                                                await RewardApi.claimQuest(
                                              email:
                                                  email,

                                              questCode:
                                                  quest.code,
                                            );

                                            setState(
                                              () {

                                                rewardStatus =
                                                    RewardStatus.fromJson(
                                                  json,
                                                );
                                              },
                                            );

                                            showDialog(
                                              context:
                                                  context,

                                              builder:
                                                  (_) {

                                                return RewardSuccessDialog(
                                                  rewardPoint:
                                                      quest.rewardPoints,
                                                );
                                              },
                                            );
                                          } catch (
                                            e
                                          ) {

                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content:
                                                    Text(
                                                  e.toString(),
                                                ),
                                              ),
                                            );
                                          }
                                        }

                                      : null,

                              style:
                                  ElevatedButton.styleFrom(
                                backgroundColor:
                                    AppColors
                                        .primary,
                              ),

                              child:
                                  const Text(
                                '리워드 받기',
                              ),
                            ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard
    extends StatelessWidget {

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.color,
  });

  final IconData icon;
  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {

    return Container(
      padding:
          const EdgeInsets.symmetric(
        vertical: 24,
      ),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(
          22,
        ),
      ),

      child: Column(
        children: [

          CircleAvatar(
            radius: 28,

            backgroundColor:
                color.withOpacity(
              0.12,
            ),

            child: Icon(
              icon,
              color: color,
              size: 30,
            ),
          ),

          const SizedBox(
            height: 14,
          ),

          Text(
            title,
          ),
        ],
      ),
    );
  }
}