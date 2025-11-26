import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/config/app_routes.dart';
import '../../../../app/config/app_theme.dart';
import '../../../../app/core/services/aptitude_prompt_service.dart';
import '../../../../app/core/utils/theme_utils.dart';

/// 투자 성향 분석 유도 다이얼로그
///
/// 로그인 성공 후 성향 분석을 하지 않은 사용자에게 표시됩니다.
/// - "지금 하기" → AptitudeInitialScreen으로 이동
/// - "다음에" → 다이얼로그 닫기
class AptitudePromptDialog extends StatelessWidget {
  const AptitudePromptDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ThemeUtils.isDarkMode(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      backgroundColor: isDarkMode ? AppTheme.grey800 : Colors.white,
      contentPadding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 16.h),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 아이콘
          Container(
            width: 64.w,
            height: 64.h,
            decoration: BoxDecoration(
              color: isDarkMode
                  ? AppTheme.primaryColor.withValues(alpha: 0.2)
                  : AppTheme.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.insights_rounded,
              size: 36.sp,
              color: AppTheme.primaryColor,
            ),
          ),
          SizedBox(height: 20.h),

          // 제목
          Text(
            '투자 성향을 분석해보세요!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : AppTheme.grey900,
            ),
          ),
          SizedBox(height: 12.h),

          // 설명
          Text(
            '간단한 질문을 통해\n나에게 맞는 투자 스타일을 찾아보세요',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              color: isDarkMode ? AppTheme.grey400 : AppTheme.grey600,
              height: 1.4,
            ),
          ),
          SizedBox(height: 24.h),

          // 버튼 영역
          Row(
            children: [
              // 다음에 버튼
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    debugPrint('🔙 [APTITUDE_PROMPT] "다음에" 선택 - 로컬 저장');
                    await AptitudePromptService.setDismissed(true);
                    if (context.mounted) Navigator.of(context).pop();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor:
                        isDarkMode ? AppTheme.grey300 : AppTheme.grey700,
                    side: BorderSide(
                      color: isDarkMode ? AppTheme.grey600 : AppTheme.grey300,
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    '다음에',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),

              // 지금 하기 버튼
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    debugPrint('🎯 [APTITUDE_PROMPT] "지금 하기" 선택 - 성향분석으로 이동');
                    Navigator.of(context).pop();
                    context.push(AppRoutes.aptitude);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    '지금 하기',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
