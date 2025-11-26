import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../app/config/app_theme.dart';

/// 교육 화면용 검색바 위젯
///
/// 재사용 가능한 검색바 컴포넌트로, 힌트 텍스트와 스타일을
/// 커스터마이징할 수 있습니다.
/// 검색어 입력 시 클리어(X) 버튼이 표시됩니다.
class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({
    super.key,
    this.hintText = '검색',
    this.onChanged,
    this.onClear,
    this.controller,
    this.showClearButton = true,
  });

  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final TextEditingController? controller;
  final bool showClearButton;

  /// 클리어 버튼 위젯 빌드
  Widget? _buildClearButton(BuildContext context) {
    if (!showClearButton || controller == null) return null;

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller!,
      builder: (context, value, child) {
        // 텍스트가 비어있으면 클리어 버튼 숨김
        if (value.text.isEmpty) return const SizedBox.shrink();

        return IconButton(
          icon: Icon(
            Icons.clear,
            color: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.color
                ?.withValues(alpha: 0.6),
            size: 20.sp,
          ),
          onPressed: () {
            controller?.clear();
            onClear?.call();
          },
          splashRadius: 20.r,
          tooltip: '검색어 지우기',
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;

    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: theme.textTheme.bodyMedium?.copyWith(
          color: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.color
              ?.withValues(alpha: 0.6),
        ),
        prefixIcon: Icon(
          Icons.search,
          color: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.color
              ?.withValues(alpha: 0.6),
          size: 20.sp,
        ),
        suffixIcon: _buildClearButton(context),
        filled: true,
        fillColor: Theme.of(context).cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: isDarkTheme
              ? BorderSide.none
              : BorderSide(color: AppTheme.grey300, width: 1.w),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide:
              BorderSide(color: Theme.of(context).primaryColor, width: 2.w),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: isDarkTheme
              ? BorderSide.none
              : BorderSide(color: AppTheme.grey300, width: 1.w),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      ),
      style: theme.textTheme.bodyMedium,
    );
  }
}
