import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../app/config/app_routes.dart';
import '../provider/aptitude_provider.dart';
import '../widgets/master_portfolio_chart.dart';
import '../../domain/model/aptitude_result.dart';

class AptitudeResultScreen extends StatelessWidget {
  /// 이 화면이 '나의 결과'를 보여주는지, '다른 성향'을 보여주는지 구분하는 플래그
  final bool isMyResult;

  const AptitudeResultScreen({super.key, this.isMyResult = true});

  @override
  Widget build(BuildContext context) {
    final AptitudeResult? result =
        context.select((AptitudeProvider p) => p.currentResult ?? p.myResult);

    if (result == null) {
      return const Scaffold(
        body: Center(child: Text('분석 결과가 없습니다.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isMyResult ? '나의 투자 성향 결과' : result.typeName),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 성향 분석 결과 제목
            Text(
              result.typeName,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.h),
            Text(
              result.typeDescription,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 16.sp,
                  color: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color
                      ?.withValues(alpha: 0.8),
                  height: 1.6),
            ),
            SizedBox(height: 48.h),

            // 투자 거장 섹션
            _buildSectionTitle('나와 비슷한 성향의 투자 거장'),
            SizedBox(height: 24.h),
            Card(
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  children: [
                    // 거장 프로필 이미지
                    CircleAvatar(
                      radius: 50.r,
                      backgroundImage: NetworkImage(result.master.imageUrl),
                      backgroundColor: Colors.grey[300],
                      child: result.master.imageUrl.contains('placehold')
                          ? Icon(
                              Icons.person,
                              size: 50.r,
                              color: Colors.grey[600],
                            )
                          : null,
                    ),
                    SizedBox(height: 16.h),

                    // 거장 이름
                    Text(
                      result.master.name,
                      style: TextStyle(
                          fontSize: 22.sp, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8.h),

                    // 거장 설명
                    Text(
                      result.master.description,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.sp,
                        height: 1.5,
                        color: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.color
                            ?.withValues(alpha: 0.7),
                      ),
                    ),
                    SizedBox(height: 32.h),

                    // 포트폴리오 제목
                    Text(
                      '포트폴리오 예시',
                      style: TextStyle(
                          fontSize: 18.sp, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16.h),

                    // 포트폴리오 차트
                    MasterPortfolioChart(portfolio: result.master.portfolio),
                  ],
                ),
              ),
            ),
            SizedBox(height: 48.h),

            // 교육 추천 섹션 (챕터명만 표시)
            _buildSectionTitle('이런 교육은 어때요?'),
            SizedBox(height: 24.h),
            _buildEducationRecommendations(context, result.typeName),

            SizedBox(height: 32.h),

            // 나의 결과를 볼 때만 하단 버튼들이 보이도록 처리
            if (isMyResult) ...[
              ElevatedButton(
                onPressed: () {
                  context.push(AppRoutes.aptitudeTypesList);
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  '다른 성향 보러가기',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              OutlinedButton(
                onPressed: () {
                  debugPrint('🔄 [APTITUDE_RESULT] 재검사하기 버튼 클릭');
                  context.pushReplacement(AppRoutes.aptitudeQuiz);
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  '재검사하기',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold),
    );
  }

  /// 성향에 따른 교육 추천 위젯 (챕터명만 표시)
  Widget _buildEducationRecommendations(BuildContext context, String typeName) {
    final recommendations = _getRecommendationsByType(typeName);

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.school,
                color: Theme.of(context).colorScheme.primary,
                size: 24.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                '추천 학습 챕터',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // 추천 챕터 목록
          ...recommendations.map((chapter) => Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 6.w,
                      height: 6.h,
                      margin: EdgeInsets.only(top: 8.h, right: 12.w),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        chapter,
                        style: TextStyle(
                          fontSize: 15.sp,
                          height: 1.4,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                    ),
                  ],
                ),
              )),

          SizedBox(height: 16.h),

          // 안내 메시지
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .secondary
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16.sp,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    '교육 탭에서 자세한 학습을 진행해보세요!',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 성향별 추천 챕터 목록 반환
  List<String> _getRecommendationsByType(String typeName) {
    switch (typeName) {
      case '단기 집중 투자자':
      case '공격적 투자형':
        return [
          '2배 ETF 투자 전략',
          '급등주 발굴 기법',
          '단기 차트 분석법',
          '위험 관리와 손절 전략',
        ];
      case '안정 추구형':
      case '보수적 투자형':
        return [
          '안전한 채권 투자',
          '배당주 투자 전략',
          '원금보장 상품 이해',
          '장기 분산투자',
        ];
      case '위험 중립형':
      case '균형 투자형':
        return [
          '포트폴리오 구성 전략',
          '리밸런싱 기법',
          '혼합형 펀드 이해',
          '자산배분 전략',
        ];
      case '장기 성장형':
        return [
          '성장주 분석법',
          '복리 투자 전략',
          '장기 투자 마인드셋',
          '글로벌 주식 투자',
        ];
      default:
        return [
          '주식 기초 개념',
          '투자 첫걸음',
          '시장 분석 방법',
          '리스크 관리',
        ];
    }
  }
}
