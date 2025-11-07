import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/config/app_routes.dart';
import '../../../../app/config/app_theme.dart';
import '../../../../app/core/widgets/action_button.dart';
import '../../../../app/core/utils/theme_utils.dart';

/// 퀴즈 결과 액션 버튼들 위젯
class QuizResultActionsWidget extends StatelessWidget {
  final int chapterId;

  const QuizResultActionsWidget({
    super.key,
    required this.chapterId,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ThemeUtils.isDarkMode(context);

    return Column(
      children: [
        // 다시 풀기 버튼
        ActionButton(
          text: '다시 풀기',
          icon: Icons.refresh,
          color: AppTheme.successColor,
          onPressed: () => context.go('${AppRoutes.quiz}?chapterId=$chapterId'),
        ),

        SizedBox(height: 12.h),

        // 교육 탭으로 돌아가기 버튼
        ActionButton(
          text: '교육 탭으로 돌아가기',
          icon: Icons.home,
          color: isDarkMode ? AppTheme.grey600 : AppTheme.grey500,
          onPressed: () => context.go(AppRoutes.education),
        ),
      ],
    );
  }
}
