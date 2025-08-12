import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../app/config/app_theme.dart';

// 추천 학습 챕터 카드 위젯
class RecommendedChapterCard extends StatelessWidget {
  const RecommendedChapterCard({
    super.key,
    required this.title,
    required this.description,
    this.icon = Icons.school,
    this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 추천 학습 챕터 카드 위젯
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      color: AppTheme.darkSurface,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.2),
          child: Icon(icon, color: AppTheme.primaryColor),
        ),
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          description,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.grey400,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: AppTheme.grey500,
          size: 16.sp,
        ),
        onTap: onTap,
      ),
    );
  }
}
