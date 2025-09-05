import 'package:go_router/go_router.dart';
import '../../../app/config/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/core/widgets/action_button.dart';
import '../presentation/auth_provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final nicknameController = TextEditingController();

  bool agreedToTerms = false;

  // ✅ [추가] 위젯이 처음 생성될 때 호출되는 initState 오버라이드
  @override
  void initState() {
    super.initState();
    // ✅ [추가] 각 컨트롤러에 리스너를 추가하여 텍스트 변경 시마다 setState를 호출합니다.
    // 이렇게 해야 비밀번호 일치 여부 등이 실시간으로 UI에 반영됩니다.
    passwordController.addListener(() => setState(() {}));
    confirmPasswordController.addListener(() => setState(() {}));
  }

  // ✅ [추가] 위젯이 화면에서 사라질 때 호출되는 dispose 오버라이드
  @override
  void dispose() {
    // ✅ [추가] 컨트롤러의 리소스를 해제하여 메모리 누수를 방지합니다.
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    nicknameController.dispose();
    super.dispose();
  }

  // ✅ [추가] 회원가입 로직을 별도의 비동기 함수로 분리합니다.
  Future<void> _handleSignup() async {
    // `build` 메서드 밖에서는 context.read를 사용하는 것이 안전합니다.
    final authProvider = context.read<AuthProvider>();

    if (!mounted) return;

    final success = await authProvider.signup(
      emailController.text.trim(),
      passwordController.text.trim(),
      nicknameController.text.trim(),
    );

    if (!mounted) return;
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('회원가입이 완료되었습니다. 로그인 해주세요.'),
        ),
      );
      // 회원가입 후 로그인 화면으로 이동하되, 뒤로가기로 다시 돌아올 수 없도록 go를 사용합니다.
      context.go(AppRoutes.login);
    } else {
      // ✅ [수정] 실패 시 authProvider에 저장된 구체적인 에러 메시지를 보여줍니다.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? '회원가입에 실패했습니다.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    // ✅ [수정] 비밀번호 일치 여부를 build 메서드 내에서 직접 확인합니다.
    // 컨트롤러에 리스너를 추가했기 때문에 텍스트가 바뀔 때마다 이 부분이 재실행됩니다.
    final isPasswordMatch = passwordController.text.isNotEmpty &&
        passwordController.text == confirmPasswordController.text;

    // ✅ [수정] 제출 가능 여부 조건
    final canSubmit =
        agreedToTerms && isPasswordMatch && !authProvider.isLoading;

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
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: '✉️ 이메일',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: '🔒 비밀번호',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: '🔒 비밀번호 확인',
                  border: const OutlineInputBorder(),
                  // ✅ [개선] 비밀번호 불일치 시 에러 텍스트를 표시하여 사용자 경험을 향상시킵니다.
                  errorText: confirmPasswordController.text.isNotEmpty &&
                          !isPasswordMatch
                      ? '비밀번호가 일치하지 않습니다.'
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nicknameController,
                decoration: const InputDecoration(
                  labelText: '🧑 닉네임',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
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
              ActionButton(
                text: '회원가입',
                icon: Icons.person_add,
                color: Colors.blue,
                // ✅ [수정] canSubmit이 false이면 null을 전달하여 버튼을 완전히 비활성화합니다.
                onPressed: canSubmit ? _handleSignup : null,
              ),
              const SizedBox(height: 16),
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
