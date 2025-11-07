import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../app/config/app_theme.dart';
import '../../../../app/core/widgets/action_button.dart';
import '../../../../app/core/utils/theme_utils.dart';

/// 이론 페이지 하단 네비게이션 위젯
class TheoryNavigationWidget extends StatelessWidget {
  final int currentIndex;
  final int totalPages;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final VoidCallback? onComplete;

  const TheoryNavigationWidget({
    super.key,
    required this.currentIndex,
    required this.totalPages,
    this.onPrevious,
    this.onNext,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ThemeUtils.isDarkMode(context);

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.darkSurface : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDarkMode ? AppTheme.grey800 : AppTheme.grey200,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // 이전 버튼
          if (currentIndex > 0)
            Expanded(
              child: ActionButton(
                text: '이전',
                icon: Icons.arrow_back,
                color: isDarkMode ? AppTheme.grey600 : AppTheme.grey500,
                onPressed: onPrevious ?? () {},
              ),
            ),

          if (currentIndex > 0) SizedBox(width: 12.w),

          // 다음/완료 버튼
          if (currentIndex < totalPages - 1)
            Expanded(
              child: ActionButton(
                text: '다음',
                icon: Icons.arrow_forward,
                color: AppTheme.successColor,
                onPressed: onNext ?? () {},
              ),
            )
          else
            Expanded(
              child: ActionButton(
                text: '이론 완료',
                icon: Icons.check_circle,
                color: AppTheme.successColor,
                onPressed: onComplete ?? () {},
              ),
            ),
        ],
      ),
    );
  }
}
