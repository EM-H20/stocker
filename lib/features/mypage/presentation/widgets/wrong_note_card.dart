import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/config/app_routes.dart';
import '../../../wrong_note/presentation/wrong_note_provider.dart';

/// 오답노트 카드 위젯
class WrongNoteCard extends StatelessWidget {
  const WrongNoteCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WrongNoteProvider>(
      builder: (context, wrongNoteProvider, child) {
        final wrongNotes = wrongNoteProvider.wrongNotes;
        final totalCount = wrongNotes.length;
        final completedCount = wrongNotes.where((note) => wrongNoteProvider.retriedQuizIds.contains(note.quizId)).length;
        final incompleteCount = totalCount - completedCount;

        return Container(
          margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '오답노트',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.go(AppRoutes.wrongNote),
                    child: Text(
                      '전체 보기',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: Theme.of(context).dividerColor,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
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
                      color: Theme.of(context).dividerColor,
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
                      color: Theme.of(context).dividerColor,
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
      },
    );
  }

  Widget _buildStatColumn(BuildContext context, String label, String count) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
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
