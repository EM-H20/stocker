import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/auth_provider.dart';
import '../../../../app/config/app_routes.dart';

/// 개별 기능 카드 위젯 (로그인 체크 기능 포함)
class FeatureCardWidget extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const FeatureCardWidget({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return GestureDetector(
          onTap: () => _handleTap(context, authProvider),
          child: Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: color.withValues(alpha: 0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 아이콘
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    icon,
                    size: 28.sp,
                    color: color,
                  ),
                ),

                SizedBox(height: 12.h),

                // 제목
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: color,
                        fontSize: 14.sp,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 🔐 탭 처리 로직 (로그인 체크 포함)
  void _handleTap(BuildContext context, AuthProvider authProvider) {
    if (authProvider.isLoggedIn) {
      // 로그인된 경우: 원래 콜백 실행
      debugPrint('✅ [FEATURE_CARD] 로그인 상태 확인됨 - $title 기능 실행');
      onTap();
    } else {
      // 로그인 안된 경우: 로그인 안내 다이얼로그 표시
      debugPrint('🔒 [FEATURE_CARD] 비로그인 상태 - $title 기능 접근 차단');
      _showLoginRequiredDialog(context);
    }
  }

  /// 🔑 로그인 필요 다이얼로그
  void _showLoginRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Row(
          children: [
            Icon(
              Icons.lock_outline_rounded,
              color: color,
              size: 28.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              '로그인 필요',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '앗! 로그인 먼저 해주세요! 🔒',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              '$title 기능을 사용하려면 로그인이 필요해요.\n지금 로그인하시겠어요?',
              style: TextStyle(
                fontSize: 14.sp,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
        actions: [
          // 나중에 버튼
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              '나중에',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontSize: 14.sp,
              ),
            ),
          ),
          // 로그인하기 버튼
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              debugPrint('🚀 [LOGIN_DIALOG] 로그인 페이지로 이동');
              context.go(AppRoutes.login);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            ),
            child: Text(
              '로그인하기',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
