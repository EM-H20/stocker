
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

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    final isPasswordMatch =
        passwordController.text == confirmPasswordController.text;

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
                decoration: const InputDecoration(
                  labelText: '🔒 비밀번호 확인',
                  border: OutlineInputBorder(),
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
                color: canSubmit ? Colors.blue : Colors.grey,
                onPressed: canSubmit
                    ? () async {
                        final success = await authProvider.signup(
                          emailController.text.trim(),
                          passwordController.text.trim(),
                          nicknameController.text.trim(),
                        );
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('회원가입이 완료되었습니다.'),
                            ),
                          );
                          context.push(AppRoutes.login);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('회원가입에 실패했습니다.'),
                            ),
                          );
                        }

                        
                      }
                    : () {},
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  context.push(AppRoutes.login);
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
