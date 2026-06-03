import 'package:flutter/material.dart';

import 'package:my_flutter_starter/data/models/app_models.dart';
import 'package:my_flutter_starter/frontend/common/theme/app_colors.dart';
import 'package:my_flutter_starter/frontend/frontend_scope.dart';
import 'package:my_flutter_starter/frontend/pages/reward/reward_benefit_page.dart';
import 'package:my_flutter_starter/frontend/pages/reward/reward_shop_page.dart';
import 'package:my_flutter_starter/frontend/pages/reward/reward_success_dialog.dart';

class RewardPage extends StatefulWidget {
  const RewardPage({super.key});

  @override
  State<RewardPage> createState() => _RewardPageState();
}

class _RewardPageState extends State<RewardPage> {
  String? _claimingQuestCode;

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.controllerOf(context);
    final state = controller.state;
    final rewardStatus = state.rewardStatus;
    final userName = state.userProfile.name.isNotEmpty
        ? state.userProfile.name
        : '사용자';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          '리워드',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshRewardStatus,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 28),
          children: [
            _RewardSummaryCard(userName: userName, rewardStatus: rewardStatus),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: _ActionCard(
                      icon: Icons.store,
                      title: '포인트 상점',
                      color: Colors.blue,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RewardShopPage(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _ActionCard(
                      icon: Icons.emoji_events,
                      title: '등급 혜택',
                      color: Colors.orange,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RewardBenefitPage(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                '오늘의 퀘스트',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 14),
            if (rewardStatus.quests.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Text('진행 가능한 리워드 퀘스트가 없습니다.'),
              )
            else
              for (final quest in rewardStatus.quests)
                _QuestTile(
                  quest: quest,
                  isClaiming: _claimingQuestCode == quest.code,
                  onClaim: () => _claimQuest(context, quest),
                ),
          ],
        ),
      ),
    );
  }

  Future<void> _claimQuest(BuildContext context, RewardQuest quest) async {
    final controller = AppScope.controllerOf(context);
    setState(() => _claimingQuestCode = quest.code);
    try {
      await controller.claimRewardQuest(quest.code);
      if (!context.mounted) {
        return;
      }
      await showDialog<void>(
        context: context,
        builder: (_) => RewardSuccessDialog(rewardMoney: quest.rewardMoney),
      );
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
        setState(() => _claimingQuestCode = null);
      }
    }
  }
}

class _RewardSummaryCard extends StatelessWidget {
  const _RewardSummaryCard({
    required this.userName,
    required this.rewardStatus,
  });

  final String userName;
  final RewardStatus rewardStatus;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white24,
                child: Icon(Icons.person, color: Colors.white, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  '$userName님',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          const Text('보유 포인트', style: TextStyle(color: Colors.white60)),
          const SizedBox(height: 8),
          Text(
            '${rewardStatus.currentPoints} P',
            style: const TextStyle(
              color: Colors.amber,
              fontWeight: FontWeight.bold,
              fontSize: 40,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('다음 보상까지', style: TextStyle(color: Colors.white70)),
              Text(
                '${rewardStatus.currentPoints} / ${rewardStatus.nextGoalPoints} P',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: rewardStatus.progress.clamp(0, 1).toDouble(),
              minHeight: 10,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation(Colors.amber),
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.local_fire_department, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  '${rewardStatus.streakDays}일 연속 활동 중',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.12),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuestTile extends StatelessWidget {
  const _QuestTile({
    required this.quest,
    required this.isClaiming,
    required this.onClaim,
  });

  final RewardQuest quest;
  final bool isClaiming;
  final VoidCallback onClaim;

  @override
  Widget build(BuildContext context) {
    final canClaim = quest.completed && !quest.claimed;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: quest.claimed
                ? Colors.green.shade100
                : AppColors.primary.withValues(alpha: 0.1),
            child: Icon(
              quest.claimed ? Icons.check : _iconForQuest(quest.iconKey),
              color: quest.claimed ? Colors.green : AppColors.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quest.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    decoration: quest.claimed
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  quest.claimed
                      ? '리워드 지급 완료'
                      : '${quest.progressLabel} · ${quest.rewardPoints}P 예정',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          if (quest.claimed)
            const Text(
              '완료',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            )
          else
            ElevatedButton(
              onPressed: canClaim && !isClaiming ? onClaim : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: Text(isClaiming ? '수령 중...' : '리워드 받기'),
            ),
        ],
      ),
    );
  }

  IconData _iconForQuest(String iconKey) {
    switch (iconKey) {
      case 'camera':
        return Icons.camera_alt;
      case 'chat':
        return Icons.chat;
      case 'search':
        return Icons.search;
      default:
        return Icons.card_giftcard;
    }
  }
}
