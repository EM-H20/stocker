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
      context.read<EducationProvider>().loadChapters();
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
          padding: EdgeInsets.all(18.w),
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
                  final currentChapter =
                      provider.chapters
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
                      child: Text(
                        '챕터 로드 실패: ${provider.chaptersError}',
                        style: TextStyle(color: colorScheme.error),
                      ),
                    );
                  }

                  return Column(
                    children:
                        provider.chapters.map((chapter) {
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4.2.w),
                            child: RecommendedChapterCard(
                              title: chapter.title,
                              description:
                                  chapter.isTheoryCompleted
                                      ? '이론 학습 완료 ✓'
                                      : '이론 학습을 시작하세요',
                              icon:
                                  chapter.isTheoryCompleted
                                      ? Icons.check_circle
                                      : Icons.play_circle_outline,
                              onTap: () {
                                provider.enterTheory(chapter.id);
                                context.go(AppRoutes.theory);
                              },
                            ),
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
