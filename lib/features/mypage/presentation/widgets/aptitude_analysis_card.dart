import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/config/app_routes.dart';
import '../../../aptitude/presentation/provider/aptitude_provider.dart';
import '../../../../app/core/widgets/app_card.dart';

/// 투자성향 분석 카드 위젯
class AptitudeAnalysisCard extends StatelessWidget {
  const AptitudeAnalysisCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '투자성향 분석',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(height: 12.h),
          Consumer<AptitudeProvider>(
            builder: (context, aptitudeProvider, child) {
              final hasResult = aptitudeProvider.myResult != null;
              final result = aptitudeProvider.myResult;

              return AppCard(
                padding: EdgeInsets.all(20.w),
                borderRadius: 12.0,
                onTap: () {
                  context.go(AppRoutes.aptitude);
                },
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hasResult && result != null
                                ? result.typeName
                                : '성향 분석을 해보세요!',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            hasResult && result != null
                                ? result.typeDescription
                                : '나의 투자 성향을 알아보고 맞춤형 투자 전략을 확인해보세요',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.color
                                          ?.withValues(alpha: 0.7),
                                    ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      hasResult ? Icons.refresh : Icons.arrow_forward_ios,
                      size: 16.sp,
                      color: Theme.of(context).primaryColor,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
