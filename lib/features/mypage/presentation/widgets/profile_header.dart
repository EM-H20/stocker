import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
          // 제목
          Center(
            child: Text(
              '마이페이지',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
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
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
