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
      selectedItemColor: Theme.of(context).primaryColor,
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

  /// 현재 위치에 따른 탭 인덱스 반환
  int _getCurrentIndex(String location) {
    if (location.startsWith(AppRoutes.education)) return 0;
    if (location.startsWith(AppRoutes.attendance)) return 1;
    if (location.startsWith(AppRoutes.aptitude)) return 2;
    if (location.startsWith(AppRoutes.wrongNote)) return 3;
    if (location.startsWith(AppRoutes.mypage)) return 4;
    return 0;
  }

  /// 탭이 선택되어 있는지 확인
  bool _isTabSelected(String location, TabItem tab) {
    switch (tab) {
      case TabItem.education:
        return location == AppRoutes.education;
      case TabItem.attendance:
        return location == AppRoutes.attendance;
      case TabItem.aptitude:
        return location == AppRoutes.aptitude;
      case TabItem.wrongNote:
        return location == AppRoutes.wrongNote;
      case TabItem.mypage:
        return location == AppRoutes.mypage;
    }
  }

  /// 탭 클릭 시 GoRouter로 라우팅
  void _onTabTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(AppRoutes.education);
        break;
      case 1:
        context.go(AppRoutes.attendance);
        break;
      case 2:
        context.go(AppRoutes.aptitude);
        break;
      case 3:
        context.go(AppRoutes.wrongNote);
        break;
      case 4:
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
  @override
  void initState() {
    super.initState();
    // AuthProvider의 로그인 성공 Notifier를 구독(listen)합니다.
    context.read<AuthProvider>().loginSuccessNotifier.addListener(_showAttendanceQuizIfNeeded);
  }

  @override
  void dispose() {
    // 위젯이 사라질 때 리스너를 반드시 제거하여 메모리 누수를 방지합니다.
    context.read<AuthProvider>().loginSuccessNotifier.removeListener(_showAttendanceQuizIfNeeded);
    super.dispose();
  }

  // 로그인 성공 시, 출석 퀴즈 팝업을 띄우는 핵심 로직
  Future<void> _showAttendanceQuizIfNeeded() async {
    if (!mounted) return; // ✅ [추가] 리스너 호출 시점에도 context 유효성 확인

    if (context.read<AuthProvider>().loginSuccessNotifier.value == true) {
      final attendanceProvider = context.read<AttendanceProvider>();
      final today = DateTime.utc(DateTime.now().year, DateTime.now().month, DateTime.now().day);

      if (attendanceProvider.attendanceStatus[today] != true) {
        await attendanceProvider.setQuizLoading(true); // ✅ [추가] 퀴즈 로딩 시작
        final success = await attendanceProvider.fetchTodaysQuiz();
        
        if (mounted && success && attendanceProvider.quizzes.isNotEmpty) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => ChangeNotifierProvider.value(
              value: attendanceProvider,
              child: AttendanceQuizDialog(quizzes: attendanceProvider.quizzes),
            ),
          );
        }
        await attendanceProvider.setQuizLoading(false); // ✅ [추가] 퀴즈 로딩 종료
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 이 위젯은 UI를 직접 그리지 않고, 자식 위젯(Scaffold)을 그대로 반환합니다.
    return widget.child;
  }
}
