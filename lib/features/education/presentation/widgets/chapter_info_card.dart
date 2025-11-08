import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../app/config/app_theme.dart';
import '../../../../app/core/widgets/app_card.dart';

/// 현재 진행 챕터 정보 카드 위젯
///
/// 챕터 제목, 설명, 진행률을 표시하는 재사용 가능한 카드 컴포넌트입니다.
class ChapterInfoCard extends StatelessWidget {
  const ChapterInfoCard({
    super.key,
    required this.title,
    required this.description,
    required this.progress,
    required this.completedLessons,
    required this.totalLessons,
  });

  final String title;
  final String description;
  final double progress; // 0.0 ~ 1.0
  final int completedLessons;
  final int totalLessons;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard.standard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 챕터 헤더
          Row(
            children: [
              Icon(
                Icons.play_circle_filled,
                color: Theme.of(context).primaryColor,
                size: 24.sp,
              ),
              SizedBox(width: 12.w),
              Text(
                '현재 진행 챕터',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.brightness == Brightness.dark
                      ? Colors.white
                      : AppTheme.grey900,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // 챕터 제목
          Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.brightness == Brightness.dark
                  ? Colors.white
                  : AppTheme.grey900,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),

          // 챕터 설명
          Text(
            description,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.color
                  ?.withValues(alpha: 0.6),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
