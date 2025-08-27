import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/config/app_routes.dart';

/// 마이페이지 상단 프로필 헤더 위젯
class ProfileHeader extends StatelessWidget {
  final String nickname;
  final VoidCallback? onEditPressed;

  const ProfileHeader({
    super.key,
    required this.nickname,
    this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 홈 버튼
              IconButton(
                onPressed: () => context.go(AppRoutes.main),
                icon: Icon(
                  Icons.home,
                  size: 28.sp,
                  color: Theme.of(context).primaryColor,
                ),
                tooltip: '홈으로',
              ),
              // 제목
              Text(
                '마이 페이지',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              // 빈 공간 (균형 맞추기용)
              SizedBox(width: 48.w),
            ],
          ),
          SizedBox(height: 24.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                nickname,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 8.w),
              GestureDetector(
                onTap: onEditPressed,
                child: Icon(
                  Icons.edit,
                  size: 20.sp,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
