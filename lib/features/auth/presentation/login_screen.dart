import 'package:go_router/go_router.dart';
import '../../../app/config/app_routes.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/core/widgets/action_button.dart';
import '../../auth/presentation/auth_provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    // ✅ [수정] 로그인 로직을 별도의 비동기 함수로 분리합니다.
    Future<void> handleLogin() async {
      // 위젯이 여전히 유효한지 먼저 확인합니다.
      if (!context.mounted) return;

      final isSuccess = await authProvider.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      // 비동기 작업 후에도 위젯이 유효한지 다시 확인합니다.
      if (context.mounted) {
        if (isSuccess) {
          context.go(AppRoutes.education);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.errorMessage ?? '로그인에 실패했습니다.'),
            ),
          );
        }
      }
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),
              Center(
                child: Image.asset(
                  'assets/images/stocker_logo.png',
                  width: 120,
                  height: 120,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                '로그인',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 48),
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
              const SizedBox(height: 32),
              ActionButton(
                text: '로그인',
                icon: Icons.login,
                color: Colors.blue,
                onPressed: authProvider.isLoading ? null : handleLogin,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  context.push(AppRoutes.register);
                },
                child: const Text('회원가입'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
