import 'package:flutter/material.dart';

import 'package:my_flutter_starter/frontend/app_routes.dart';
import 'package:my_flutter_starter/frontend/common/theme/app_colors.dart';
import 'package:my_flutter_starter/frontend/common/theme/app_text_styles.dart';
import 'package:my_flutter_starter/frontend/common/widgets/app_buttons.dart';
import 'package:my_flutter_starter/frontend/frontend_scope.dart';

/// WELCOME PAGE
/// 앱 첫 진입에서 브랜드 인상과 핵심 가치를 전달하는 랜딩 화면.
/// 찾아줘의 BLE 분실 방지, 보안 사진 승인, 채팅 연결 흐름을 시작 전에 보여준다.
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
            child: LayoutBuilder(
              builder: (context, constraints) {
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 26 * (1 - value)),
                        child: child,
                      ),
                    );
                  },
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight - 42),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 12),
                          _HeroSection(greetingName: greetingName),
                          const SizedBox(height: 28),
                          const _FeatureGrid(),
                          const SizedBox(height: 28),
                          AppPrimaryButton(
                            label: '찾아줘 시작하기',
                            icon: Icons.arrow_forward_rounded,
                            expanded: true,
                            onPressed: () => Navigator.of(context).pushReplacementNamed(
                              AppRoutes.shell,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () => Navigator.of(context).pushReplacementNamed(
                              AppRoutes.shell,
                            ),
                            child: Text(
                              '둘러보기로 바로 이동',
                              style: AppTextStyles.body.copyWith(color: AppColors.primaryDark),
                            ),
                          ),
                          const SizedBox(height: 8),
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
                );
              },
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
            Color(0xFFF7FCFD),
            Color(0xFFF4F9FB),
            AppColors.background,
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -30,
            right: -20,
            child: _GlowOrb(
              size: 180,
              color: const Color(0x332DD4BF),
            ),
          ),
          Positioned(
            top: 130,
            left: -40,
            child: _GlowOrb(
              size: 140,
              color: const Color(0x2238BDF8),
            ),
          ),
          Positioned(
            bottom: 90,
            right: 12,
            child: _GlowOrb(
              size: 120,
              color: const Color(0x1F14B8A6),
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0xFFD5F5F0)),
          ),
          child: Text(
            'BLE 기반 분실물 보호 서비스',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.primaryDark,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 22),
        const _BrandLockup(),
        const SizedBox(height: 26),
        if (greetingName.isNotEmpty) ...[
          Text(
            '$greetingName님, 안녕하세요',
            textAlign: TextAlign.center,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.primaryDark,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
        ],
        Text(
          '멀어지기 전에 먼저 알려주고,\n잃어버린 뒤에도 끝까지 연결해줘요.',
          textAlign: TextAlign.center,
          style: AppTextStyles.headline.copyWith(
            fontSize: 28,
            height: 1.28,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          '내 물건과 BLE 센서가 멀어지면 즉시 알리고,\n주변 사용자와는 채팅으로 연결하되 사진은 승인 전까지 잠금으로 보호합니다.',
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const _BrandMark(size: 62),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '찾아줘',
              style: AppTextStyles.headline.copyWith(
                fontSize: 34,
                color: AppColors.primaryDark,
                letterSpacing: -0.7,
              ),
            ),
            Text(
              'Lost & Found Flow',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFE9FBF7),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A14B8A6),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Center(
        child: CustomPaint(
          size: Size.square(size * 0.54),
          painter: _BrandMarkPainter(),
        ),
      ),
    );
  }
}

class _BrandMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final primary = Paint()
      ..color = AppColors.teal
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    primary.strokeWidth = size.width * 0.08;
    canvas.drawCircle(center, size.width * 0.34, primary);

    primary.strokeWidth = size.width * 0.12;
    final path = Path()
      ..moveTo(center.dx, size.height * 0.18)
      ..lineTo(center.dx, center.dy + size.height * 0.08);
    canvas.drawPath(path, primary);

    final dotPaint = Paint()..color = AppColors.teal;
    canvas.drawCircle(
      Offset(center.dx, size.height * 0.18),
      size.width * 0.06,
      dotPaint,
    );

    final sweepPaint = Paint()
      ..color = AppColors.teal.withValues(alpha: 0.24)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.08
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: size.width * 0.22),
      -1.8,
      1.6,
      false,
      sweepPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
                description: '휴대폰과 센서가 멀어지면 바로 알려줘요.',
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _FeatureCard(
                icon: Icons.shield_outlined,
                title: '안전지대 예외',
                description: '집과 회사 같은 안심 구역은 조용하게 유지돼요.',
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _FeatureCard(
                icon: Icons.lock_outline_rounded,
                title: '사진 승인 보호',
                description: '주인 허용 전에는 사진이 잠금 상태로 보관돼요.',
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _FeatureCard(
                icon: Icons.forum_outlined,
                title: '채팅으로 연결',
                description: '발견자와 대화하고 비매너 신고까지 이어져요.',
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE4F3F1)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 22,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFEAFBF7),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.teal),
          ),
          const SizedBox(height: 14),
          Text(title, style: AppTextStyles.subtitle),
          const SizedBox(height: 6),
          Text(
            description,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
              height: 1.55,
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
