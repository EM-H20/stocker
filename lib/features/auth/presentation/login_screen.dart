import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../app/config/app_routes.dart';
import '../../../app/core/widgets/custom_snackbar.dart';
import 'riverpod/auth_notifier.dart';
import 'widgets/modern_text_field.dart';
import 'widgets/gradient_button.dart';

/// 🔥 ConsumerStatefulWidget으로 변환 - TextEditingController 생명주기 관리
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  // ✅ State 클래스 멤버로 이동 - 빌드 때마다 초기화되지 않음!
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    // ✅ 메모리 누수 방지 - 컨트롤러 정리
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// ✅ 로그인 처리 로직
  Future<void> _handleLogin() async {
    if (!mounted) return;

    debugPrint('🔐 [LOGIN] Login attempt started');

    // 🔥 Riverpod: ref.read()로 AuthNotifier의 login 메서드 호출
    final authNotifier = ref.read(authNotifierProvider.notifier);
    final isSuccess = await authNotifier.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    // 비동기 작업 후에도 위젯이 유효한지 다시 확인합니다.
    if (mounted) {
      if (isSuccess) {
        debugPrint('✅ [LOGIN] 로그인 성공');

        // 🔥 Riverpod: 최신 상태를 다시 읽어옴
        final currentState = ref.read(authNotifierProvider).value;
        debugPrint(
            '🔍 [LOGIN] Current auth state - user: ${currentState?.user?.email}');

        // ✅ Android 대응: Riverpod 상태 전파 대기
        debugPrint('⏳ [LOGIN] Waiting for state propagation...');
        await Future.delayed(const Duration(milliseconds: 200));

        // 상태 전파 후 재확인
        final finalState = ref.read(authNotifierProvider).value;
        debugPrint(
            '✅ [LOGIN] State propagation complete - user: ${finalState?.user?.email}');

        // ✅ async gap 이후 mounted 체크
        if (!mounted) return;

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
        final errorMsg = currentState?.errorMessage ?? '로그인에 실패했습니다.';

        debugPrint('🔔 [LOGIN] 에러 메시지 표시 예정: $errorMsg');

        // 🎨 실패 메시지 표시 (커스텀 SnackBar) - 서버 에러 메시지 자동 표시
        CustomSnackBar.show(
          context: context,
          type: SnackBarType.error,
          message: errorMsg,
          duration: const Duration(seconds: 3),
        );

        debugPrint('✅ [LOGIN] CustomSnackBar.show() 호출 완료');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🔥 Riverpod: ref.watch()로 AuthState 구독
    final authState = ref.watch(authNotifierProvider);

    return PopScope(
      // ✅ Android 뒤로가기 버튼 제어: 로그인 화면에서는 뒤로가기 허용 (홈으로 이동)
      canPop: false, // 기본 뒤로가기 막기
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (!didPop) {
          debugPrint('🔙 [LOGIN] Android 뒤로가기 감지');
          // 홈으로 이동 허용
          context.go(AppRoutes.home);
        }
      },
      child: GestureDetector(
        onTap: () {
          // 화면을 탭하면 키보드 숨김
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          // ✅ 키보드가 올라올 때 Scaffold가 자동으로 resize되도록 설정
          resizeToAvoidBottomInset: true,
          // ✅ AppBar 제거 - 회원가입 화면과 일관성 유지
          body: SafeArea(
            child: SingleChildScrollView(
              // ✅ 키보드 올라올 때 스크롤 가능하도록 추가
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 60.h), // ✅ AppBar 없어서 상단 여백 증가
                    Center(
                      child: Image.asset(
                        'assets/images/stocker_logo.png',
                        width: 140.w, // ✅ 로고 크기 증가 + 반응형
                        height: 140.h,
                      ),
                    ),
                    SizedBox(height: 32.h), // ✅ 반응형 적용
                    Text(
                      '로그인',
                      textAlign: TextAlign.center,
                      style:
                          Theme.of(context).textTheme.headlineMedium, // ✅ Theme 활용
                    ),
                    SizedBox(height: 48.h), // ✅ 반응형 적용
                    // ✨ ModernTextField - 이메일
                    ModernTextField(
                      label: '이메일',
                      hint: 'example@email.com',
                      prefixIcon: Icons.email_outlined,
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 16.h), // ✅ 반응형 적용
                    // ✨ ModernTextField - 비밀번호 (가시성 토글 포함)
                    ModernTextField(
                      label: '비밀번호',
                      prefixIcon: Icons.lock_outline,
                      controller: _passwordController,
                      isPassword: true,
                    ),
                    SizedBox(height: 32.h), // ✅ 반응형 적용
                    // ✨ GradientButton - 로그인
                    GradientButton(
                      text: '로그인',
                      icon: Icons.login,
                      onPressed: (authState.value?.isLoading ?? false)
                          ? null
                          : _handleLogin,
                      isLoading: authState.value?.isLoading ?? false,
                    ),
                    SizedBox(height: 24.h), // ✅ 반응형 적용
                    // ✨ 개선된 회원가입 CTA
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '계정이 없으신가요? ',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ), // ✅ Theme 활용
                        ),
                        TextButton(
                          onPressed: () {
                            debugPrint('📝 [LOGIN] 회원가입 버튼 클릭');
                            context.push(AppRoutes.register);
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ), // ✅ 반응형 적용
                          ),
                          child: Text(
                            '회원가입',
                            style:
                                Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ), // ✅ Theme 활용
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
