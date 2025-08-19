import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../app/config/app_theme.dart';
import '../../../wrong_note/data/models/wrong_note_response.dart';

/// 오답노트 카드 위젯
class WrongNoteCard extends StatelessWidget {
  final List<WrongNoteItem> wrongNotes;
  final VoidCallback? onViewAllPressed;

  const WrongNoteCard({
    super.key,
    required this.wrongNotes,
    this.onViewAllPressed,
  });

  @override
  Widget build(BuildContext context) {
    final totalCount = wrongNotes.length;
    final completedCount = wrongNotes.where((note) => note.isRetried).length;
    final incompleteCount = totalCount - completedCount;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '오답노트',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: AppTheme.grey300,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.grey300.withValues(alpha: 0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatColumn(
                    context,
                    '전체',
                    totalCount.toString(),
                  ),
                ),
                Container(
                  width: 1.w,
                  height: 40.h,
                  color: AppTheme.grey300,
                ),
                Expanded(
                  child: _buildStatColumn(
                    context,
                    '재시도',
                    completedCount.toString(),
                  ),
                ),
                Container(
                  width: 1.w,
                  height: 40.h,
                  color: AppTheme.grey300,
                ),
                Expanded(
                  child: _buildStatColumn(
                    context,
                    '미완료',
                    incompleteCount.toString(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(BuildContext context, String label, String count) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.grey600,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          count,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
