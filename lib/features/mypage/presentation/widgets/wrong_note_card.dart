import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/config/app_routes.dart';
import '../../../wrong_note/presentation/riverpod/wrong_note_notifier.dart';
import '../../../../app/config/app_theme.dart';
import '../../../../app/core/widgets/app_card.dart';

/// 오답노트 카드 위젯
class WrongNoteCard extends ConsumerWidget {
  const WrongNoteCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🔥 Riverpod: ref.watch로 상태 구독
    final wrongNoteState = ref.watch(wrongNoteNotifierProvider);
    final wrongNotes = wrongNoteState.wrongNotes;
    final totalCount = wrongNotes.length;
    final completedCount = wrongNotes
        .where((note) => wrongNoteState.retriedQuizIds.contains(note.quizId))
        .length;
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
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppTheme.primaryColor.withValues(alpha: 0.8)
                            : AppTheme.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          AppCard(
            padding: EdgeInsets.all(20.w),
            borderRadius: 12.0,
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
  }

  Widget _buildStatColumn(BuildContext context, String label, String count) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.color
                    ?.withValues(alpha: 0.7),
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
