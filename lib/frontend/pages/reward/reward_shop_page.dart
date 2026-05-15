import 'package:flutter/material.dart';
import 'package:my_flutter_starter/frontend/common/theme/app_colors.dart';

class RewardShopPage extends StatelessWidget {
  const RewardShopPage({super.key});

  @override
  Widget build(BuildContext context) {

    /// 현재 보유 포인트
    const int currentPoint = 1850;

    /// 상점 아이템
    final items = [

      {
        'title': '커피 쿠폰',
        'desc': '스타벅스 아메리카노 교환권',
        'price': '1500P',
        'icon': Icons.local_cafe,
      },

      {
        'title': '편의점 상품권',
        'desc': '5,000원 모바일 상품권',
        'price': '3000P',
        'icon': Icons.store,
      },

      {
        'title': '배달 할인 쿠폰',
        'desc': '배달앱 할인 쿠폰',
        'price': '2500P',
        'icon': Icons.delivery_dining,
      },

      {
        'title': '포인트 부스터',
        'desc': '7일 동안 포인트 2배 적립',
        'price': '1200P',
        'icon': Icons.flash_on,
      },

      {
        'title': '프리미엄 프로필',
        'desc': '프로필 테두리 변경',
        'price': '800P',
        'icon': Icons.workspace_premium,
      },

      {
        'title': '닉네임 컬러 변경',
        'desc': '닉네임 색상 커스텀',
        'price': '600P',
        'icon': Icons.palette,
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

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
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Column(
        children: [

          /// =========================
          /// 포인트 카드
          /// =========================

          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(24),

            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(28),

              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primary
                      .withOpacity(0.85),
                ],
              ),
            ),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                const Text(
                  '현재 보유 포인트',

                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  '$currentPoint P',

                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 18),

                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),

                  decoration: BoxDecoration(
                    color: Colors.white24,

                    borderRadius:
                        BorderRadius.circular(
                      14,
                    ),
                  ),

                  child: const Text(
                    '분실물 반환 성공 시 사례금의 일부가 포인트로 적립됩니다.',

                    style: TextStyle(
                      color: Colors.white,
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

              itemCount: items.length,

              itemBuilder: (context, index) {

                final item = items[index];

                return Container(
                  margin:
                      const EdgeInsets.only(
                    bottom: 16,
                  ),

                  padding:
                      const EdgeInsets.all(18),

                  decoration: BoxDecoration(
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
                            AppColors.primary
                                .withOpacity(
                              0.12,
                            ),

                        child: Icon(
                          item['icon']
                              as IconData,

                          color:
                              AppColors.primary,

                          size: 30,
                        ),
                      ),

                      const SizedBox(width: 16),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,

                          children: [

                            Text(
                              item['title']
                                  as String,

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
                              item['desc']
                                  as String,

                              style: TextStyle(
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
                              item['price']
                                  as String,

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

                      ElevatedButton(
                        onPressed: () {

                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(

                            SnackBar(
                              content: Text(
                                '${item['title']} 구매 완료!',
                              ),
                            ),
                          );
                        },

                        style:
                            ElevatedButton
                                .styleFrom(
                          backgroundColor:
                              AppColors.primary,

                          padding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal: 18,
                            vertical: 12,
                          ),

                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(
                              14,
                            ),
                          ),
                        ),

                        child: const Text(
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