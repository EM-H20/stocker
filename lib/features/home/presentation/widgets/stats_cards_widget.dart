import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../../app/config/app_theme.dart';
import '../../../attendance/presentation/provider/attendance_provider.dart';
import '../../../wrong_note/presentation/wrong_note_provider.dart';
import '../../../note/presentation/provider/note_provider.dart';
import '../../../aptitude/presentation/provider/aptitude_provider.dart';
import '../../../education/presentation/education_provider.dart';
import '../../../../app/core/utils/theme_utils.dart';

/// 메인 대시보드 통계 카드들 위젯
class StatsCardsWidget extends StatelessWidget {
  const StatsCardsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: _buildStatsCard(context), // 통계 카드만 남김
    );
  }

  /// 통계 정보 카드
  Widget _buildStatsCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: ThemeUtils.isDarkMode(context)
              ? AppTheme.grey700.withValues(alpha: 0.3)
              : AppTheme.grey300.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Consumer5<AttendanceProvider, WrongNoteProvider, NoteProvider,
          AptitudeProvider, EducationProvider>(
        builder: (context, attendanceProvider, wrongNoteProvider, noteProvider,
            aptitudeProvider, educationProvider, child) {
          final attendedDays =
              attendanceProvider.attendanceStatus.values.where((v) => v).length;
          final wrongNotes = wrongNoteProvider.wrongNotes.length;

          // 교육 진행률 데이터
          final completedChapters = educationProvider.getCompletedChapterCount();
          final totalChapters = educationProvider.chapters.length;
          final educationProgress = educationProvider.globalProgressPercentage;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '학습 현황',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: ThemeUtils.isDarkMode(context)
                              ? AppTheme.grey400
                              : AppTheme.grey600,
                        ),
                  ),
                  // 성향분석 결과가 있으면 표시
                  if (aptitudeProvider.myResult != null)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: AppTheme.warningColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        aptitudeProvider.myResult!.typeName,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.warningColor,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                ],
              ),

              SizedBox(height: 12.h),

              // Done 통계
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: AppTheme.successColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Icon(
                      Icons.calendar_today,
                      color: AppTheme.successColor,
                      size: 16.sp,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    '출석 $attendedDays일',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: ThemeUtils.isDarkMode(context)
                              ? Colors.white
                              : AppTheme.grey900,
                        ),
                  ),
                ],
              ),

              SizedBox(height: 8.h),

              // To-Do 통계
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: AppTheme.errorColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Icon(
                      Icons.error_outline,
                      color: AppTheme.errorColor,
                      size: 16.sp,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    '오답노트 $wrongNotes개',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: ThemeUtils.isDarkMode(context)
                              ? Colors.white
                              : AppTheme.grey900,
                        ),
                  ),
                ],
              ),

              // 교육 진행률 (로딩 중이 아니고 챕터가 있을 때만)
              if (!educationProvider.isLoadingChapters && totalChapters > 0) ...[
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: AppTheme.infoColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Icon(
                        Icons.school,
                        color: AppTheme.infoColor,
                        size: 16.sp,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '교육 진행률',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: ThemeUtils.isDarkMode(context)
                                          ? Colors.white
                                          : AppTheme.grey900,
                                    ),
                              ),
                              Text(
                                '${educationProgress.toStringAsFixed(1)}%',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.infoColor,
                                    ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4.h),
                          Row(
                            children: [
                              Expanded(
                                child: LinearProgressIndicator(
                                  value: educationProgress / 100,
                                  backgroundColor: ThemeUtils.isDarkMode(context)
                                      ? Colors.grey[700]
                                      : AppTheme.grey300.withValues(alpha: 0.5),
                                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.infoColor),
                                  minHeight: 3.h,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                '$completedChapters/$totalChapters',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: ThemeUtils.isDarkMode(context)
                                          ? AppTheme.grey400
                                          : AppTheme.grey600,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],

              // 성향분석 결과가 있으면 표시
              if (aptitudeProvider.myResult != null) ...[
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: AppTheme.warningColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Icon(
                        Icons.psychology,
                        color: AppTheme.warningColor,
                        size: 16.sp,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        '나의 투자성향: ${aptitudeProvider.myResult!.typeName}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: ThemeUtils.isDarkMode(context)
                                  ? Colors.white
                                  : AppTheme.grey700,
                            ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
