import 'package:flutter/material.dart';

import 'package:my_flutter_starter/data/models/app_models.dart';
import 'package:my_flutter_starter/frontend/frontend_scope.dart';

class RewardBenefitPage extends StatelessWidget {
  const RewardBenefitPage({super.key});

  @override
  Widget build(BuildContext context) {
    final benefits = AppScope.controllerOf(context).state.rewardStatus.benefits;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          '등급별 혜택',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: benefits.isEmpty
          ? const Center(child: Text('등급 혜택 정보가 없습니다.'))
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: benefits.length,
              itemBuilder: (context, index) {
                final benefit = benefits[index];
                final color = _colorForTier(benefit.tier);
                return _BenefitCard(benefit: benefit, color: color);
              },
            ),
    );
  }

  Color _colorForTier(String tier) {
    switch (tier) {
      case 'Silver':
        return const Color(0xFFC0C0C0);
      case 'Gold':
        return const Color(0xFFFFD700);
      case 'Master':
        return const Color(0xFF6D28D9);
      case 'Bronze':
      default:
        return const Color(0xFFCD7F32);
    }
  }
}

class _BenefitCard extends StatelessWidget {
  const _BenefitCard({required this.benefit, required this.color});

  final RewardBenefit benefit;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: benefit.isCurrent ? Border.all(color: color, width: 2) : null,
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.workspace_premium, color: color, size: 32),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        benefit.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    if (benefit.isCurrent)
                      Text(
                        '현재 등급',
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  benefit.description,
                  style: TextStyle(color: Colors.grey.shade700),
                ),
                const SizedBox(height: 6),
                Text(
                  '${benefit.requiredPoints}P 이상',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
