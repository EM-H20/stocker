import 'package:go_router/go_router.dart';
import '../../../app/config/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // 🔥 Riverpod 추가
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/core/widgets/action_button.dart';
import '../../../app/core/widgets/custom_snackbar.dart'; // 🎨 커스텀 SnackBar
// import '../presentation/auth_provider.dart'; // 🔥 Riverpod으로 교체됨
import '../presentation/riverpod/auth_notifier.dart'; // 🔥 Riverpod AuthNotifier

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final nicknameController = TextEditingController();
  final ageController = TextEditingController(); // 추가
  final occupationController = TextEditingController(); // 추가

  bool agreedToTerms = false;
  String selectedProvider = 'local'; // 기본값을 'local'로 설정
  String profileImageUrl = ''; // 프로필 이미지 URL (선택사항)

  // 직업 선택 옵션들
  final List<String> occupationOptions = [
    '학생',
    '직장인',
    '자영업자',
    '투자자',
    '프리랜서',
    '전업주부',
    '기타'
  ];

  @override
  void initState() {
    super.initState();
    passwordController.addListener(() => setState(() {}));
    confirmPasswordController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    nicknameController.dispose();
    ageController.dispose();
    occupationController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    // 🔥 Riverpod: ref.read()로 AuthNotifier 접근
    final authNotifier = ref.read(authNotifierProvider.notifier);

    if (!mounted) return;

    // 나이 유효성 검사
    final age = int.tryParse(ageController.text.trim());
    if (age == null || age < 1 || age > 120) {
      CustomSnackBar.show(
        context: context,
        type: SnackBarType.error,
        message: '올바른 나이를 입력해주세요 (1-120세)',
      );
      return;
    }

    // 직업 유효성 검사
    if (occupationController.text.trim().isEmpty) {
      CustomSnackBar.show(
        context: context,
        type: SnackBarType.error,
        message: '직업을 입력해주세요',
      );
      return;
    }

    final success = await authNotifier.signup(
      emailController.text.trim(),
      passwordController.text.trim(),
      nicknameController.text.trim(),
      age: age,
      occupation: occupationController.text.trim(),
      provider: selectedProvider,
      profileImageUrl: profileImageUrl.isEmpty
          ? 'https://example.com/profile.png'
          : profileImageUrl, // 기본 프로필 이미지
    );

    if (!mounted) return;

    if (success) {
      // 🎨 회원가입 성공 메시지
      CustomSnackBar.show(
        context: context,
        type: SnackBarType.success,
        message: '회원가입이 완료되었습니다. 로그인 해주세요.',
      );
      context.go(AppRoutes.login);
    } else {
      // 🔥 Riverpod: 최신 상태를 다시 읽어옴
      final currentState = ref.read(authNotifierProvider).value;

      // 🎨 회원가입 실패 메시지 (서버 에러 메시지 자동 표시)
      CustomSnackBar.show(
        context: context,
        type: SnackBarType.error,
        message: currentState?.errorMessage ?? '회원가입에 실패했습니다.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🔥 Riverpod: ref.watch()로 AuthState 구독
    final authState = ref.watch(authNotifierProvider);

    final isPasswordMatch = passwordController.text.isNotEmpty &&
        passwordController.text == confirmPasswordController.text;

    final canSubmit = agreedToTerms &&
        isPasswordMatch &&
        emailController.text.trim().isNotEmpty &&
        nicknameController.text.trim().isNotEmpty &&
        ageController.text.trim().isNotEmpty &&
        occupationController.text.trim().isNotEmpty &&
        !(authState.value?.isLoading ?? false);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              Center(
                child: Image.asset(
                  'assets/images/stocker_logo.png',
                  width: 120.w,
                  height: 120.h,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                '회원가입',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),

              // 이메일
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: '✉️ 이메일',
                  border: OutlineInputBorder(),
                  hintText: 'example@email.com',
                ),
              ),
              const SizedBox(height: 16),

              // 비밀번호
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: '🔒 비밀번호',
                  border: OutlineInputBorder(),
                  hintText: '8자 이상 입력해주세요',
                ),
              ),
              const SizedBox(height: 16),

              // 비밀번호 확인
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: '🔒 비밀번호 확인',
                  border: const OutlineInputBorder(),
                  hintText: '비밀번호를 다시 입력해주세요',
                  errorText: confirmPasswordController.text.isNotEmpty &&
                          !isPasswordMatch
                      ? '비밀번호가 일치하지 않습니다.'
                      : null,
                ),
              ),
              const SizedBox(height: 16),

              // 닉네임
              TextField(
                controller: nicknameController,
                decoration: const InputDecoration(
                  labelText: '🧑 닉네임',
                  border: OutlineInputBorder(),
                  hintText: '다른 사용자에게 보여질 이름',
                ),
              ),
              const SizedBox(height: 16),

              // 나이 (새로 추가)
              TextField(
                controller: ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: '🎂 나이',
                  border: OutlineInputBorder(),
                  hintText: '예: 25',
                ),
              ),
              const SizedBox(height: 16),

              // 직업 (새로 추가) - 드롭다운으로 개선
              DropdownButtonFormField<String>(
                initialValue: occupationController.text.isEmpty
                    ? null
                    : occupationController.text,
                decoration: const InputDecoration(
                  labelText: '💼 직업',
                  border: OutlineInputBorder(),
                ),
                hint: const Text('직업을 선택해주세요'),
                items: occupationOptions.map((String occupation) {
                  return DropdownMenuItem<String>(
                    value: occupation,
                    child: Text(occupation),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    occupationController.text = newValue;
                    setState(() {});
                  }
                },
              ),
              const SizedBox(height: 16),

              // 프로필 이미지 URL (선택사항)
              TextField(
                onChanged: (value) => profileImageUrl = value,
                decoration: const InputDecoration(
                  labelText: '📸 프로필 이미지 URL (선택사항)',
                  border: OutlineInputBorder(),
                  hintText: 'https://example.com/profile.jpg',
                ),
              ),
              const SizedBox(height: 24),

              // 약관 동의
              Row(
                children: [
                  Checkbox(
                    value: agreedToTerms,
                    onChanged: (val) {
                      setState(() => agreedToTerms = val ?? false);
                    },
                  ),
                  const Expanded(
                    child: Text.rich(
                      TextSpan(
                        text: '이용약관 및 ',
                        children: [
                          TextSpan(
                            text: '개인정보처리방침',
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(text: '에 동의합니다'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 회원가입 버튼
              ActionButton(
                text: (authState.value?.isLoading ?? false) ? '처리중...' : '회원가입',
                icon: (authState.value?.isLoading ?? false)
                    ? Icons.hourglass_empty
                    : Icons.person_add,
                color: canSubmit ? Colors.blue : Colors.grey,
                onPressed: canSubmit ? _handleSignup : null,
              ),
              const SizedBox(height: 16),

              // 로그인으로 이동
              TextButton(
                onPressed: () {
                  context.go(AppRoutes.login);
                },
                child: const Text('로그인으로 돌아가기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
