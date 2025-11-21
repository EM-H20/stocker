import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // 🔥 Riverpod 추가
import 'package:go_router/go_router.dart';
import '../../../app/config/app_routes.dart';
import '../../../app/core/widgets/action_button.dart';
// import '../../auth/presentation/auth_provider.dart'; // 🔥 Riverpod으로 교체됨
import '../../auth/presentation/riverpod/auth_notifier.dart'; // 🔥 Riverpod AuthNotifier

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🔥 Riverpod: ref.watch()로 AuthState 구독
    final authState = ref.watch(authNotifierProvider);

    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    // ✅ [Riverpod 변환] 로그인 로직을 별도의 비동기 함수로 분리합니다.
    Future<void> handleLogin() async {
      // 위젯이 여전히 유효한지 먼저 확인합니다.
      if (!context.mounted) return;

      // 🔥 Riverpod: ref.read()로 AuthNotifier의 login 메서드 호출
      final authNotifier = ref.read(authNotifierProvider.notifier);
      final isSuccess = await authNotifier.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      // 비동기 작업 후에도 위젯이 유효한지 다시 확인합니다.
      if (context.mounted) {
        if (isSuccess) {
          debugPrint('✅ [LOGIN] 로그인 성공');

          // 🔥 Riverpod: 최신 상태를 다시 읽어옴
          final currentState = ref.read(authNotifierProvider).value;

          // ✅ 쿼리 파라미터에서 원래 경로 가져오기
          final uri = GoRouterState.of(context).uri;
          final redirectPath = uri.queryParameters['redirect'];

          // ✅ 원래 가려던 페이지로 이동 (없으면 기본 홈)
          final destination = redirectPath ?? AppRoutes.education;

          debugPrint('📍 [LOGIN] Redirecting to: $destination');
          context.go(destination);

          // 성공 메시지 표시
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('${currentState?.user?.nickname ?? "사용자"}님 환영합니다! 🎉'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        } else {
          debugPrint('❌ [LOGIN] 로그인 실패');

          // 🔥 Riverpod: 최신 상태를 다시 읽어옴
          final currentState = ref.read(authNotifierProvider).value;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(currentState?.errorMessage ?? '로그인에 실패했습니다.'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }

    return GestureDetector(
      onTap: () {
        // 화면을 탭하면 키보드 숨김
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('로그인'),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () {
              debugPrint('🔙 [LOGIN] 뒤로가기 버튼 클릭');
              // 이전 페이지가 있으면 뒤로가기, 없으면 홈으로
              if (Navigator.canPop(context)) {
                context.pop();
                debugPrint('📱 [LOGIN] 이전 페이지로 이동');
              } else {
                context.go(AppRoutes.home);
                debugPrint('🏠 [LOGIN] 홈 페이지로 이동');
              }
            },
          ),
        ),
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
                  // 🔥 Riverpod: authState.value?.isLoading으로 로딩 상태 확인
                  onPressed: (authState.value?.isLoading ?? false)
                      ? null
                      : handleLogin,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () {
                        debugPrint('📝 [LOGIN] 회원가입 버튼 클릭');
                        context.push(AppRoutes.register);
                      },
                      child: const Text('회원가입'),
                    ),
                    Text(
                      '|',
                      style: TextStyle(
                        color: Colors.grey.withValues(alpha: 0.5),
                        fontSize: 16,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        debugPrint('🏠 [LOGIN] 메인으로 돌아가기 버튼 클릭');
                        context.go(AppRoutes.home);
                      },
                      icon: const Icon(Icons.home_outlined, size: 18),
                      label: const Text('메인으로'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
