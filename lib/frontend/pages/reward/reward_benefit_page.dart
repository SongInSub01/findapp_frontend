import 'package:flutter/material.dart';

class RewardBenefitPage extends StatelessWidget {
  const RewardBenefitPage({super.key});

  @override
  Widget build(BuildContext context) {
    final benefits = [
      {
        'title': 'Bronze',
        'desc': '기본 포인트 적립',
        'color': const Color(0xFFCD7F32),
      },
      {
        'title': 'Silver',
        'desc': '포인트 1.2배 적립',
        'color': const Color(0xFFC0C0C0),
      },
      {
        'title': 'Gold',
        'desc': '포인트 1.5배 + 특별 배지',
        'color': const Color(0xFFFFD700),
      },
      {
        'title': 'Master',
        'desc': '랭킹 강조 표시 + 특별 테두리',
        'color': const Color(0xFF6D28D9),
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          '등급별 혜택',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: benefits.length,

        itemBuilder: (context, index) {
          final benefit = benefits[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 18),
            padding: const EdgeInsets.all(22),

            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),

            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,

                  decoration: BoxDecoration(
                    color: (benefit['color'] as Color)
                        .withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),

                  child: Icon(
                    Icons.workspace_premium,
                    color: benefit['color'] as Color,
                    size: 32,
                  ),
                ),

                const SizedBox(width: 18),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        benefit['title'] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        benefit['desc'] as String,
                        style: TextStyle(
                          color: Colors.grey.shade700,
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