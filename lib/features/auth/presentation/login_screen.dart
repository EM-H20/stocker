
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
                onPressed: () {
                  authProvider.login(
                    emailController.text.trim(),
                    passwordController.text.trim(),
                  );
                  if (authProvider.user != null && context.mounted) { //요기 주목 
                    context.go(AppRoutes.education); // 로그인 성공 시 교육 화면으로 이동
                  }
                },
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  context.push(AppRoutes.register); // 회원가입 화면으로 이동
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
