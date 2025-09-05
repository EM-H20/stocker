import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 성향 분석 퀴즈 화면에서 사용될 답변 선택 버튼 위젯
///
/// "매우 그렇다", "그렇다" 등의 선택지를 표시하며,
/// 선택되었을 때 시각적인 피드백을 줍니다.
class QuizOptionButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onPressed;

  const QuizOptionButton({
    super.key,
    required this.text,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    // 앱의 전체적인 테마를 가져옵니다.
    final theme = Theme.of(context);

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: Size(double.infinity, 50.h), // 버튼의 최소 크기
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 24.w),
        // isSelected 값에 따라 배경색을 다르게 표시
        backgroundColor: isSelected
            ? theme.colorScheme.primary.withValues(alpha: 0.1)
            : Colors.transparent,
        // isSelected 값에 따라 테두리 스타일을 다르게 표시
        side: BorderSide(
          color: isSelected
              ? theme.colorScheme.primary
              : (theme.brightness == Brightness.light
                  ? Colors.grey[400]!
                  : Colors.grey[600]!),
          width: isSelected ? 2.0 : 1.0,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16.sp,
          // isSelected 값에 따라 글자 두께를 다르게 표시
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          // isSelected 값에 따라 글자 색상을 다르게 표시
          color: isSelected
              ? theme.colorScheme.primary
              : theme.textTheme.bodyLarge?.color,
        ),
      ),
    );
  }
}
