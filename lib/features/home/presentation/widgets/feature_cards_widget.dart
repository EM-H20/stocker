import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/config/app_routes.dart';
import '../../../../app/config/app_theme.dart';
import 'feature_card_widget.dart';

/// 메인 대시보드 기능 카드들 위젯
class FeatureCardsWidget extends StatelessWidget {
  const FeatureCardsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 섹션 헤더
          Text(
            '기능 바로가기',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : AppTheme.grey900,
            ),
          ),
          
          SizedBox(height: 16.h),
          
          // 첫 번째 줄: 교육, 출석
          Row(
            children: [
              Expanded(
                child: FeatureCardWidget(
                  title: '교육',
                  icon: Icons.school_rounded,
                  color: AppTheme.primaryColor,
                  onTap: () => context.go(AppRoutes.education),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: FeatureCardWidget(
                  title: '출석',
                  icon: Icons.calendar_today_rounded,
                  color: AppTheme.successColor,
                  onTap: () => context.go(AppRoutes.attendance),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 12.h),
          
          // 두 번째 줄: 성향분석, 오답노트
          Row(
            children: [
              Expanded(
                child: FeatureCardWidget(
                  title: '성향분석',
                  icon: Icons.psychology_rounded,
                  color: AppTheme.warningColor,
                  onTap: () => context.go(AppRoutes.aptitude),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: FeatureCardWidget(
                  title: '오답노트',
                  icon: Icons.note_alt_rounded,
                  color: AppTheme.errorColor,
                  onTap: () => context.go(AppRoutes.wrongNote),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}