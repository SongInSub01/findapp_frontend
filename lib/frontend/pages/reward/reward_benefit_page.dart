import 'package:flutter/material.dart';

import 'reward_model.dart';

class RewardBenefitPage
    extends StatelessWidget {

  const RewardBenefitPage({
    super.key,
    required this.benefits,
  });

  final List<RewardBenefit> benefits;

  Color getTierColor(
    String tier,
  ) {

    switch (tier) {

      case 'Bronze':
        return const Color(
          0xFFCD7F32,
        );

      case 'Silver':
        return const Color(
          0xFFC0C0C0,
        );

      case 'Gold':
        return const Color(
          0xFFFFD700,
        );

      case 'Master':
        return const Color(
          0xFF6D28D9,
        );

      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor:
          const Color(0xFFF5F7FB),

      appBar: AppBar(
        backgroundColor:
            Colors.white,

        elevation: 0,

        title: const Text(
          '등급별 혜택',

          style: TextStyle(
            color: Colors.black,

            fontWeight:
                FontWeight.bold,
          ),
        ),

        iconTheme:
            const IconThemeData(
          color: Colors.black,
        ),
      ),

      body: ListView.builder(
        padding:
            const EdgeInsets.all(20),

        itemCount: benefits.length,

        itemBuilder:
            (context, index) {

          final benefit =
              benefits[index];

          final tierColor =
              getTierColor(
            benefit.tier,
          );

          return Container(
            margin:
                const EdgeInsets.only(
              bottom: 18,
            ),

            padding:
                const EdgeInsets.all(
              22,
            ),

            decoration: BoxDecoration(
              color: Colors.white,

              borderRadius:
                  BorderRadius.circular(
                24,
              ),

              border:
                  benefit.isCurrent

                      ? Border.all(
                          color:
                              tierColor,

                          width: 2,
                        )

                      : null,

              boxShadow:
                  benefit.isCurrent

                      ? [
                          BoxShadow(
                            color:
                                tierColor
                                    .withOpacity(
                              0.2,
                            ),

                            blurRadius:
                                12,

                            offset:
                                const Offset(
                              0,
                              6,
                            ),
                          ),
                        ]

                      : [],
            ),

            child: Row(
              children: [

                Container(
                  width: 60,
                  height: 60,

                  decoration:
                      BoxDecoration(
                    color:
                        tierColor
                            .withOpacity(
                      0.15,
                    ),

                    shape:
                        BoxShape.circle,
                  ),

                  child: Icon(
                    Icons
                        .workspace_premium,

                    color: tierColor,

                    size: 32,
                  ),
                ),

                const SizedBox(
                  width: 18,
                ),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,

                    children: [

                      Row(
                        children: [

                          Text(
                            benefit.title,

                            style:
                                const TextStyle(
                              fontWeight:
                                  FontWeight
                                      .bold,

                              fontSize: 18,
                            ),
                          ),

                          if (benefit
                              .isCurrent)

                            Container(
                              margin:
                                  const EdgeInsets.only(
                                left: 10,
                              ),

                              padding:
                                  const EdgeInsets.symmetric(
                                horizontal:
                                    10,

                                vertical:
                                    4,
                              ),

                              decoration:
                                  BoxDecoration(
                                color:
                                    tierColor,

                                borderRadius:
                                    BorderRadius.circular(
                                  10,
                                ),
                              ),

                              child:
                                  const Text(
                                '현재 등급',

                                style:
                                    TextStyle(
                                  color:
                                      Colors
                                          .white,

                                  fontSize:
                                      11,

                                  fontWeight:
                                      FontWeight
                                          .bold,
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(
                        height: 8,
                      ),

                      Text(
                        benefit.description,

                        style: TextStyle(
                          color: Colors
                              .grey
                              .shade700,
                        ),
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      Text(
                        '${benefit.requiredPoints}P 이상 필요',

                        style:
                            TextStyle(
                          color:
                              tierColor,

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
          );
        },
      ),
    );
  }
}