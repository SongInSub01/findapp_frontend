import 'package:flutter/material.dart';

import 'package:my_flutter_starter/frontend/app_routes.dart';
import 'package:my_flutter_starter/frontend/common/theme/app_colors.dart';
import 'package:my_flutter_starter/frontend/common/theme/app_text_styles.dart';
import 'package:my_flutter_starter/frontend/common/widgets/app_buttons.dart';
import 'package:my_flutter_starter/frontend/frontend_scope.dart';

/// LOGIN PAGE
/// 사용자가 찾아줘 서비스를 시작하기 전에 아이디와 비밀번호로 로그인하는 페이지다.
/// 아이디와 비밀번호 입력, 로그인 검증, 회원가입 진입을 이 파일 안에서 함께 처리한다.
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const _LoginBackground(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.sizeOf(context).height - 72,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _LoginHero(),
                    const SizedBox(height: 28),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.96),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: const Color(0xFFE4F3F1)),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x14000000),
                            blurRadius: 28,
                            offset: Offset(0, 14),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '로그인',
                            style: AppTextStyles.headline.copyWith(fontSize: 24),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '이메일 또는 로그인 아이디와 비밀번호를 입력해 주세요.',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 18),
                          TextField(
                            controller: _idController,
                            decoration: const InputDecoration(
                              labelText: '이메일 또는 로그인 아이디',
                              hintText: '로그인할 계정을 입력해 주세요',
                              prefixIcon: Icon(Icons.person_outline_rounded),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _passwordController,
                            obscureText: _hidePassword,
                            decoration: InputDecoration(
                              labelText: '비밀번호',
                              hintText: '비밀번호를 입력해 주세요',
                              prefixIcon: const Icon(Icons.lock_outline_rounded),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() => _hidePassword = !_hidePassword);
                                },
                                icon: Icon(
                                  _hidePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                    value: _rememberMe,
                                    activeColor: AppColors.teal,
                                    onChanged: (value) {
                                      setState(() => _rememberMe = value ?? true);
                                    },
                                  ),
                                  Expanded(
                                    child: Text(
                                      '로그인 상태 유지',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextStyles.body.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: _showRecoveryGuide,
                                  child: const Text('비밀번호 찾기'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          AppPrimaryButton(
                            label: '로그인하고 시작하기',
                            icon: Icons.login_rounded,
                            expanded: true,
                            onPressed: _isSubmitting ? null : _submitLogin,
                          ),
                          const SizedBox(height: 18),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEAFBF7),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.lock_outline_rounded, size: 18, color: AppColors.teal),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '로그인 후에도 분실물 사진은 바로 공개되지 않으며, 주인 승인 후에만 열람됩니다.',
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.teal,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pushNamed(
                          AppRoutes.join,
                        ),
                        child: Text(
                          '처음이신가요? 회원가입하기',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.teal,
                            fontWeight: FontWeight.w700,
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
    if (_idController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
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
      if (!mounted) {
        return;
      }
      _showSnackBar('$userName님 환영합니다. 안내 화면으로 이동합니다.');
      Navigator.of(context).pushReplacementNamed(AppRoutes.welcome);
    } catch (error) {
      if (!mounted) {
        return;
      }
      _showSnackBar(error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _showRecoveryGuide() async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('비밀번호 찾기'),
          content: const Text(
            '등록된 이메일 기준으로 비밀번호 재설정 링크를 전송하는 구조를 붙일 수 있습니다.\n'
            '현재 프로젝트는 실제 회원가입 API를 통해 생성한 계정으로 로그인합니다.',
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
            Color(0xFFF8FCFC),
            Color(0xFFF2FBF8),
            AppColors.background,
          ],
        ),
      ),
      child: Stack(
        children: const [
          Positioned(
            top: -40,
            right: -10,
            child: _LoginOrb(size: 180, color: Color(0x262DD4BF)),
          ),
          Positioned(
            top: 140,
            left: -45,
            child: _LoginOrb(size: 150, color: Color(0x1E38BDF8)),
          ),
          Positioned(
            bottom: 80,
            right: 8,
            child: _LoginOrb(size: 130, color: Color(0x1F14B8A6)),
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0xFFD5F5F0)),
          ),
          child: Text(
            '안전한 분실물 보호 흐름',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.teal,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            const _LoginLogo(size: 54),
            const SizedBox(width: 14),
            Text(
              '찾아줘',
              style: AppTextStyles.headline.copyWith(
                fontSize: 32,
                color: AppColors.teal,
                letterSpacing: -0.6,
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        Text(
          '내 물건을 더 빨리,\n더 안전하게 찾아줘',
          style: AppTextStyles.headline.copyWith(
            fontSize: 28,
            height: 1.28,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'BLE 거리 알림부터 분실 후 채팅 연결, 사진 승인 보호까지\n찾아줘가 자연스럽게 이어줍니다.',
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
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFE9FBF7),
          ],
        ),
      ),
      child: const Center(
        child: Icon(Icons.track_changes_rounded, color: AppColors.teal, size: 28),
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
