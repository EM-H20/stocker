import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../education_provider.dart';
import '../../../../app/config/app_theme.dart';

/// 전체 학습 진행률 바 위젯
/// 교육 메인 화면과 이론 화면에서 재사용 가능한 컴포넌트
class GlobalProgressBar extends StatelessWidget {
  /// 여백 설정
  final EdgeInsets? margin;

  const GlobalProgressBar({super.key, this.margin});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDarkTheme = theme.brightness == Brightness.dark;

    return Consumer<EducationProvider>(
      builder: (context, provider, child) {
        // 로딩 중이거나 챕터가 없는 경우
        if (provider.isLoadingChapters || provider.chapters.isEmpty) {
          return Container(
            margin: margin ?? EdgeInsets.only(bottom: 16.h),
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12.r),
              border: isDarkTheme
                  ? null
                  : Border.all(
                      color: colorScheme.outline.withValues(alpha: 0.2),
                    ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.school_outlined,
                  color: isDarkTheme
                      ? AppTheme.successColor
                      : Theme.of(context).primaryColor,
                  size: 20.sp,
                ),
                SizedBox(width: 12.w),
                Text(
                  '학습 준비 중...',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDarkTheme ? Colors.white : colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          );
        }

        // 진행률 데이터가 있는 경우
        return Container(
          margin: margin ?? EdgeInsets.only(bottom: 16.h),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12.r),
            border: isDarkTheme
                ? null
                : Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.2),
                  ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더 (제목과 백분율)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.school,
                        color: isDarkTheme
                            ? const Color(0xFF4CAF50)
                            : colorScheme.primary,
                        size: 20.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        '전체 학습 진행률',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: isDarkTheme ? Colors.white : AppTheme.grey900,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: isDarkTheme
                          ? AppTheme.successColor.withValues(alpha: 0.2)
                          : Theme.of(context)
                              .primaryColor
                              .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      '${provider.globalProgressPercentage.toStringAsFixed(1)}%',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: isDarkTheme
                            ? const Color(0xFF4CAF50)
                            : colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),

              // 진행률 바
              LinearProgressIndicator(
                value: provider.globalProgressRatio,
                backgroundColor: isDarkTheme
                    ? Colors.grey[700]
                    : colorScheme.outline.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(
                  isDarkTheme
                      ? AppTheme.successColor
                      : Theme.of(context).primaryColor,
                ),
                minHeight: 6.h,
              ),
              SizedBox(height: 8.h),

              // 상세 진행 상황
              Text(
                provider.detailedProgressSummary,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.color
                      ?.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
