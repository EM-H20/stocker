import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../app/config/app_routes.dart';
import '../../../../app/config/app_theme.dart';
import '../../../../app/core/navigation/navigation_guard.dart';
import 'feature_card_widget.dart';
import '../../../../app/core/utils/theme_utils.dart';

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
            'Menu',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                  color: ThemeUtils.isDarkMode(context)
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
                  onTap: () {
                    debugPrint('🎓 [FEATURE_CARDS] 교육 카드 클릭 - 교육 페이지로 이동');
                    NavigationGuard.safeGo(context, AppRoutes.education);
                  },
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: FeatureCardWidget(
                  title: '출석',
                  icon: Icons.calendar_today_rounded,
                  color: AppTheme.successColor,
                  onTap: () {
                    debugPrint('📅 [FEATURE_CARDS] 출석 카드 클릭 - 출석 페이지로 이동');
                    NavigationGuard.safeGo(context, AppRoutes.attendance);
                  },
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
                  onTap: () {
                    debugPrint('🧠 [FEATURE_CARDS] 성향분석 카드 클릭 - 성향분석 페이지로 이동');
                    NavigationGuard.safeGo(context, AppRoutes.aptitude);
                  },
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: FeatureCardWidget(
                  title: '오답노트',
                  icon: Icons.note_alt_rounded,
                  color: AppTheme.errorColor,
                  onTap: () {
                    debugPrint('📝 [FEATURE_CARDS] 오답노트 카드 클릭 - 오답노트 페이지로 이동');
                    NavigationGuard.safeGo(context, AppRoutes.wrongNote);
                    // 네비게이션 히스토리 리포트 출력 (개발 모드에서만)
                    NavigationGuard.printNavigationReport();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
