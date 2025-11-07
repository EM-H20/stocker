import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../utils/theme_utils.dart';
import '../../config/app_theme.dart';

/// 공통 에러 메시지 위젯
///
/// 앱 전체에서 일관된 에러 UI를 제공합니다.
/// 다양한 에러 타입과 재시도 기능을 지원합니다.
class ErrorMessageWidget extends StatelessWidget {
  /// 에러 제목 (선택사항)
  final String? title;

  /// 에러 메시지
  final String message;

  /// 에러 아이콘 (선택사항)
  final IconData? icon;

  /// 재시도 버튼 콜백 (선택사항)
  final VoidCallback? onRetry;

  /// 재시도 버튼 텍스트
  final String retryButtonText;

  /// 세로 여백 추가 여부
  final bool withVerticalPadding;

  const ErrorMessageWidget({
    super.key,
    this.title,
    required this.message,
    this.icon,
    this.onRetry,
    this.retryButtonText = '다시 시도',
    this.withVerticalPadding = true,
  });

  /// 네트워크 에러 위젯
  factory ErrorMessageWidget.network({
    String? title,
    String? message,
    VoidCallback? onRetry,
  }) {
    return ErrorMessageWidget(
      title: title ?? '네트워크 오류',
      message: message ?? '인터넷 연결을 확인하고 다시 시도해주세요.',
      icon: Icons.wifi_off_rounded,
      onRetry: onRetry,
    );
  }

  /// 인증 에러 위젯
  factory ErrorMessageWidget.auth({
    String? title,
    String? message,
    VoidCallback? onRetry,
  }) {
    return ErrorMessageWidget(
      title: title ?? '인증 오류',
      message: message ?? '로그인이 필요한 서비스입니다.',
      icon: Icons.lock_outline,
      onRetry: onRetry,
      retryButtonText: '로그인하기',
    );
  }

  /// 데이터 없음 위젯
  factory ErrorMessageWidget.empty({
    String? title,
    required String message,
    VoidCallback? onRetry,
  }) {
    return ErrorMessageWidget(
      title: title,
      message: message,
      icon: Icons.inbox_outlined,
      onRetry: onRetry,
      retryButtonText: '새로고침',
    );
  }

  /// 서버 에러 위젯
  factory ErrorMessageWidget.server({
    String? title,
    String? message,
    VoidCallback? onRetry,
  }) {
    return ErrorMessageWidget(
      title: title ?? '서버 오류',
      message: message ?? '일시적인 문제가 발생했습니다. 잠시 후 다시 시도해주세요.',
      icon: Icons.cloud_off_outlined,
      onRetry: onRetry,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 에러 아이콘
        if (icon != null)
          Icon(
            icon,
            size: 64.sp,
            color: AppTheme.errorColor,
          ),

        if (icon != null) SizedBox(height: 16.h),

        // 에러 제목
        if (title != null) ...[
          Text(
            title!,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: ThemeUtils.getColorByTheme(
                context,
                lightColor: AppTheme.grey900,
                darkColor: Colors.white,
              ),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
        ],

        // 에러 메시지
        Text(
          message,
          style: TextStyle(
            fontSize: 14.sp,
            color: ThemeUtils.getColorByTheme(
              context,
              lightColor: AppTheme.grey600,
              darkColor: AppTheme.grey400,
            ),
          ),
          textAlign: TextAlign.center,
        ),

        // 재시도 버튼
        if (onRetry != null) ...[
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: Text(retryButtonText),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: 24.w,
                vertical: 12.h,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
        ],
      ],
    );

    if (withVerticalPadding) {
      content = Padding(
        padding: EdgeInsets.symmetric(vertical: 40.h),
        child: content,
      );
    }

    return Center(child: content);
  }
}
