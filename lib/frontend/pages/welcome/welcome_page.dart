import 'package:flutter/material.dart';

import 'package:my_flutter_starter/frontend/app_routes.dart';
import 'package:my_flutter_starter/frontend/common/theme/app_colors.dart';
import 'package:my_flutter_starter/frontend/common/theme/app_text_styles.dart';
import 'package:my_flutter_starter/frontend/common/widgets/app_buttons.dart';
import 'package:my_flutter_starter/frontend/frontend_scope.dart';

/// WELCOME PAGE
/// 디자인만 미니멀하게 리디자인
/// 기존 기능 유지
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.controllerOf(context);
    final greetingName = controller.state.userProfile.name.trim();

    return Scaffold(
      body: Stack(
        children: [
          const _LandingBackground(),

          SafeArea(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,

              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 24 * (1 - value)),
                    child: child,
                  ),
                );
              },

              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),

                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight:
                        MediaQuery.sizeOf(context).height - 48,
                  ),

                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 10),

                      _HeroSection(
                        greetingName: greetingName,
                      ),

                      const SizedBox(height: 34),

                      const _FeatureGrid(),

                      const SizedBox(height: 34),

                      SizedBox(
                        width: double.infinity,
                        height: 56,

                        child: AppPrimaryButton(
                          label: '찾아줘 시작하기',
                          expanded: true,

                          onPressed: () {
                            Navigator.of(
                              context,
                            ).pushReplacementNamed(
                              AppRoutes.shell,
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 16),

                      Text(
                        '사진은 승인 전까지 잠금 상태로 보호됩니다.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),

                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LandingBackground extends StatelessWidget {
  const _LandingBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF8FBFF),
            Color(0xFFF4F8FF),
            Color(0xFFEFF5FF),
          ],
        ),
      ),

      child: Stack(
        children: const [
          Positioned(
            top: -50,
            right: -30,
            child: _GlowOrb(
              size: 190,
              color: Color(0x184A90E2),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({
    required this.greetingName,
  });

  final String greetingName;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _BrandLockup(),

        const SizedBox(height: 28),

        if (greetingName.isNotEmpty) ...[
          Text(
            '$greetingName님 환영합니다',
            textAlign: TextAlign.center,

            style: AppTextStyles.caption.copyWith(
              color: const Color(0xFF4A90E2),
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 10),
        ],

        Text(
          '분실물을 더 빠르고\n안전하게 찾아보세요',
          textAlign: TextAlign.center,

          style: AppTextStyles.headline.copyWith(
            fontSize: 30,
            height: 1.3,
            letterSpacing: -0.6,
          ),
        ),

        const SizedBox(height: 16),

        Text(
          'BLE 거리 알림과 채팅 연결 기능을 제공합니다.',
          textAlign: TextAlign.center,

          style: AppTextStyles.body.copyWith(
            color: AppColors.textSecondary,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}

class _BrandLockup extends StatelessWidget {
  const _BrandLockup();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _BrandMark(size: 70),

        const SizedBox(height: 18),

        Text(
          '찾아줘',
          style: AppTextStyles.headline.copyWith(
            fontSize: 36,
            color: const Color(0xFF4A90E2),
            fontWeight: FontWeight.w900,
            letterSpacing: -1,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          'Lost & Found Flow',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark({
    required this.size,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,

      decoration: BoxDecoration(
        shape: BoxShape.circle,

        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF7EB6FF),
            Color(0xFF4A90E2),
          ],
        ),

        boxShadow: const [
          BoxShadow(
            color: Color(0x184A90E2),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),

      child: const Center(
        child: Icon(
          Icons.track_changes_rounded,
          color: Colors.white,
          size: 34,
        ),
      ),
    );
  }
}

class _FeatureGrid extends StatelessWidget {
  const _FeatureGrid();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        Row(
          children: [
            Expanded(
              child: _FeatureCard(
                icon: Icons.bluetooth_searching_rounded,
                title: '자동 거리 알림',
                description: '센서가 멀어지면 바로 알려줘요.',
              ),
            ),

            SizedBox(width: 12),

            Expanded(
              child: _FeatureCard(
                icon: Icons.lock_outline_rounded,
                title: '사진 승인 보호',
                description: '허용 전까지 사진을 잠금 보호해요.',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),

        borderRadius: BorderRadius.circular(18),

        boxShadow: const [
          BoxShadow(
            color: Color(0x0A4A90E2),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,

            decoration: BoxDecoration(
              color: const Color(0xFFF1F7FF),

              borderRadius: BorderRadius.circular(14),
            ),

            child: Icon(
              icon,
              color: const Color(0xFF4A90E2),
            ),
          ),

          const SizedBox(height: 12),

          Text(
            title,
            style: AppTextStyles.subtitle.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,

            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,

        decoration: BoxDecoration(
          shape: BoxShape.circle,

          gradient: RadialGradient(
            colors: [
              color,
              color.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }
}