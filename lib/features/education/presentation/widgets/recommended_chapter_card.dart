import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
      color: Theme.of(context).cardColor,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
          child: Icon(icon, color: Theme.of(context).primaryColor),
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
            color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
          size: 16.sp,
        ),
        onTap: onTap,
      ),
    );
  }
}
