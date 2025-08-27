import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../../app/config/app_theme.dart';
import '../../../attendance/presentation/provider/attendance_provider.dart';
import '../../../wrong_note/presentation/wrong_note_provider.dart';
import '../../../note/presentation/provider/note_provider.dart';
import '../../../aptitude/presentation/provider/aptitude_provider.dart';

/// 메인 대시보드 통계 카드들 위젯
class StatsCardsWidget extends StatelessWidget {
  const StatsCardsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: [
          // 날짜 카드
          Expanded(
            flex: 1,
            child: _buildDateCard(context),
          ),
          SizedBox(width: 16.w),
          
          // 통계 카드
          Expanded(
            flex: 1,
            child: _buildStatsCard(context),
          ),
        ],
      ),
    );
  }

  /// 날짜 표시 카드
  Widget _buildDateCard(BuildContext context) {
    final now = DateTime.now();
    
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
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
      child: Column(
        children: [
          Text(
            '${now.month}월',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppTheme.grey400
                  : AppTheme.grey600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '${now.day}일',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontSize: 48.sp,
              fontWeight: FontWeight.w300,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : AppTheme.grey900,
            ),
          ),
        ],
      ),
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
          color: Theme.of(context).brightness == Brightness.dark
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
      child: Consumer4<AttendanceProvider, WrongNoteProvider, NoteProvider, AptitudeProvider>(
        builder: (context, attendanceProvider, wrongNoteProvider, noteProvider, aptitudeProvider, child) {
          final attendedDays = attendanceProvider.attendanceStatus.values.where((v) => v).length;
          final wrongNotes = wrongNoteProvider.wrongNotes.length;
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더
              Text(
                '출석 교육',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppTheme.grey400
                      : AppTheme.grey600,
                ),
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
                      Icons.check_circle,
                      color: AppTheme.successColor,
                      size: 16.sp,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    '$attendedDays Done',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).brightness == Brightness.dark
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
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Icon(
                      Icons.edit_note,
                      color: AppTheme.primaryColor,
                      size: 16.sp,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    '$wrongNotes To-Do',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : AppTheme.grey900,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}