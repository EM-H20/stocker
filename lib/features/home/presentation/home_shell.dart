import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'tap_item.dart';
import '../../../app/config/app_routes.dart';

/// BottomNavigationBar와 탭별 화면 전환을 담당하는 메인 Shell
class HomeShell extends StatelessWidget {
  final Widget child;

  const HomeShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child, // ShellRoute에서 전달받은 현재 탭 화면
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  /// BottomNavigationBar 위젯 생성 (GoRouter 기반)
  Widget _buildBottomNavigationBar(BuildContext context) {
    // 해당 코드는 GoRouter를 사용하여 BottomNavigationBar를 생성하는 코드입니다.
    final String location = GoRouterState.of(context).matchedLocation;

    return BottomNavigationBar(
      // BottomNavigationBar의 타입을 fixed로 설정하여 탭이 고정됩니다.
      type: BottomNavigationBarType.fixed,
      // 현재 선택된 탭 인덱스를 반환합니다.
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
      // BottomNavigationBarItem을 생성하여 탭 아이콘과 라벨을 설정합니다.
      items:
          TabItem.values.map((tab) {
            final isSelected = _isTabSelected(location, tab);
            // isSelected에 따라 아이콘을 변경합니다.
            return BottomNavigationBarItem(
              icon: Icon(isSelected ? tab.selectedIcon : tab.icon, size: 24.w),
              label: tab.label,
            );
          }).toList(),
    );
  }

  /// 현재 위치에 따른 탭 인덱스 반환
  int _getCurrentIndex(String location) {
    switch (location) {
      case AppRoutes.education:
        return 0;
      case AppRoutes.attendance:
        return 1;
      case AppRoutes.aptitude:
        return 2;
      case AppRoutes.wrongNote:
        return 3;
      case AppRoutes.mypage:
        return 4;
      default:
        return 0;
    }
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
        // app_router.dart에 정의된 경로들을 app_router에서 경로로 사용함.
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
