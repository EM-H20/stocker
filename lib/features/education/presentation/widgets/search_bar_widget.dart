import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../app/config/app_theme.dart';

/// 교육 화면용 검색바 위젯
///
/// 재사용 가능한 검색바 컴포넌트로, 힌트 텍스트와 스타일을
/// 커스터마이징할 수 있습니다.
class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({
    super.key,
    this.hintText = '검색',
    this.onChanged,
    this.controller,
  });

  final String hintText;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: theme.textTheme.bodyMedium?.copyWith(
          color: AppTheme.grey500,
        ),
        prefixIcon: Icon(
          Icons.search,
          color: AppTheme.grey500,
          size: 20.sp,
        ),
        filled: true,
        fillColor: AppTheme.darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppTheme.primaryColor, width: 2.w),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      ),
      style: theme.textTheme.bodyMedium,
    );
  }
}
