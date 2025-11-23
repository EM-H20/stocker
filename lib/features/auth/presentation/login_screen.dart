import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/config/app_routes.dart';
import '../../../app/core/widgets/custom_snackbar.dart';
import 'riverpod/auth_notifier.dart';
import 'widgets/modern_text_field.dart';
import 'widgets/gradient_button.dart';

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

      debugPrint('🔐 [LOGIN] Login attempt started');

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
          debugPrint('🔍 [LOGIN] Current auth state - user: ${currentState?.user?.email}');

          // ✅ Android 대응: Riverpod 상태 전파 대기
          // AuthGuard가 정확한 상태로 평가될 수 있도록 추가 대기
          debugPrint('⏳ [LOGIN] Waiting for state propagation...');
          await Future.delayed(const Duration(milliseconds: 200));

          // 상태 전파 후 재확인
          final finalState = ref.read(authNotifierProvider).value;
          debugPrint('✅ [LOGIN] State propagation complete - user: ${finalState?.user?.email}');

          // ✅ async gap 이후 mounted 체크
          if (!context.mounted) return;

          // ✅ 쿼리 파라미터에서 원래 경로 가져오기
          final uri = GoRouterState.of(context).uri;
          final redirectPath = uri.queryParameters['redirect'];

          // ✅ 원래 가려던 페이지로 이동 (없으면 기본 홈)
          final destination = redirectPath ?? AppRoutes.education;

          debugPrint('📍 [LOGIN] Redirecting to: $destination');
          context.go(destination);

          // 🎨 성공 메시지 표시 (커스텀 SnackBar)
          CustomSnackBar.show(
            context: context,
            type: SnackBarType.success,
            message: '${currentState?.user?.nickname ?? "사용자"}님 환영합니다! 🎉',
            duration: const Duration(seconds: 2),
          );
        } else {
          debugPrint('❌ [LOGIN] 로그인 실패');

          // 🔥 Riverpod: 최신 상태를 다시 읽어옴
          final currentState = ref.read(authNotifierProvider).value;

          // 🎨 실패 메시지 표시 (커스텀 SnackBar) - 서버 에러 메시지 자동 표시
          CustomSnackBar.show(
            context: context,
            type: SnackBarType.error,
            message: currentState?.errorMessage ?? '로그인에 실패했습니다.',
            duration: const Duration(seconds: 3),
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
                // ✨ ModernTextField - 이메일
                ModernTextField(
                  label: '이메일',
                  hint: 'example@email.com',
                  prefixIcon: Icons.email_outlined,
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                // ✨ ModernTextField - 비밀번호 (가시성 토글 포함)
                ModernTextField(
                  label: '비밀번호',
                  prefixIcon: Icons.lock_outline,
                  controller: passwordController,
                  isPassword: true,
                ),
                const SizedBox(height: 32),
                // ✨ GradientButton - 로그인
                GradientButton(
                  text: '로그인',
                  icon: Icons.login,
                  onPressed: (authState.value?.isLoading ?? false)
                      ? null
                      : handleLogin,
                  isLoading: authState.value?.isLoading ?? false,
                ),
                const SizedBox(height: 24),
                // ✨ 개선된 회원가입 CTA
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '계정이 없으신가요? ',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        debugPrint('📝 [LOGIN] 회원가입 버튼 클릭');
                        context.push(AppRoutes.register);
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                      ),
                      child: const Text(
                        '회원가입',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
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
