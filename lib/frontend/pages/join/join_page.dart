import 'package:flutter/material.dart';

import 'package:my_flutter_starter/frontend/app_routes.dart';
import 'package:my_flutter_starter/frontend/common/theme/app_colors.dart';
import 'package:my_flutter_starter/frontend/common/theme/app_text_styles.dart';
import 'package:my_flutter_starter/frontend/common/widgets/app_buttons.dart';
import 'package:my_flutter_starter/frontend/frontend_scope.dart';

/// JOIN PAGE
/// 기능 유지 + 디자인만 미니멀 블루 테마로 수정
class JoinPage extends StatefulWidget {
  const JoinPage({super.key});

  @override
  State<JoinPage> createState() => _JoinPageState();
}

class _JoinPageState extends State<JoinPage> {
  final TextEditingController _nameController =
      TextEditingController();

  final TextEditingController _emailController =
      TextEditingController();

  final TextEditingController _passwordController =
      TextEditingController();

  final TextEditingController
  _confirmPasswordController =
      TextEditingController();

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
      fillColor: const Color(0xFFF7FAFF),

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
          width: 1.4,
        ),
      ),

      labelStyle: AppTextStyles.body.copyWith(
        color: AppColors.textSecondary,
      ),

      hintStyle: AppTextStyles.body.copyWith(
        color: AppColors.textSecondary
            .withValues(alpha: 0.7),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const _SignupBackground(),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                24,
                24,
                24,
                24,
              ),

              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      MediaQuery.sizeOf(context).height -
                      80,
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    /// 뒤로가기
                    Container(
                      width: 46,
                      height: 46,

                      decoration: BoxDecoration(
                        color: Colors.white,

                        borderRadius:
                            BorderRadius.circular(14),

                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0A4A90E2),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),

                      child: IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },

                        icon: const Icon(
                          Icons.chevron_left_rounded,
                          color: Color(0xFF4A90E2),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    const _SignupHero(),

                    const SizedBox(height: 28),

                    /// 회원가입 카드
                    Container(
                      width: double.infinity,

                      padding: const EdgeInsets.all(24),

                      decoration: BoxDecoration(
                        color: Colors.white,

                        borderRadius:
                            BorderRadius.circular(22),

                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0A4A90E2),
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),

                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [
                          Text(
                            '회원가입',

                            style: AppTextStyles.headline
                                .copyWith(
                                  fontSize: 25,
                                  fontWeight:
                                      FontWeight.w800,
                                ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            '계정을 만들고 서비스를 시작해 보세요.',

                            style: AppTextStyles.body
                                .copyWith(
                                  color: AppColors
                                      .textSecondary,
                                ),
                          ),

                          const SizedBox(height: 24),

                          /// 이름
                          TextField(
                            controller:
                                _nameController,

                            decoration:
                                _inputDecoration(
                                  label: '이름',
                                  hint: '홍길동',
                                  icon: Icons
                                      .person_outline_rounded,
                                ),
                          ),

                          const SizedBox(height: 16),

                          /// 이메일
                          TextField(
                            controller:
                                _emailController,

                            keyboardType:
                                TextInputType
                                    .emailAddress,

                            decoration:
                                _inputDecoration(
                                  label: '이메일',
                                  hint:
                                      'owner@example.com',
                                  icon: Icons
                                      .mail_outline_rounded,
                                ),
                          ),

                          const SizedBox(height: 16),

                          /// 비밀번호
                          TextField(
                            controller:
                                _passwordController,

                            obscureText:
                                _hidePassword,

                            decoration:
                                _inputDecoration(
                                  label: '비밀번호',
                                  hint: '8자 이상 입력',
                                  icon: Icons
                                      .lock_outline_rounded,

                                  suffixIcon:
                                      IconButton(
                                        onPressed: () {
                                          setState(() {
                                            _hidePassword =
                                                !_hidePassword;
                                          });
                                        },

                                        icon: Icon(
                                          _hidePassword
                                              ? Icons
                                                    .visibility_outlined
                                              : Icons
                                                    .visibility_off_outlined,

                                          color: AppColors
                                              .textSecondary,
                                        ),
                                      ),
                                ),
                          ),

                          const SizedBox(height: 16),

                          /// 비밀번호 확인
                          TextField(
                            controller:
                                _confirmPasswordController,

                            obscureText:
                                _hideConfirmPassword,

                            decoration:
                                _inputDecoration(
                                  label: '비밀번호 확인',
                                  hint:
                                      '동일한 비밀번호 입력',
                                  icon: Icons
                                      .verified_user_outlined,

                                  suffixIcon:
                                      IconButton(
                                        onPressed: () {
                                          setState(() {
                                            _hideConfirmPassword =
                                                !_hideConfirmPassword;
                                          });
                                        },

                                        icon: Icon(
                                          _hideConfirmPassword
                                              ? Icons
                                                    .visibility_outlined
                                              : Icons
                                                    .visibility_off_outlined,

                                          color: AppColors
                                              .textSecondary,
                                        ),
                                      ),
                                ),
                          ),

                          const SizedBox(height: 20),

                          /// 필수 약관
                          _AgreementTile(
                            value: _agreeToPolicy,

                            title:
                                '개인정보 처리 정책에 동의',

                            subtitle:
                                '서비스 이용을 위한 필수 항목입니다.',

                            onChanged: (value) {
                              setState(() {
                                _agreeToPolicy =
                                    value ?? false;
                              });
                            },
                          ),

                          const SizedBox(height: 10),

                          /// 마케팅
                          _AgreementTile(
                            value:
                                _agreeToMarketing,

                            title:
                                '업데이트 및 알림 수신',

                            subtitle:
                                '선택 항목이며 언제든 변경 가능합니다.',

                            onChanged: (value) {
                              setState(() {
                                _agreeToMarketing =
                                    value ?? false;
                              });
                            },
                          ),

                          const SizedBox(height: 24),

                          /// 회원가입 버튼
                          SizedBox(
                            width: double.infinity,
                            height: 56,

                            child: AppPrimaryButton(
                              label:
                                  _isSubmitting
                                  ? '가입 중...'
                                  : '회원가입하고 시작하기',

                              expanded: true,

                              onPressed:
                                  _isSubmitting
                                  ? null
                                  : _submitSignup,
                            ),
                          ),

                          const SizedBox(height: 16),

                          /// 보안 안내
                          Container(
                            width: double.infinity,

                            padding:
                                const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),

                            decoration: BoxDecoration(
                              color: const Color(
                                0xFFF5F9FF,
                              ),

                              borderRadius:
                                  BorderRadius.circular(
                                    16,
                                  ),
                            ),

                            child: Row(
                              children: [
                                const Icon(
                                  Icons
                                      .shield_outlined,
                                  size: 18,
                                  color: Color(
                                    0xFF4A90E2,
                                  ),
                                ),

                                const SizedBox(
                                  width: 8,
                                ),

                                Expanded(
                                  child: Text(
                                    '사진은 승인 전까지 안전하게 보호됩니다.',

                                    style: AppTextStyles
                                        .caption
                                        .copyWith(
                                          color:
                                              const Color(
                                                0xFF4A90E2,
                                              ),

                                          fontWeight:
                                              FontWeight
                                                  .w700,
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

                    /// 로그인 이동
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context)
                              .pushReplacementNamed(
                                AppRoutes.login,
                              );
                        },

                        child: RichText(
                          text: TextSpan(
                            text:
                                '이미 계정이 있나요? ',

                            style: AppTextStyles
                                .body
                                .copyWith(
                                  color: AppColors
                                      .textSecondary,
                                ),

                            children: [
                              TextSpan(
                                text: '로그인하기',

                                style: AppTextStyles
                                    .body
                                    .copyWith(
                                      color:
                                          const Color(
                                            0xFF4A90E2,
                                          ),

                                      fontWeight:
                                          FontWeight
                                              .w800,
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

  Future<void> _submitSignup() async {
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty ||
        _confirmPasswordController.text
            .trim()
            .isEmpty) {
      _showSnackBar('모든 항목을 입력해 주세요.');
      return;
    }

    if (_passwordController.text.trim().length <
        8) {
      _showSnackBar(
        '비밀번호는 8자 이상으로 입력해 주세요.',
      );
      return;
    }

    if (_passwordController.text !=
        _confirmPasswordController.text) {
      _showSnackBar(
        '비밀번호와 비밀번호 확인이 일치하지 않습니다.',
      );
      return;
    }

    if (!_agreeToPolicy) {
      _showSnackBar(
        '필수 동의 항목을 확인해 주세요.',
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final controller = AppScope.controllerOf(
      context,
    );

    try {
      final userName = await controller.signUp(
        userName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        rememberMe: true,
      );

      if (!mounted) return;

      _showSnackBar(
        '$userName님, 가입이 완료되었습니다.',
      );

      Navigator.of(context)
          .pushReplacementNamed(
            AppRoutes.welcome,
          );
    } catch (error) {
      if (!mounted) return;

      _showSnackBar(
        error.toString().replaceFirst(
          'Exception: ',
          '',
        ),
      );
    } finally {
      if (mounted) {
        setState(
          () => _isSubmitting = false,
        );
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
            Color(0xFFF8FBFF),
            Color(0xFFF4F8FF),
            Color(0xFFEFF5FF),
          ],
        ),
      ),

      child: Stack(
        children: const [
          Positioned(
            top: -60,
            right: -30,

            child: _SignupOrb(
              size: 190,
              color: Color(0x184A90E2),
            ),
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
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        Row(
          children: [
            const _SignupLogo(size: 58),

            const SizedBox(width: 16),

            Text(
              '찾아줘',

              style: AppTextStyles.headline
                  .copyWith(
                    fontSize: 34,
                    color: const Color(
                      0xFF4A90E2,
                    ),
                    fontWeight:
                        FontWeight.w900,
                    letterSpacing: -0.8,
                  ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        Text(
          '계정을 만들고\n안전하게 시작해 보세요',

          style: AppTextStyles.headline
              .copyWith(
                fontSize: 29,
                height: 1.3,
                letterSpacing: -0.4,
              ),
        ),

        const SizedBox(height: 14),

        Text(
          'BLE 거리 알림과 채팅 연결 기능을 사용할 수 있습니다.',

          style: AppTextStyles.body
              .copyWith(
                color:
                    AppColors.textSecondary,
                height: 1.6,
              ),
        ),
      ],
    );
  }
}

class _SignupLogo extends StatelessWidget {
  const _SignupLogo({
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

      child: Center(
        child: Icon(
          Icons.radar_rounded,
          size: size * 0.5,
          color: Colors.white,
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
      padding:
          const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),

      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFF),

        borderRadius:
            BorderRadius.circular(16),
      ),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Checkbox(
            value: value,

            activeColor:
                const Color(0xFF4A90E2),

            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(5),
            ),

            onChanged: onChanged,
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                top: 3,
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Text(
                    title,

                    style: AppTextStyles.body
                        .copyWith(
                          fontWeight:
                              FontWeight
                                  .w700,
                        ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    subtitle,

                    style: AppTextStyles
                        .caption
                        .copyWith(
                          color: AppColors
                              .textSecondary,

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
  const _SignupOrb({
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