import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../app/config/app_theme.dart';

/// 노트 섹션 위젯
class NoteSection extends StatelessWidget {
  final List<NoteItem> notes;
  final VoidCallback? onAddPressed;

  const NoteSection({
    super.key,
    required this.notes,
    this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '노트',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              GestureDetector(
                onTap: onAddPressed,
                child: Icon(
                  Icons.add,
                  size: 24.sp,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ...notes.map((note) => _buildNoteItem(context, note)),
        ],
      ),
    );
  }

  Widget _buildNoteItem(BuildContext context, NoteItem note) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppTheme.grey300,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.grey300.withValues(alpha: 0.2),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            note.title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            note.preview,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.grey600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// 노트 아이템 모델
class NoteItem {
  final String title;
  final String preview;
  final DateTime createdAt;

  const NoteItem({
    required this.title,
    required this.preview,
    required this.createdAt,
  });
}
