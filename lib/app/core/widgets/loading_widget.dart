import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../utils/theme_utils.dart';
import '../../config/app_theme.dart';

/// 공통 로딩 위젯
///
/// 앱 전체에서 일관된 로딩 UI를 제공합니다.
/// 다양한 스타일과 크기를 지원합니다.
class LoadingWidget extends StatelessWidget {
  /// 로딩 메시지 (선택사항)
  final String? message;

  /// 로딩 인디케이터 색상 (기본값: primaryColor)
  final Color? color;

  /// 크기 (small, medium, large)
  final LoadingSize size;

  /// 세로 여백 추가 여부
  final bool withVerticalPadding;

  const LoadingWidget({
    super.key,
    this.message,
    this.color,
    this.size = LoadingSize.medium,
    this.withVerticalPadding = true,
  });

  /// 작은 로딩 위젯 (인라인 사용)
  const LoadingWidget.small({
    super.key,
    this.message,
    this.color,
  })  : size = LoadingSize.small,
        withVerticalPadding = false;

  /// 큰 로딩 위젯 (전체 화면)
  const LoadingWidget.large({
    super.key,
    this.message,
    this.color,
  })  : size = LoadingSize.large,
        withVerticalPadding = true;

  @override
  Widget build(BuildContext context) {
    final indicatorSize = _getIndicatorSize();
    final effectiveColor = color ?? Theme.of(context).primaryColor;

    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: indicatorSize,
          height: indicatorSize,
          child: CircularProgressIndicator(
            color: effectiveColor,
            strokeWidth: _getStrokeWidth(),
          ),
        ),
        if (message != null) ...[
          SizedBox(height: 16.h),
          Text(
            message!,
            style: TextStyle(
              fontSize: _getFontSize(),
              color: ThemeUtils.getColorByTheme(
                context,
                lightColor: AppTheme.grey600,
                darkColor: AppTheme.grey400,
              ),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );

    if (withVerticalPadding) {
      content = Padding(
        padding: EdgeInsets.symmetric(vertical: _getVerticalPadding()),
        child: content,
      );
    }

    return content;
  }

  double _getIndicatorSize() {
    switch (size) {
      case LoadingSize.small:
        return 20.w;
      case LoadingSize.medium:
        return 32.w;
      case LoadingSize.large:
        return 48.w;
    }
  }

  double _getStrokeWidth() {
    switch (size) {
      case LoadingSize.small:
        return 2.0;
      case LoadingSize.medium:
        return 3.0;
      case LoadingSize.large:
        return 4.0;
    }
  }

  double _getFontSize() {
    switch (size) {
      case LoadingSize.small:
        return 12.sp;
      case LoadingSize.medium:
        return 14.sp;
      case LoadingSize.large:
        return 16.sp;
    }
  }

  double _getVerticalPadding() {
    switch (size) {
      case LoadingSize.small:
        return 20.h;
      case LoadingSize.medium:
        return 40.h;
      case LoadingSize.large:
        return 60.h;
    }
  }
}

/// 로딩 위젯 크기
enum LoadingSize {
  small,
  medium,
  large,
}
