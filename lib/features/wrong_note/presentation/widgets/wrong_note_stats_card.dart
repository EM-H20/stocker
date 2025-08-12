import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/config/app_theme.dart';
import '../wrong_note_screen.dart';

/// 오답노트 상단 통계 카드 위젯
///
/// 전체 오답 수, 재시도 완료 수, 미완료 수를 표시하는 카드
class WrongNoteStatsCard extends StatelessWidget {
  final List<WrongAnswerItem> wrongAnswers;

  const WrongNoteStatsCard({super.key, required this.wrongAnswers});

  @override
  Widget build(BuildContext context) {
    final totalWrong = wrongAnswers.length;
    final retriedCount = wrongAnswers.where((item) => item.isRetried).length;
    final pendingCount = totalWrong - retriedCount;

    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          // 아이콘
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppTheme.successColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.quiz_outlined,
              color: AppTheme.successColor,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 16.w),

          // 통계 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '오답 현황',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    _buildStatItem('전체', totalWrong, AppTheme.successColor),
                    SizedBox(width: 16.w),
                    _buildStatItem('재시도', retriedCount, AppTheme.infoColor),
                    SizedBox(width: 16.w),
                    _buildStatItem('미완료', pendingCount, AppTheme.warningColor),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 통계 아이템
  Widget _buildStatItem(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            color: color,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 12.sp)),
      ],
    );
  }
}
