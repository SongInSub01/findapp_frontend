import 'package:flutter/material.dart';
import 'package:my_flutter_starter/frontend/common/theme/app_colors.dart';
import 'package:my_flutter_starter/frontend/frontend_scope.dart';

import 'package:my_flutter_starter/frontend/pages/reward/reward_shop_page.dart';
import 'package:my_flutter_starter/frontend/pages/reward/reward_benefit_page.dart';
import 'package:my_flutter_starter/frontend/pages/reward/reward_success_dialog.dart';

class RewardPage extends StatefulWidget {
  const RewardPage({super.key});

  @override
  State<RewardPage> createState() =>
      _RewardPageState();
}

class _RewardPageState
    extends State<RewardPage> {

  /// 현재 포인트
  int currentPoints = 2500;

  /// 진행도
  final double progress = 0.7;

  /// 퀘스트
  late List<Map<String, dynamic>> quests;

  @override
  void initState() {
    super.initState();

    quests = [

      {
        'title': '주변 분실물 3개 확인하기',
        'rewardMoney': 5000,
        'completed': false,
        'icon': Icons.search,
        'progress': '3 / 5',
      },

      {
        'title': '습득물 등록하기',
        'rewardMoney': 3000,
        'completed': false,
        'icon': Icons.camera_alt,
        'progress': '1 / 3',
      },

      {
        'title': '채팅 응답하기',
        'rewardMoney': 10000,
        'completed': true,
        'icon': Icons.chat,
        'progress': '완료',
      },
    ];
  }

  @override
  Widget build(BuildContext context) {

    /// 사용자 정보
    final state =
        AppScope.controllerOf(context)
            .state;

    final userProfile =
        state.userProfile;

    final userName =
        userProfile.name.isNotEmpty
            ? userProfile.name
            : '사용자';

    return Scaffold(
      backgroundColor:
          const Color(0xFFF5F7FB),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        title: const Text(
          '리워드',

          style: TextStyle(
            color: Colors.black,
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [

            /// =========================
            /// 상단 카드
            /// =========================

            Container(
              margin:
                  const EdgeInsets.all(20),

              padding:
                  const EdgeInsets.all(24),

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

                  begin:
                      Alignment.topLeft,

                  end:
                      Alignment.bottomRight,
                ),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black
                        .withOpacity(0.12),

                    blurRadius: 14,

                    offset:
                        const Offset(0, 8),
                  ),
                ],
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                children: [

                  /// 사용자
                  Row(
                    children: [

                      const CircleAvatar(
                        radius: 30,

                        backgroundColor:
                            Colors.white24,

                        child: Icon(
                          Icons.person,
                          color:
                              Colors.white,
                          size: 30,
                        ),
                      ),

                      const SizedBox(
                        width: 16,
                      ),

                      Expanded(
                        child: Text(
                          '$userName님',

                          style:
                              const TextStyle(
                            color:
                                Colors.white,

                            fontWeight:
                                FontWeight
                                    .bold,

                            fontSize: 24,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 30,
                  ),

                  const Text(
                    '보유 포인트',

                    style: TextStyle(
                      color:
                          Colors.white60,
                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  Text(
                    '$currentPoints P',

                    style: const TextStyle(
                      color: Colors.amber,

                      fontWeight:
                          FontWeight.bold,

                      fontSize: 40,
                    ),
                  ),

                  const SizedBox(
                    height: 24,
                  ),

                  const Row(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .spaceBetween,

                    children: [

                      Text(
                        '다음 보상까지',

                        style: TextStyle(
                          color:
                              Colors.white70,
                        ),
                      ),

                      Text(
                        '2500 / 3500 P',

                        style: TextStyle(
                          color:
                              Colors.white70,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(
                      20,
                    ),

                    child:
                        LinearProgressIndicator(
                      value: progress,

                      minHeight: 10,

                      backgroundColor:
                          Colors.white24,

                      valueColor:
                          const AlwaysStoppedAnimation(
                        Colors.amber,
                      ),
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
                      color: Colors.orange
                          .withOpacity(
                        0.15,
                      ),

                      borderRadius:
                          BorderRadius.circular(
                        14,
                      ),
                    ),

                    child: const Row(
                      children: [

                        Icon(
                          Icons
                              .local_fire_department,

                          color:
                              Colors.orange,
                        ),

                        SizedBox(width: 8),

                        Text(
                          '5일 연속 활동 중 🔥',

                          style: TextStyle(
                            color:
                                Colors.white,

                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            /// =========================
            /// 액션 버튼
            /// =========================

            Padding(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 20,
              ),

              child: Row(
                children: [

                  /// 포인트 상점
                  Expanded(
                    child:
                        GestureDetector(
                      onTap: () {

                        Navigator.push(
                          context,

                          MaterialPageRoute(
                            builder: (_) =>
                                const RewardShopPage(),
                          ),
                        );
                      },

                      child: _ActionCard(
                        icon: Icons.store,
                        title:
                            '포인트 상점',

                        color:
                            Colors.blue,
                      ),
                    ),
                  ),

                  const SizedBox(
                    width: 16,
                  ),

                  /// 등급 혜택
                  Expanded(
                    child:
                        GestureDetector(
                      onTap: () {

                        Navigator.push(
                          context,

                          MaterialPageRoute(
                            builder: (_) =>
                                const RewardBenefitPage(),
                          ),
                        );
                      },

                      child: _ActionCard(
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

            /// =========================
            /// 퀘스트
            /// =========================

            _buildSectionTitle(
              '오늘의 퀘스트',
            ),

            const SizedBox(height: 14),

            ListView.builder(
              itemCount: quests.length,

              shrinkWrap: true,

              physics:
                  const NeverScrollableScrollPhysics(),

              itemBuilder:
                  (context, index) {

                final quest =
                    quests[index];

                final completed =
                    quest['completed']
                        as bool;

                final int rewardMoney =
                    quest['rewardMoney'];

                final int rewardPoint =
                    (rewardMoney * 0.03)
                        .toInt();

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
                        backgroundColor:
                            completed
                                ? Colors
                                    .green
                                    .shade100
                                : AppColors
                                    .primary
                                    .withOpacity(
                                      0.1,
                                    ),

                        child: Icon(
                          completed
                              ? Icons.check
                              : quest['icon']
                                  as IconData,

                          color:
                              completed
                                  ? Colors.green
                                  : AppColors
                                      .primary,
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
                              quest['title']
                                  as String,

                              style:
                                  TextStyle(
                                fontWeight:
                                    FontWeight
                                        .bold,

                                decoration:
                                    completed
                                        ? TextDecoration
                                            .lineThrough
                                        : null,
                              ),
                            ),

                            const SizedBox(
                              height: 6,
                            ),

                            Text(
                              completed
                                  ? '리워드 지급 완료'
                                  : '${quest['progress']} · ${rewardPoint}P 예정',

                              style:
                                  TextStyle(
                                color: Colors
                                    .grey
                                    .shade600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      completed
                          ? const Text(
                              '완료',

                              style:
                                  TextStyle(
                                color:
                                    Colors.green,

                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            )

                          : ElevatedButton(
                              onPressed:
                                  () {

                                setState(
                                  () {

                                    currentPoints +=
                                        rewardPoint;

                                    quest['completed'] =
                                        true;
                                  },
                                );

                                showDialog(
                                  context:
                                      context,

                                  builder:
                                      (_) {

                                    return RewardSuccessDialog(
                                      rewardMoney:
                                          rewardMoney,
                                    );
                                  },
                                );
                              },

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

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(
    String title,
  ) {

    return Padding(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 20,
      ),

      child: Align(
        alignment:
            Alignment.centerLeft,

        child: Text(
          title,

          style: const TextStyle(
            fontSize: 20,
            fontWeight:
                FontWeight.bold,
          ),
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

            style: const TextStyle(
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}