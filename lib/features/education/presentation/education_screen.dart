import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
// 분리된 위젯들 import
import 'widgets/search_bar_widget.dart';
import 'widgets/recommended_chapter_card.dart';
import 'widgets/current_learning_card.dart';
import 'widgets/global_progress_bar.dart';
import 'package:stocker/app/config/app_routes.dart';
import 'package:go_router/go_router.dart';
import 'education_provider.dart';

class EducationScreen extends StatefulWidget {
  const EducationScreen({super.key});

  @override
  State<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen> {
  @override
  void initState() {
    super.initState();
    // 화면 로드 시 챕터 목록을 가져옴
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<EducationProvider>();
      // 🧹 캐시 삭제 및 강제 새로고침으로 mock 데이터 제거
      debugPrint('🧹 [EDUCATION_SCREEN] 캐시 삭제 및 강제 새로고침 시작');
      provider.clearCache().then((_) {
        debugPrint('🔄 [EDUCATION_SCREEN] 캐시 삭제 완료, 강제 새로고침 실행');
        provider.loadChapters(forceRefresh: true);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // 주식 관련 Mock Data
    // 하드코딩된 더미 데이터 제거 - Provider에서 실제 데이터 사용

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 검색바 (상단으로 이동)
              const SearchBarWidget(hintText: '챕터나 주제를 검색하세요'),
              SizedBox(height: 16.h),

              // 전체 진행률 바 (재사용 가능한 컴포넌트)
              const GlobalProgressBar(),
              SizedBox(height: 12.h),

              // 현재 진행 학습 카드 - Provider 데이터 사용
              Consumer<EducationProvider>(
                builder: (context, provider, child) {
                  // 로딩 중이거나 챕터가 없는 경우 기본 카드 표시
                  if (provider.isLoadingChapters || provider.chapters.isEmpty) {
                    return CurrentLearningCard(
                      title: '학습 준비 중...',
                      description: '챕터 정보를 불러오고 있습니다.',
                      onTheoryPressed: null,
                      onQuizPressed: null,
                    );
                  }

                  // 현재 진행 중인 챕터 찾기 (미완료 챕터 중 첫 번째)
                  final currentChapter = provider.chapters
                          .where((chapter) => !chapter.isTheoryCompleted)
                          .isNotEmpty
                      ? provider.chapters
                          .where((chapter) => !chapter.isTheoryCompleted)
                          .first
                      : provider.chapters.first;

                  return CurrentLearningCard(
                    title: currentChapter.title,
                    description: '현재 진행 중인 챕터입니다. 이론 학습을 완료한 후 퀴즈에 도전하세요.',
                    onTheoryPressed: () {
                      provider.enterTheory(currentChapter.id);
                      context.go(AppRoutes.theory);
                    },
                    onQuizPressed: () {
                      // 퀴즈 화면으로 이동
                      context.go(AppRoutes.quiz);
                    },
                  );
                },
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

              // 추천 학습 챕터 리스트 - Provider 데이터 사용
              Consumer<EducationProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoadingChapters) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (provider.chaptersError != null) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48.sp,
                            color: colorScheme.error,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            '챕터 로드 실패',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: colorScheme.error,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            provider.chaptersError!,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color:
                                  colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                          SizedBox(height: 16.h),
                          ElevatedButton(
                            onPressed: () {
                              debugPrint('🔄 [EDUCATION_SCREEN] 재시도 버튼 클릭');
                              provider.clearCache().then((_) {
                                provider.loadChapters(forceRefresh: true);
                              });
                            },
                            child: Text('다시 시도'),
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: provider.chapters.map((chapter) {
                      // 챕터 상태에 따른 설명과 아이콘 결정
                      String description;
                      IconData icon;
                      
                      if (chapter.isChapterCompleted) {
                        description = '챕터 완료! 🎉 (이론 ✓, 퀴즈 ✓)';
                        icon = Icons.stars;
                      } else if (chapter.isTheoryCompleted && chapter.isQuizCompleted) {
                        description = '챕터 완료 처리 중... ⏳';
                        icon = Icons.hourglass_empty;
                      } else if (chapter.isTheoryCompleted) {
                        description = '이론 완료 ✓ (퀴즈 진행 필요)';
                        icon = Icons.quiz_outlined;
                      } else if (chapter.isQuizCompleted) {
                        description = '퀴즈 완료 ✓ (이론 진행 필요)';
                        icon = Icons.school_outlined;
                      } else {
                        description = '이론 학습을 시작하세요';
                        icon = Icons.play_circle_outline;
                      }
                      
                      return RecommendedChapterCard(
                        title: chapter.title,
                        description: description,
                        icon: icon,
                        onTap: () {
                          provider.enterTheory(chapter.id);
                          context.go(AppRoutes.theory);
                        },
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
