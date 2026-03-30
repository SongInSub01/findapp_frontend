import 'package:flutter/material.dart';

import 'package:my_flutter_starter/frontend/app_routes.dart';
import 'package:my_flutter_starter/frontend/common/theme/app_colors.dart';
import 'package:my_flutter_starter/frontend/common/theme/app_text_styles.dart';
import 'package:my_flutter_starter/frontend/common/widgets/app_buttons.dart';
import 'package:my_flutter_starter/frontend/frontend_scope.dart';

/// JOIN PAGE
/// 처음 찾아줘를 사용하는 사용자가 계정을 만들고 보호 흐름을 시작하는 페이지다.
/// 이름, 이메일, 비밀번호, 약관 동의와 같은 가입 입력을 이 파일 안에서 함께 처리한다.
class JoinPage extends StatefulWidget {
  const JoinPage({super.key});

  @override
  State<JoinPage> createState() => _JoinPageState();
}

class _JoinPageState extends State<JoinPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _agreeToPolicy = true;
  bool _agreeToMarketing = false;
  bool _hidePassword = true;
  bool _hideConfirmPassword = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const _SignupBackground(),
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
                    IconButton.filledTonal(
                      onPressed: () => Navigator.of(context).pop(),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.92),
                      ),
                      icon: const Icon(Icons.chevron_left_rounded),
                    ),
                    const SizedBox(height: 18),
                    const _SignupHero(),
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
                            '회원가입',
                            style: AppTextStyles.headline.copyWith(fontSize: 24),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '내 물건 상태, 위치 알림, 승인 대기 사진, 채팅 기록을 안전하게 연결할 계정을 만듭니다.',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 18),
                          TextField(
                            controller: _nameController,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: '이름',
                              hintText: '홍길동',
                              prefixIcon: Icon(Icons.person_outline_rounded),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: '이메일',
                              hintText: 'owner@example.com',
                              prefixIcon: Icon(Icons.mail_outline_rounded),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _passwordController,
                            obscureText: _hidePassword,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              labelText: '비밀번호',
                              hintText: '8자 이상 입력',
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
                          TextField(
                            controller: _confirmPasswordController,
                            obscureText: _hideConfirmPassword,
                            decoration: InputDecoration(
                              labelText: '비밀번호 확인',
                              hintText: '동일한 비밀번호 입력',
                              prefixIcon: const Icon(Icons.verified_user_outlined),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(
                                    () => _hideConfirmPassword = !_hideConfirmPassword,
                                  );
                                },
                                icon: Icon(
                                  _hideConfirmPassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _AgreementTile(
                            value: _agreeToPolicy,
                            title: '개인정보 처리 및 위치 기반 보호 정책에 동의',
                            subtitle: '분실물 보호 흐름, 채팅 연결, 승인 요청 처리에 필요합니다.',
                            onChanged: (value) {
                              setState(() => _agreeToPolicy = value ?? false);
                            },
                          ),
                          const SizedBox(height: 8),
                          _AgreementTile(
                            value: _agreeToMarketing,
                            title: '보호 알림 팁과 업데이트 소식 받기',
                            subtitle: '선택 항목이며 언제든지 설정에서 변경할 수 있습니다.',
                            onChanged: (value) {
                              setState(() => _agreeToMarketing = value ?? false);
                            },
                          ),
                          const SizedBox(height: 18),
                          AppPrimaryButton(
                            label: '회원가입하고 시작하기',
                            icon: Icons.person_add_alt_1_rounded,
                            expanded: true,
                            onPressed: _isSubmitting ? null : _submitSignup,
                          ),
                          const SizedBox(height: 14),
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
                                const Icon(
                                  Icons.privacy_tip_outlined,
                                  size: 18,
                                  color: AppColors.teal,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '가입 후에도 분실물 사진은 기본 잠금 상태로 유지되며, 주인 승인 전에는 노출되지 않습니다.',
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
                        onPressed: () => Navigator.of(context).pushReplacementNamed(
                          AppRoutes.login,
                        ),
                        child: Text(
                          '이미 계정이 있나요? 로그인하기',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.primaryDark,
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

  Future<void> _submitSignup() async {
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty ||
        _confirmPasswordController.text.trim().isEmpty) {
      _showSnackBar('모든 항목을 입력해 주세요.');
      return;
    }

    if (_passwordController.text.trim().length < 8) {
      _showSnackBar('비밀번호는 8자 이상으로 입력해 주세요.');
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showSnackBar('비밀번호와 비밀번호 확인이 일치하지 않습니다.');
      return;
    }

    if (!_agreeToPolicy) {
      _showSnackBar('필수 동의 항목을 확인해 주세요.');
      return;
    }

    setState(() => _isSubmitting = true);
    final controller = AppScope.controllerOf(context);

    try {
      final userName = await controller.signUp(
        userName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        rememberMe: true,
      );
      if (!mounted) {
        return;
      }
      _showSnackBar('$userName님, 찾아줘 가입이 완료되었습니다.');
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
}

class _SignupBackground extends StatelessWidget {
  const _SignupBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF8FCFC),
            Color(0xFFF1FBF8),
            AppColors.background,
          ],
        ),
      ),
      child: Stack(
        children: const [
          Positioned(
            top: -34,
            right: -16,
            child: _SignupOrb(size: 184, color: Color(0x242DD4BF)),
          ),
          Positioned(
            top: 150,
            left: -42,
            child: _SignupOrb(size: 148, color: Color(0x2038BDF8)),
          ),
          Positioned(
            bottom: 84,
            right: 10,
            child: _SignupOrb(size: 126, color: Color(0x1F14B8A6)),
          ),
        ],
      ),
    );
  }
}

class _SignupHero extends StatelessWidget {
  const _SignupHero();

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
            '처음 시작하는 보호 설정',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.teal,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            const _SignupLogo(size: 54),
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
          '계정을 만들고 내 물건 보호 흐름을\n안전하게 시작하세요.',
          style: AppTextStyles.headline.copyWith(
            fontSize: 28,
            height: 1.28,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'BLE 분실 경고, 안전지대, 채팅 연결, 사진 승인 대기 흐름을 내 계정 기준으로 이어갈 수 있습니다.',
          style: AppTextStyles.body.copyWith(
            color: AppColors.textSecondary,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}

class _SignupLogo extends StatelessWidget {
  const _SignupLogo({required this.size});

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
            Color(0xFFE8FBF7),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.radar_rounded,
          size: size * 0.5,
          color: AppColors.teal,
        ),
      ),
    );
  }
}

class _AgreementTile extends StatelessWidget {
  const _AgreementTile({
    required this.value,
    required this.title,
    required this.subtitle,
    required this.onChanged,
  });

  final bool value;
  final String title;
  final String subtitle;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBFB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2F2F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: value,
            activeColor: AppColors.teal,
            onChanged: onChanged,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SignupOrb extends StatelessWidget {
  const _SignupOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}
