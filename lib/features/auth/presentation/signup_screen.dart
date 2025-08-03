//회원가입 UI
import 'package:go_router/go_router.dart';
import '../../../app/config/app_routes.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../presentation/auth_provider.dart';
import '../presentation/widgets/auth_switch_button.dart';  // 수정된 경로
import '../presentation/widgets/auth_text_field.dart';  // 수정된 경로
import '../presentation/widgets/password_helper_text.dart';  // 수정된 경로


class SignupScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nicknameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('회원가입')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 50),
            // 이메일 입력 필드
            AuthTextField(
              controller: emailController,
              hintText: '이메일을 입력하세요',
            ),
            const SizedBox(height: 16),
            // 비밀번호 입력 필드
            AuthTextField(
              controller: passwordController,
              hintText: '비밀번호를 입력하세요',
              isPassword: true,
            ),
            const SizedBox(height: 16),
            // 비밀번호 조건 안내
            PasswordHelperText(isValid: passwordController.text.length >= 8),
            const SizedBox(height: 16),
            // 닉네임 입력 필드
            AuthTextField(
              controller: nicknameController,
              hintText: '닉네임을 입력하세요',
            ),
            const SizedBox(height: 20),
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                return authProvider.isLoading
                    ? const CircularProgressIndicator() // 로딩 중에는 스피너 표시
                    : ElevatedButton( 
                        onPressed: () {
                          authProvider.signup(   // 회원가입 메소드 호출
                            emailController.text,
                            passwordController.text,
                            nicknameController.text,
                          );
                          context.go(AppRoutes.login); // 회원가입 후 로그인 화면으로 리디렉션
                        },
                        child: const Text('회원가입'),
                      );
              },
            ),
            const SizedBox(height: 20),
            // 로그인 화면으로 이동
            AuthSwitchButton(
              buttonText: '로그인',
              onPressed: () {
                context.go(AppRoutes.login); // 로그인 화면으로 이동
              },
            ),

            
    
            // 회원가입 실패 시 오류 메시지 표시
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                return authProvider.errorMessage.isNotEmpty
                    ? Text(
                        authProvider.errorMessage,
                        style: const TextStyle(color: Colors.red),
                      )
                    : const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}