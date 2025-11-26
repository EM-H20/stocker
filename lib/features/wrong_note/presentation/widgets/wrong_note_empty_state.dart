import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/config/app_theme.dart';
import '../../../../app/core/utils/theme_utils.dart';

/// 오답노트 빈 상태 위젯
///
/// 오답이 없을 때 표시되는 안내 화면
class WrongNoteEmptyState extends StatelessWidget {
  final VoidCallback onGoToQuiz;

  const WrongNoteEmptyState({
    super.key,
    required this.onGoToQuiz,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.quiz_outlined,
            size: 64.sp,
            color: ThemeUtils.isDarkMode(context)
                ? AppTheme.grey600
                : AppTheme.grey500,
          ),
          SizedBox(height: 16.h),
          Text(
            '오답이 없습니다',
            style: TextStyle(
              color: ThemeUtils.isDarkMode(context)
                  ? AppTheme.grey400
                  : AppTheme.grey700,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '퀴즈를 풀고 틀린 문제들을 복습해보세요',
            style: TextStyle(
              color: ThemeUtils.isDarkMode(context)
                  ? AppTheme.grey500
                  : AppTheme.grey600,
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }
}
