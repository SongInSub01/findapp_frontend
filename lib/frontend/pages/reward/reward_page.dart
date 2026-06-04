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
  State<RewardPage> createState() => _RewardPageState();
}

class _RewardPageState extends State<RewardPage> {
  RewardStatus? rewardStatus;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => loadReward());
  }

  Future<void> loadReward() async {
    try {
      final state = AppScope.controllerOf(context).state;
      final email = state.userProfile.email;
      final json = await RewardApi.getRewardStatus(email: email);
      setState(() {
        rewardStatus = RewardStatus.fromJson(json);
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  IconData _questIcon(String iconKey) {
    switch (iconKey) {
      case 'search': return Icons.search;
      case 'camera': return Icons.camera_alt;
      case 'chat':   return Icons.chat;
      default:       return Icons.card_giftcard;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.controllerOf(context).state;
    final userName = state.userProfile.name;

    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (rewardStatus == null) return const Center(child: Text('리워드를 불러오지 못했습니다.'));

    // 진행 중(미수령) / 완료(수령) 분리
    final activeQuests  = rewardStatus!.quests.where((q) => !q.claimed).toList();
    final claimedQuests = rewardStatus!.quests.where((q) =>  q.claimed).toList();

    return ColoredBox(
      color: const Color(0xFFF5F7FB),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: Text('리워드', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
            ),

            // 포인트 카드
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: const LinearGradient(colors: [Color(0xFF1E293B), Color(0xFF0F172A)]),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$userName님', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  const Text('보유 포인트', style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 8),
                  Text('${rewardStatus!.currentPoints} P',
                      style: const TextStyle(color: Colors.amber, fontSize: 40, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  LinearProgressIndicator(value: rewardStatus!.progress),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${rewardStatus!.streakDays}일 연속 활동 중 🔥',
                          style: const TextStyle(color: Colors.white, fontSize: 13)),
                      Text('목표 ${rewardStatus!.nextGoalPoints}P',
                          style: const TextStyle(color: Colors.white54, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),

            // 상점 / 혜택 버튼
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(
                        builder: (_) => RewardShopPage(rewardStatus: rewardStatus!))),
                      child: const _ActionCard(icon: Icons.store, title: '포인트 상점', color: Colors.blue),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(
                        builder: (_) => RewardBenefitPage(benefits: rewardStatus!.benefits))),
                      child: const _ActionCard(icon: Icons.emoji_events, title: '등급 혜택', color: Colors.orange),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // 사례금 적립 안내 배너
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, size: 18, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '분실물을 찾음 처리하면 설정한 사례금의 0.1% 포인트가 자동 적립됩니다.',
                      style: TextStyle(fontSize: 12, color: AppColors.primary.withValues(alpha: 0.9), height: 1.4),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 퀘스트 목록
            if (activeQuests.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Center(
                  child: Text('진행 중인 퀘스트가 없습니다',
                      style: TextStyle(color: AppColors.textSecondary)),
                ),
              )
            else
              ListView.builder(
                itemCount: activeQuests.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) =>
                    _QuestCard(quest: activeQuests[index], questIcon: _questIcon,
                        onClaim: _claimQuest),
              ),

            // 수령 완료 퀘스트
            if (claimedQuests.isNotEmpty) ...[
              const SizedBox(height: 8),
              ListView.builder(
                itemCount: claimedQuests.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) =>
                    _QuestCard(quest: claimedQuests[index],
                        questIcon: _questIcon, onClaim: _claimQuest,
                        dimmed: true),
              ),
            ],

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Future<void> _claimQuest(RewardQuest quest) async {
    try {
      final state = AppScope.controllerOf(context).state;
      final json = await RewardApi.claimQuest(
        email: state.userProfile.email,
        questCode: quest.code,
      );
      setState(() => rewardStatus = RewardStatus.fromJson(json));
      if (!mounted) return;
      showDialog(context: context,
          builder: (_) => RewardSuccessDialog(rewardPoint: quest.rewardPoints));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }
}

// ── 퀘스트 카드 ─────────────────────────────────────────────────────────────

class _QuestCard extends StatelessWidget {
  const _QuestCard({
    required this.quest,
    required this.questIcon,
    required this.onClaim,
    this.dimmed = false,
  });

  final RewardQuest quest;
  final IconData Function(String) questIcon;
  final Future<void> Function(RewardQuest) onClaim;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: dimmed ? 0.55 : 1.0,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: quest.completed && !quest.claimed
              ? Border.all(color: AppColors.primary.withValues(alpha: 0.4), width: 1.5)
              : null,
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: quest.claimed
                  ? const Color(0xFFE5E7EB)
                  : quest.completed
                  ? AppColors.primary.withValues(alpha: 0.12)
                  : const Color(0xFFF3F4F6),
              child: Icon(questIcon(quest.iconKey),
                  color: quest.claimed
                      ? AppColors.textSecondary
                      : quest.completed ? AppColors.primary : AppColors.textTertiary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(quest.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: dimmed ? AppColors.textSecondary : const Color(0xFF111827),
                      )),
                  const SizedBox(height: 4),
                  Text(quest.progressLabel,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  if (!quest.claimed) ...[
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: quest.progressTarget > 0
                          ? quest.progressCurrent / quest.progressTarget
                          : 0,
                      backgroundColor: const Color(0xFFE5E7EB),
                      color: AppColors.primary,
                      minHeight: 4,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            if (quest.claimed)
              const Icon(Icons.check_circle_rounded, color: AppColors.green, size: 24)
            else
              ElevatedButton(
                onPressed: quest.completed ? () => onClaim(quest) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: quest.completed ? AppColors.primary : const Color(0xFFE5E7EB),
                  foregroundColor: quest.completed ? Colors.white : AppColors.textSecondary,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
                child: Text(quest.completed ? '받기' : '진행 중'),
              ),
          ],
        ),
      ),
    );
  }
}

// ── 액션 카드 ─────────────────────────────────────────────────────────────

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.icon, required this.title, required this.color});

  final IconData icon;
  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)),
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 14),
          Text(title),
        ],
      ),
    );
  }
}
