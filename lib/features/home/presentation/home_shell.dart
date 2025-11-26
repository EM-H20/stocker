import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'tap_item.dart';
import '../../../app/config/app_routes.dart';
import '../../../app/core/services/aptitude_prompt_service.dart';
import '../../auth/presentation/riverpod/auth_notifier.dart';
import '../../attendance/presentation/riverpod/attendance_notifier.dart';
import '../../attendance/presentation/widgets/attendance_quiz_dialog.dart';
import '../../aptitude/presentation/widgets/aptitude_prompt_dialog.dart';
import '../../../app/core/utils/theme_utils.dart';

/// BottomNavigationBar와 탭별 화면 전환을 담당하는 메인 Shell (StatelessWidget 유지)
class HomeShell extends StatelessWidget {
  final Widget child;

  const HomeShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // ✅ [수정] 기존 Scaffold를 _HomeShellListener라는 새로운 위젯으로 감쌉니다.
    // 이 위젯이 화면에 보이지 않게 백그라운드에서 리스너 역할을 수행합니다.
    return _HomeShellListener(
      child: Scaffold(
        body: child, // ShellRoute에서 전달받은 현재 탭 화면
        bottomNavigationBar: _buildBottomNavigationBar(context),
      ),
    );
  }

  /// BottomNavigationBar 위젯 생성 (GoRouter 기반)
  Widget _buildBottomNavigationBar(BuildContext context) {
    final String location = GoRouterState.of(context).matchedLocation;

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _getCurrentIndex(location),
      onTap: (index) => _onTabTapped(context, index),
      selectedItemColor: ThemeUtils.isDarkMode(context)
          ? const Color(0xFF64B5F6) // 다크모드: 더 밝은 파란색
          : Theme.of(context).primaryColor, // 라이트모드: 기본 테마 색상
      unselectedItemColor: Colors.grey,
      selectedLabelStyle: TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: 11.sp,
        fontWeight: FontWeight.w400,
      ),
      items: TabItem.values.map((tab) {
        final isSelected = _isTabSelected(location, tab);
        return BottomNavigationBarItem(
          icon: Icon(isSelected ? tab.selectedIcon : tab.icon, size: 24.w),
          label: tab.label,
        );
      }).toList(),
    );
  }

  /// 현재 위치에 따른 탭 인덱스 반환 (4개 탭)
  int _getCurrentIndex(String location) {
    if (location.startsWith(AppRoutes.education)) return 0;
    if (location.startsWith(AppRoutes.attendance)) return 1;
    if (location.startsWith(AppRoutes.wrongNote)) return 2;
    if (location.startsWith(AppRoutes.mypage)) return 3;
    return 0;
  }

  /// 탭이 선택되어 있는지 확인 (4개 탭)
  bool _isTabSelected(String location, TabItem tab) {
    switch (tab) {
      case TabItem.education:
        return location == AppRoutes.education;
      case TabItem.attendance:
        return location == AppRoutes.attendance;
      case TabItem.wrongNote:
        return location == AppRoutes.wrongNote;
      case TabItem.mypage:
        return location == AppRoutes.mypage;
    }
  }

  /// 탭 클릭 시 GoRouter로 라우팅 (4개 탭)
  void _onTabTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(AppRoutes.education);
        break;
      case 1:
        context.go(AppRoutes.attendance);
        break;
      case 2:
        context.go(AppRoutes.wrongNote);
        break;
      case 3:
        context.go(AppRoutes.mypage);
        break;
    }
  }
}

// ✅ [Riverpod 변환] 로그인 성공 이벤트를 감지하는 ConsumerStatefulWidget
class _HomeShellListener extends ConsumerStatefulWidget {
  final Widget child;
  const _HomeShellListener({required this.child});

  @override
  ConsumerState<_HomeShellListener> createState() => __HomeShellListenerState();
}

class __HomeShellListenerState extends ConsumerState<_HomeShellListener> {
  // 🔥 Riverpod 변환 완료 - Provider 참조 불필요
  bool _hasCheckedInitialDialogs = false;

  @override
  void initState() {
    super.initState();
    // 🎯 첫 빌드 후 다이얼로그 체크 (로그인 직후 화면 진입 시)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkInitialDialogsIfNeeded();
    });
  }

  /// 🔍 앱 시작/로그인 직후 다이얼로그 체크
  Future<void> _checkInitialDialogsIfNeeded() async {
    if (_hasCheckedInitialDialogs) return;
    _hasCheckedInitialDialogs = true;

    // 로그인 상태인지 확인
    final authState = ref.read(authNotifierProvider).value;
    if (authState?.user != null) {
      debugPrint('🚀 [HOME_SHELL] 앱 시작 - 로그인 상태 감지, 다이얼로그 체크');
      await _handleLoginSuccessDialogs();
    }
  }

  // 🎯 투자 성향 분석 유도 다이얼로그 (SharedPreferences 기반)
  Future<void> _showAptitudePromptIfNeeded() async {
    if (!mounted) return;

    // 🔥 SharedPreferences: 로컬에 저장된 "다음에" 클릭 여부 확인
    final isDismissed = await AptitudePromptService.isDismissed();

    if (!mounted) return;

    // "다음에"를 클릭한 적이 없으면 다이얼로그 표시
    if (!isDismissed) {
      debugPrint('📊 [HOME_SHELL] 성향분석 유도 다이얼로그 표시');
      showDialog(
        context: context,
        barrierDismissible: true, // 다이얼로그 밖 터치로 닫기 가능
        builder: (_) => const AptitudePromptDialog(),
      );
    } else {
      debugPrint('✅ [HOME_SHELL] 이미 "다음에" 선택됨 - 다이얼로그 스킵');
    }
  }

  // 로그인 성공 시, 출석 퀴즈 팝업을 띄우는 핵심 로직
  Future<void> _showAttendanceQuizIfNeeded() async {
    // ✅ mounted 체크
    if (!mounted) return;

    final today = DateTime.utc(
        DateTime.now().year, DateTime.now().month, DateTime.now().day);

    // 🔥 Riverpod: AttendanceNotifier의 상태를 확인
    final attendanceState = ref.read(attendanceNotifierProvider);

    if (!attendanceState.isAttendedOn(today)) {
      // 🔥 Riverpod: AttendanceNotifier의 메서드 호출
      final attendanceNotifier = ref.read(attendanceNotifierProvider.notifier);

      attendanceNotifier.setQuizLoading(true); // ✅ 퀴즈 로딩 시작
      final success = await attendanceNotifier.fetchTodaysQuiz();

      // ✅ context 사용 전에 mounted 다시 확인
      if (mounted && success) {
        final currentQuizzes = ref.read(attendanceNotifierProvider).quizzes;

        if (currentQuizzes.isNotEmpty) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => ProviderScope(
              // 🔥 Riverpod: Dialog에서도 ref 사용 가능하도록 ProviderScope 제공
              child: AttendanceQuizDialog(quizzes: currentQuizzes),
            ),
          );
        }
      }
      attendanceNotifier.setQuizLoading(false); // ✅ 퀴즈 로딩 종료
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🔥 Riverpod ref.listen으로 로그인 성공 이벤트 감지
    ref.listen(loginSuccessNotifierProvider, (prev, next) {
      if (next == true) {
        debugPrint('🎉 [HOME_SHELL] 로그인 성공 이벤트 감지 - 다이얼로그 시퀀스 시작');
        _handleLoginSuccessDialogs();
      }
    });

    // 이 위젯은 UI를 직접 그리지 않고, 자식 위젯(Scaffold)을 그대로 반환합니다.
    return widget.child;
  }

  /// 🎬 로그인 성공 후 다이얼로그 시퀀스 처리
  /// 1. 출석 퀴즈 다이얼로그 (필요시)
  /// 2. 성향분석 유도 다이얼로그 (필요시)
  Future<void> _handleLoginSuccessDialogs() async {
    // 1️⃣ 먼저 출석 퀴즈 확인
    debugPrint('📝 [HOME_SHELL] Step 1: 출석 퀴즈 확인 중...');
    await _showAttendanceQuizIfNeeded();

    // 2️⃣ 출석 퀴즈 완료 후 잠시 대기 (UX 개선)
    if (!mounted) return;
    await Future.delayed(const Duration(milliseconds: 500));

    // 3️⃣ 성향분석 유도 다이얼로그
    if (!mounted) return;
    debugPrint('📊 [HOME_SHELL] Step 2: 성향분석 확인 중...');
    await _showAptitudePromptIfNeeded();
  }
}
