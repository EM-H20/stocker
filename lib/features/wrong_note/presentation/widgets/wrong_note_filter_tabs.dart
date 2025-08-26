import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


import '../../../../app/config/app_theme.dart';// 

/// 챕터별로 오답을 필터링할 수 있는 탭 위젯
class WrongNoteFilterTabs extends StatelessWidget {
  final String selectedFilter;
  final Function(String) onFilterChanged;

  const WrongNoteFilterTabs({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filters = ['전체', '주식 기초', '기술적 분석', '기업 분석'];

    return Container(
      height: 50.h,
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = selectedFilter == filter;

          return GestureDetector(
            onTap: () => onFilterChanged(filter),
            child: Container(
              margin: EdgeInsets.only(right: 12.w),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              decoration: BoxDecoration(
                color:
                  isSelected
                      ? AppTheme.successColor
                      : (theme.brightness == Brightness.dark 
                          ? AppTheme.darkSurface 
                          : Colors.grey[50]),
                borderRadius: BorderRadius.circular(25.r),
                border: Border.all(
                  color:
                      isSelected 
                          ? AppTheme.successColor 
                          : (theme.brightness == Brightness.dark 
                              ? AppTheme.grey600.withValues(alpha: 0.5) 
                              : AppTheme.grey300.withValues(alpha: 0.7)),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.brightness == Brightness.dark 
                        ? Colors.black.withValues(alpha: 0.2) 
                        : Colors.grey.withValues(alpha: 0.15),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Text(
                filter,
                style: TextStyle(
                  color: isSelected 
                      ? Colors.white 
                      : (theme.brightness == Brightness.dark 
                          ? AppTheme.grey300 
                          : AppTheme.grey700),
                  fontSize: 14.sp,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
