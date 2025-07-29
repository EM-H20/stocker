import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 추천 학습 컨텐츠 카드 위젯
///
/// 추천 학습 컨텐츠를 표시하는 재사용 가능한 리스트 타일 카드입니다.
class RecommendedContentCard extends StatelessWidget {
  const RecommendedContentCard({
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
    final colorScheme = theme.colorScheme;

    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: colorScheme.primaryContainer,
          child: Icon(icon, color: colorScheme.onPrimaryContainer),
        ),
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          description,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: colorScheme.onSurface.withOpacity(0.5),
          size: 16.sp,
        ),
        onTap: onTap,
      ),
    );
  }
}
