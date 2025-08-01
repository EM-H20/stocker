import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// 분리된 위젯들 import
import 'widgets/search_bar_widget.dart';
import 'widgets/recommended_chapter_card.dart';
import 'widgets/current_learning_card.dart';
import 'package:stocker/app/config/app_routes.dart';
import 'package:go_router/go_router.dart';

class EducationScreen extends StatefulWidget {
  const EducationScreen({super.key});

  @override
  State<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen> {
  // 현재 진행 학습 데이터
  Map<String, dynamic> currentLearning = {
    'title': '챕터 1: 주식 투자 기초',
    'description': '주식 시장의 기본 개념과 투자 원칙을 학습하여 안전한 투자의 기초를 다지는 챕터입니다.',
    'progress': 0.7,
    'progressText': '7/10 레슨 완료',
    'icon': Icons.trending_up,
  };

  // 추천 학습 챕터를 선택했을 때 현재 진행 학습으로 설정
  void _selectRecommendedContent(Map<String, dynamic> content) {
    setState(() {
      currentLearning = {
        'title': content['title'],
        'description': content['description'],
        'progress': 0.0, // 새로 시작하는 학습이므로 0%
        'progressText': '0/10 레슨 완료',
        'icon': content['icon'],
      };
    });
    debugPrint('선택된 학습: ${content['title']}');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // 주식 관련 Mock Data
    final stockEducationData = [
      {
        'title': '기술적 분석 기초',
        'description': '차트 패턴과 기술적 지표를 통한 주가 분석 방법',
        'icon': Icons.show_chart,
      },
      {
        'title': '기본적 분석 심화',
        'description': '재무제표 분석과 기업 가치 평가 방법',
        'icon': Icons.analytics,
      },
      {
        'title': '포트폴리오 관리',
        'description': '리스크 분산과 자산 배분 전략',
        'icon': Icons.pie_chart,
      },
      {
        'title': '파생상품 투자',
        'description': '옵션, 선물 등 파생상품의 이해와 활용',
        'icon': Icons.trending_up,
      },
      {
        'title': '글로벌 주식 투자',
        'description': '해외 주식 시장 분석과 투자 전략',
        'icon': Icons.public,
      },
      {
        'title': '암호화폐 투자',
        'description': '비트코인, 이더리움 등 암호화폐 투자 가이드',
        'icon': Icons.currency_bitcoin,
      },
      {
        'title': 'ESG 투자',
        'description': '지속가능한 투자와 ESG 기업 평가',
        'icon': Icons.eco,
      },
      {
        'title': '리스크 관리',
        'description': '투자 리스크 측정과 헤지 전략',
        'icon': Icons.security,
      },
    ];

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(18.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 검색바
              const SearchBarWidget(hintText: '챕터나 주제를 검색하세요'),
              SizedBox(height: 28.h),

              // 현재 진행 학습 카드
              CurrentLearningCard(
                title: currentLearning['title'],
                description: currentLearning['description'],
                progress: currentLearning['progress'],
                progressText: currentLearning['progressText'],
                onTheoryPressed: () => {context.go(AppRoutes.theory)},
                onQuizPressed:
                    () => debugPrint('${currentLearning['title']} 퀴즈 풀기 클릭'),
              ),
              SizedBox(height: 28.h),

              // 추천 학습 챕터 제목
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 5.w),
                child: Text(
                  '추천 학습 챕터',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 16.h),

              // 추천 학습 챕터 리스트
              ...stockEducationData.map((data) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.2.w), // 좌우 여백
                  child: RecommendedChapterCard(
                    title: data['title'] as String,
                    description: data['description'] as String,
                    icon: data['icon'] as IconData,
                    onTap: () => _selectRecommendedContent(data),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
