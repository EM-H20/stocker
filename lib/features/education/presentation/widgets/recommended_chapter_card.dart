import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../app/config/app_theme.dart';
import '../../../../app/core/widgets/app_card.dart';

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
    return AppCard(
      padding: EdgeInsets.all(12.w),
      margin: EdgeInsets.only(bottom: 12.h),
      backgroundColor: theme.brightness == Brightness.dark
          ? AppTheme.darkSurface
          : theme.cardColor,
      borderColor: theme.brightness == Brightness.dark
          ? AppTheme.grey600.withValues(alpha: 0.3)
          : AppTheme.grey300.withValues(alpha: 0.5),
      borderRadius: 12.0,
      onTap: onTap,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(
          backgroundColor: Theme.of(
            context,
          ).primaryColor.withValues(alpha: 0.2),
          child: Icon(
            icon,
            color: theme.brightness == Brightness.dark
                ? Colors.white
                : Theme.of(context).primaryColor,
          ),
        ),
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.brightness == Brightness.dark
                ? Colors.white
                : AppTheme.grey900,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          description,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.brightness == Brightness.dark
                ? AppTheme.grey400
                : AppTheme.grey600,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: theme.brightness == Brightness.dark
              ? AppTheme.grey500
              : AppTheme.grey600,
          size: 16.sp,
        ),
      ),
    );
  }
}
