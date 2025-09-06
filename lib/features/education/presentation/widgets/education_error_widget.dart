import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../app/core/widgets/action_button.dart';
import '../../../../app/config/app_theme.dart';

/// 교육 기능 전용 에러 위젯
/// 이론, 퀴즈 등 교육 관련 화면에서 재사용 가능한 에러 UI
class EducationErrorWidget extends StatelessWidget {
  const EducationErrorWidget({
    super.key,
    required this.title,
    required this.errorMessage,
    required this.onRetry,
    this.retryButtonText = '다시 시도',
  });

  /// 에러 제목 (예: '이론을 불러오는데 실패했습니다', '퀴즈를 불러오는데 실패했습니다')
  final String title;

  /// 에러 상세 메시지
  final String errorMessage;

  /// 재시도 버튼 콜백
  final VoidCallback onRetry;

  /// 재시도 버튼 텍스트 (기본값: '다시 시도')
  final String retryButtonText;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 에러 아이콘
            Icon(
              Icons.error_outline,
              size: 64.sp,
              color: Colors.red,
            ),
            SizedBox(height: 16.h),

            // 에러 제목
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),

            // 에러 상세 메시지
            Text(
              errorMessage,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14.sp,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),

            // 재시도 버튼
            ActionButton(
              text: retryButtonText,
              icon: Icons.refresh,
              color: AppTheme.successColor, // 성공색은 고정 사용
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
