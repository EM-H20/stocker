import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'tap_item.dart';
import '../../../app/config/app_routes.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../attendance/presentation/provider/attendance_provider.dart';
import '../../attendance/presentation/widgets/attendance_quiz_dialog.dart';

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
      selectedItemColor:
          Theme.of(context).brightness == Brightness.dark
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


// ✅ [추가] 로그인 성공 이벤트를 감지하는 역할을 하는 별도의 StatefulWidget
class _HomeShellListener extends StatefulWidget {
  final Widget child;
  const _HomeShellListener({required this.child});

  @override
  State<_HomeShellListener> createState() => __HomeShellListenerState();
}

class __HomeShellListenerState extends State<_HomeShellListener> {
  // ✅ [수정] Provider 참조를 안전하게 저장할 변수들
  AuthProvider? _authProvider;
  AttendanceProvider? _attendanceProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ✅ [수정] didChangeDependencies에서 Provider 참조를 안전하게 저장
    _authProvider = context.read<AuthProvider>();
    _attendanceProvider = context.read<AttendanceProvider>();
    
    // 리스너 등록 (저장된 참조 사용)
    _authProvider?.loginSuccessNotifier.addListener(_showAttendanceQuizIfNeeded);
  }

  @override
  void dispose() {
    // ✅ [수정] dispose에서는 저장된 참조를 사용 (context 사용하지 않음)
    // 이렇게 하면 위젯이 비활성화된 후에도 안전하게 리스너를 제거할 수 있습니다
    _authProvider?.loginSuccessNotifier.removeListener(_showAttendanceQuizIfNeeded);
    super.dispose();
  }

  // 로그인 성공 시, 출석 퀴즈 팝업을 띄우는 핵심 로직
  Future<void> _showAttendanceQuizIfNeeded() async {
    // ✅ [수정] mounted 체크와 Provider null 체크 추가
    if (!mounted || _authProvider == null || _attendanceProvider == null) return;

    if (_authProvider!.loginSuccessNotifier.value == true) {
      final today = DateTime.utc(DateTime.now().year, DateTime.now().month, DateTime.now().day);

      if (_attendanceProvider!.attendanceStatus[today] != true) {
        await _attendanceProvider!.setQuizLoading(true); // ✅ 퀴즈 로딩 시작
        final success = await _attendanceProvider!.fetchTodaysQuiz();
        
        // ✅ [수정] context 사용 전에 mounted 다시 확인
        if (mounted && success && _attendanceProvider!.quizzes.isNotEmpty) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => ChangeNotifierProvider.value(
              value: _attendanceProvider!,
              child: AttendanceQuizDialog(quizzes: _attendanceProvider!.quizzes),
            ),
          );
        }
        await _attendanceProvider!.setQuizLoading(false); // ✅ 퀴즈 로딩 종료
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 이 위젯은 UI를 직접 그리지 않고, 자식 위젯(Scaffold)을 그대로 반환합니다.
    return widget.child;
  }
}
