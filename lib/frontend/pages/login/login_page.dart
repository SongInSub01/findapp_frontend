import 'package:flutter/material.dart';

import 'package:my_flutter_starter/frontend/app_routes.dart';
import 'package:my_flutter_starter/frontend/common/theme/app_colors.dart';
import 'package:my_flutter_starter/frontend/common/theme/app_text_styles.dart';
import 'package:my_flutter_starter/frontend/common/widgets/app_buttons.dart';
import 'package:my_flutter_starter/frontend/frontend_scope.dart';

/// LOGIN PAGE
/// 기존 기능은 유지하면서
/// 디자인만 더 심플하고 세련된 블루/하늘색 테마로 리디자인
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _rememberMe = true;
  bool _hidePassword = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,

      prefixIcon: Icon(
        icon,
        color: const Color(0xFF4A90E2),
      ),

      suffixIcon: suffixIcon,

      filled: true,
      fillColor: const Color(0xFFF5F9FF),

      contentPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 18,
      ),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: Color(0xFF4A90E2),
          width: 1.5,
        ),
      ),

      labelStyle: AppTextStyles.body.copyWith(
        color: AppColors.textSecondary,
      ),

      hintStyle: AppTextStyles.body.copyWith(
        color: AppColors.textSecondary.withValues(alpha: 0.7),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const _LoginBackground(),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.sizeOf(context).height - 80,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _LoginHero(),

                    const SizedBox(height: 30),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.96),

                        borderRadius: BorderRadius.circular(24),

                        border: Border.all(
                          color: const Color(0xFFE5F0FF),
                        ),

                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0D4A90E2),
                            blurRadius: 20,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '로그인',
                            style: AppTextStyles.headline.copyWith(
                              fontSize: 25,
                              fontWeight: FontWeight.w800,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            '이메일 또는 로그인 아이디와 비밀번호를 입력해 주세요.',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                          ),

                          const SizedBox(height: 24),

                          /// 아이디 입력
                          TextField(
                            controller: _idController,
                            decoration: _inputDecoration(
                              label: '이메일 또는 로그인 아이디',
                              hint: '로그인할 계정을 입력해 주세요',
                              icon: Icons.person_outline_rounded,
                            ),
                          ),

                          const SizedBox(height: 16),

                          /// 비밀번호 입력
                          TextField(
                            controller: _passwordController,
                            obscureText: _hidePassword,
                            decoration: _inputDecoration(
                              label: '비밀번호',
                              hint: '비밀번호를 입력해 주세요',
                              icon: Icons.lock_outline_rounded,

                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _hidePassword = !_hidePassword;
                                  });
                                },
                                icon: Icon(
                                  _hidePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 14),

                          /// 로그인 유지 + 비밀번호 찾기
                          Row(
                            children: [
                              Transform.scale(
                                scale: 0.95,
                                child: Checkbox(
                                  value: _rememberMe,
                                  activeColor: const Color(0xFF4A90E2),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      _rememberMe = value ?? true;
                                    });
                                  },
                                ),
                              ),

                              Expanded(
                                child: Text(
                                  '로그인 상태 유지',
                                  style: AppTextStyles.body.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),

                              TextButton(
                                onPressed: _isSubmitting
                                    ? null
                                    : _showRecoveryGuide,
                                child: Text(
                                  '비밀번호 찾기',
                                  style: AppTextStyles.body.copyWith(
                                    color: const Color(0xFF4A90E2),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          /// 로딩
                          if (_isSubmitting) ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F9FF),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.3,
                                      color: Color(0xFF4A90E2),
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  Expanded(
                                    child: Text(
                                      '로그인 정보를 확인하고 있습니다.',
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 14),
                          ],

                          /// 로그인 버튼
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: AppPrimaryButton(
                              label: _isSubmitting
                                  ? '로그인 중...'
                                  : '로그인하고 시작하기',

                              icon: _isSubmitting
                                  ? Icons.hourglass_top_rounded
                                  : Icons.login_rounded,

                              expanded: true,

                              onPressed:
                                  _isSubmitting ? null : _submitLogin,
                            ),
                          ),

                          const SizedBox(height: 18),

                          /// 보안 안내
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),

                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F9FF),

                              borderRadius: BorderRadius.circular(18),

                              border: Border.all(
                                color: const Color(0xFFDDEBFF),
                              ),
                            ),

                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.shield_outlined,
                                  color: Color(0xFF4A90E2),
                                  size: 20,
                                ),

                                const SizedBox(width: 10),

                                Expanded(
                                  child: Text(
                                    '로그인 후에도 분실물 사진은 바로 공개되지 않으며,\n주인 승인 후에만 열람됩니다.',
                                    style: AppTextStyles.caption.copyWith(
                                      color: const Color(0xFF4A90E2),
                                      fontWeight: FontWeight.w700,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    /// 회원가입
                    Center(
                      child: TextButton(
                        onPressed: _isSubmitting
                            ? null
                            : () {
                                Navigator.of(
                                  context,
                                ).pushNamed(AppRoutes.join);
                              },
                        child: RichText(
                          text: TextSpan(
                            text: '처음이신가요? ',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            children: [
                              TextSpan(
                                text: '회원가입하기',
                                style: AppTextStyles.body.copyWith(
                                  color: const Color(0xFF4A90E2),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitLogin() async {
    if (_idController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      _showSnackBar('아이디와 비밀번호를 입력해 주세요.');
      return;
    }

    setState(() => _isSubmitting = true);

    final controller = AppScope.controllerOf(context);

    try {
      final userName = await controller.signIn(
        loginId: _idController.text.trim(),
        password: _passwordController.text,
        rememberMe: _rememberMe,
      );

      if (!mounted) return;

      _showSnackBar('$userName님 환영합니다.');

      Navigator.of(context).pushReplacementNamed(AppRoutes.welcome);
    } catch (error) {
      if (!mounted) return;

      _showSnackBar(
        error.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(message),
      ),
    );
  }

  Future<void> _showRecoveryGuide() async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),

          title: const Text('비밀번호 찾기'),

          content: const Text(
            '등록된 이메일 기준으로 비밀번호 재설정 링크를 전송하는 구조를 붙일 수 있습니다.',
          ),

          actions: [
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }
}

class _LoginBackground extends StatelessWidget {
  const _LoginBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF8FBFF),
            Color(0xFFF3F8FF),
            Color(0xFFEFF6FF),
          ],
        ),
      ),

      child: Stack(
        children: const [
          Positioned(
            top: -50,
            right: -20,
            child: _LoginOrb(
              size: 190,
              color: Color(0x224A90E2),
            ),
          ),

          Positioned(
            bottom: 120,
            left: -40,
            child: _LoginOrb(
              size: 140,
              color: Color(0x1438BDF8),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginHero extends StatelessWidget {
  const _LoginHero();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 8,
          ),

          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),

            borderRadius: BorderRadius.circular(999),

            border: Border.all(
              color: const Color(0xFFDCEBFF),
            ),
          ),

          child: Text(
            '안전한 분실물 보호 시스템',
            style: AppTextStyles.caption.copyWith(
              color: const Color(0xFF4A90E2),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),

        const SizedBox(height: 22),

        Row(
          children: [
            const _LoginLogo(size: 58),

            const SizedBox(width: 16),

            Text(
              '찾아줘',
              style: AppTextStyles.headline.copyWith(
                fontSize: 34,
                color: const Color(0xFF4A90E2),
                fontWeight: FontWeight.w900,
                letterSpacing: -0.8,
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        Text(
          '내 물건을 더 빠르고,\n더 안전하게 찾아줘',
          style: AppTextStyles.headline.copyWith(
            fontSize: 29,
            height: 1.3,
            letterSpacing: -0.4,
          ),
        ),

        const SizedBox(height: 14),

        Text(
          'BLE 거리 알림부터 채팅 연결,\n분실물 사진 보호까지 안전하게 연결됩니다.',
          style: AppTextStyles.body.copyWith(
            color: AppColors.textSecondary,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}

class _LoginLogo extends StatelessWidget {
  const _LoginLogo({required this.size});

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
            Color(0xFF79B8FF),
            Color(0xFF4A90E2),
          ],
        ),

        boxShadow: const [
          BoxShadow(
            color: Color(0x224A90E2),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),

      child: const Center(
        child: Icon(
          Icons.track_changes_rounded,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }
}

class _LoginOrb extends StatelessWidget {
  const _LoginOrb({
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