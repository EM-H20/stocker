import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../app/config/app_theme.dart';
import '../../../../app/core/widgets/action_button.dart';

/// 퀴즈 하단 네비게이션 위젯
class QuizNavigationWidget extends StatelessWidget {
  final bool showPrevious;
  final VoidCallback? onPrevious;
  final Widget actionButton;

  const QuizNavigationWidget({
    super.key,
    required this.showPrevious,
    this.onPrevious,
    required this.actionButton,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDarkMode 
            ? AppTheme.darkSurface 
            : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDarkMode 
                ? AppTheme.grey800 
                : AppTheme.grey200,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // 이전 버튼
          if (showPrevious) ...[
            Expanded(
              child: ActionButton(
                text: '이전',
                icon: Icons.arrow_back,
                color: isDarkMode 
                    ? AppTheme.grey700 
                    : AppTheme.grey500,
                onPressed: onPrevious ?? () {},
              ),
            ),
            SizedBox(width: 12.w),
          ],

          // 액션 버튼 (제출/다음/완료)
          Expanded(child: actionButton),
        ],
      ),
    );
  }
}
