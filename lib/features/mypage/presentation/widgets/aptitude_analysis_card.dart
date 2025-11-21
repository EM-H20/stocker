import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/config/app_routes.dart';
import '../../../aptitude/presentation/riverpod/aptitude_notifier.dart';
import '../../../../app/core/widgets/app_card.dart';

/// 투자성향 분석 카드 위젯
class AptitudeAnalysisCard extends ConsumerWidget {
  const AptitudeAnalysisCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🔥 Riverpod: ref.watch로 상태 구독
    final aptitudeState = ref.watch(aptitudeNotifierProvider);
    final hasResult = aptitudeState.myResult != null;
    final result = aptitudeState.myResult;

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
          AppCard(
            padding: EdgeInsets.all(20.w),
            borderRadius: 12.0,
            onTap: () {
              context.push(AppRoutes.aptitude);
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
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        hasResult && result != null
                            ? result.typeDescription
                            : '나의 투자 성향을 알아보고 맞춤형 투자 전략을 확인해보세요',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
          ),
        ],
      ),
    );
  }
}
