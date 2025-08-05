import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../app/config/app_routes.dart';
import 'auth_provider.dart';
import '../presentation/widgets/auth_switch_button.dart';  // 수정된 경로
import '../presentation/widgets/auth_text_field.dart';  // 수정된 경로
import '../presentation/widgets/password_helper_text.dart';  // 수정된 경로

class LoginScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // 더미 데이터: 로그인 성공 시 사용할 값
  final String dummyEmail = "test@example.com";
  final String dummyPassword = "Password123!";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('로그인')),
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
            const SizedBox(height: 20),
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                return authProvider.isLoading
                    ? const CircularProgressIndicator() // 로딩 중에는 스피너 표시
                    : ElevatedButton(
                        onPressed: () {
                          // 더미 로그인 처리
                          if (emailController.text == dummyEmail &&
                              passwordController.text == dummyPassword) {
                            // 로그인 성공
                            authProvider.setUser(dummyEmail);
                            context.go(AppRoutes.education);
                          } else {
                            // 로그인 실패
                            authProvider.setErrorMessage('아이디 또는 비밀번호가 틀렸습니다.');
                          }
                        },
                        child: const Text('로그인'),
                      );
              },
            ),
            const SizedBox(height: 20),
            // 회원가입 화면으로 이동
            AuthSwitchButton(
              buttonText: '회원가입',
              onPressed: () {
                context.go(AppRoutes.register); // GoRouter로 회원가입 화면으로 이동
              },
            ),
            // 로그인 실패 시 오류 메시지 표시
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
