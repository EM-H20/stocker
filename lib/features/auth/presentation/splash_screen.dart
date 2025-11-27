import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../app/config/app_routes.dart';
import 'riverpod/auth_notifier.dart';

/// 🚀 스플래시 화면
///
/// 앱 시작 시 인증 상태를 확인하고 적절한 화면으로 리다이렉트합니다.
/// - 로그인 됨 → /education (메인 화면)
/// - 로그인 안 됨 → /login (로그인 화면)
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // 🎬 애니메이션 설정
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );

    _animationController.forward();

    // 인증 상태 확인 시작
    _checkAuthAndNavigate();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// 인증 상태 확인 후 적절한 화면으로 이동
  Future<void> _checkAuthAndNavigate() async {
    debugPrint('🚀 [SPLASH] 인증 상태 확인 시작...');

    // 최소 1.5초 대기 (애니메이션 + 브랜딩 노출)
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    // 인증 상태 확인 (초기화 완료까지 대기)
    final authState = ref.read(authNotifierProvider);

    // AsyncNotifier가 아직 로딩 중이면 대기
    if (authState.isLoading) {
      debugPrint('🔄 [SPLASH] 인증 상태 로딩 중... 대기');

      // 최대 3초까지 대기
      int waitCount = 0;
      while (authState.isLoading && waitCount < 30) {
        await Future.delayed(const Duration(milliseconds: 100));
        waitCount++;
        if (!mounted) return;
      }
    }

    if (!mounted) return;

    // 최종 인증 상태 확인
    final finalAuthState = ref.read(authNotifierProvider);
    final isLoggedIn = finalAuthState.value?.user != null;
    final isInitializing = finalAuthState.value?.isInitializing ?? true;

    debugPrint('🔐 [SPLASH] ═══════════════════════════');
    debugPrint('🔐 [SPLASH] 인증 상태 확인 완료');
    debugPrint('🔐 [SPLASH] Is logged in: $isLoggedIn');
    debugPrint('🔐 [SPLASH] Is initializing: $isInitializing');
    debugPrint(
        '🔐 [SPLASH] User email: ${finalAuthState.value?.user?.email ?? "null"}');
    debugPrint('🔐 [SPLASH] ═══════════════════════════');

    if (!mounted) return;

    // 화면 전환
    if (isLoggedIn) {
      debugPrint('✅ [SPLASH] 로그인 상태 → 교육 탭으로 이동');
      context.go(AppRoutes.education);
    } else {
      debugPrint('🔐 [SPLASH] 비로그인 상태 → 로그인 화면으로 이동');
      context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDarkMode
                ? [
                    const Color(0xFF1A1A2E),
                    const Color(0xFF16213E),
                  ]
                : [
                    Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    Colors.white,
                  ],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: child,
                ),
              );
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // 🎨 로고
                Image.asset(
                  'assets/images/stocker_logo.png',
                  width: 150.w,
                  height: 150.h,
                ),
                SizedBox(height: 24.h),

                // 📝 앱 이름
                Text(
                  'Stocker',
                  style: TextStyle(
                    fontSize: 36.sp,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                    letterSpacing: 2,
                  ),
                ),
                SizedBox(height: 8.h),

                // 🏷️ 슬로건
                Text(
                  '똑똑한 투자 습관의 시작',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const Spacer(flex: 2),

                // ⏳ 로딩 인디케이터
                SizedBox(
                  width: 24.w,
                  height: 24.h,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                SizedBox(height: 16.h),

                Text(
                  '로딩 중...',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: isDarkMode ? Colors.grey[500] : Colors.grey[500],
                  ),
                ),

                SizedBox(height: 48.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
