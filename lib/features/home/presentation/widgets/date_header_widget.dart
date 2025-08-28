import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/config/app_theme.dart';
import '../../../../app/config/app_routes.dart';
import '../../../auth/presentation/auth_provider.dart';

/// 메인 대시보드 상단 날짜 헤더 위젯
class DateHeaderWidget extends StatelessWidget {
  const DateHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final weekday = weekdays[now.weekday - 1];
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 날짜 정보
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                weekday,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.w300,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withValues(alpha: 0.8)
                      : AppTheme.grey900.withValues(alpha: 0.8),
                ),
              ),
              Text(
                '${now.day}일',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 16.sp,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppTheme.grey400
                      : AppTheme.grey600,
                ),
              ),
            ],
          ),
          
          // 로그인/사용자 정보 영역
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              if (authProvider.isInitializing) {
                // 앱 시작 시 토큰 확인 중
                return SizedBox(
                  width: 20.w,
                  height: 20.h,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppTheme.primaryColor,
                  ),
                );
              }
              
              if (authProvider.isLoggedIn) {
                // 로그인 상태: 사용자 정보 표시
                return _buildUserInfo(context, authProvider);
              } else {
                // 로그아웃 상태: 로그인 버튼 표시
                return _buildLoginButton(context);
              }
            },
          ),
        ],
      ),
    );
  }

  /// 로그인 버튼 위젯
  Widget _buildLoginButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        debugPrint('🚀 [AUTH_BUTTON] 로그인 버튼 클릭 - 로그인 페이지로 이동');
        debugPrint('📍 [AUTH_BUTTON] 이동 경로: ${AppRoutes.login}');
        context.go(AppRoutes.login);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: AppTheme.primaryColor.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.login,
              size: 16.sp,
              color: AppTheme.primaryColor,
            ),
            SizedBox(width: 4.w),
            Text(
              '로그인',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 사용자 정보 메뉴 위젯
  Widget _buildUserInfo(BuildContext context, AuthProvider authProvider) {
    return PopupMenuButton<String>(
      offset: Offset(0, 40.h), // 메뉴를 아래쪽으로 조금 띄움
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: AppTheme.primaryColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 12.r,
              backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.2),
              child: Icon(
                Icons.person,
                size: 14.sp,
                color: AppTheme.primaryColor,
              ),
            ),
            SizedBox(width: 6.w),
            Text(
              authProvider.user?.nickname ?? '사용자',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: 4.w),
            Icon(
              Icons.keyboard_arrow_down,
              size: 16.sp,
              color: AppTheme.primaryColor.withValues(alpha: 0.7),
            ),
          ],
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'profile',
          child: Row(
            children: [
              Icon(
                Icons.person_outline,
                size: 18.sp,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withValues(alpha: 0.8)
                    : AppTheme.grey700,
              ),
              SizedBox(width: 8.w),
              Text(
                '내 정보',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withValues(alpha: 0.9)
                      : AppTheme.grey800,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'settings',
          child: Row(
            children: [
              Icon(
                Icons.settings_outlined,
                size: 18.sp,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withValues(alpha: 0.8)
                    : AppTheme.grey700,
              ),
              SizedBox(width: 8.w),
              Text(
                '설정',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withValues(alpha: 0.9)
                      : AppTheme.grey800,
                ),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              if (authProvider.isLoading)
                SizedBox(
                  width: 18.sp,
                  height: 18.sp,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.red.withValues(alpha: 0.7),
                  ),
                )
              else
                Icon(
                  Icons.logout,
                  size: 18.sp,
                  color: Colors.red.withValues(alpha: 0.7),
                ),
              SizedBox(width: 8.w),
              Text(
                authProvider.isLoading ? '로그아웃 중...' : '로그아웃',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.red.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
      onSelected: (value) async {
        debugPrint('🎯 [AUTH_MENU] 메뉴 선택: $value');
        
        switch (value) {
          case 'profile':
            // 프로필 페이지로 이동 (구현되면)
            debugPrint('👤 [AUTH_MENU] 프로필 페이지로 이동');
            // context.go(AppRoutes.profile);
            break;
          case 'settings':
            // 설정 페이지로 이동 (구현되면)
            debugPrint('⚙️ [AUTH_MENU] 설정 페이지로 이동');
            // context.go(AppRoutes.settings);
            break;
          case 'logout':
            if (!authProvider.isLoading) {
              debugPrint('🚪 [AUTH_MENU] 로그아웃 실행');
              await authProvider.logout();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('로그아웃되었습니다'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            }
            break;
        }
      },
    );
  }
}