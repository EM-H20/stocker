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
import '../../../app/core/widgets/loading_widget.dart';
import '../../../app/core/widgets/error_message_widget.dart';

class EducationScreen extends StatefulWidget {
  const EducationScreen({super.key});

  @override
  State<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

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
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// CurrentLearningCard로 부드럽게 스크롤
  void _scrollToCurrentLearningCard() {
    // CurrentLearningCard는 페이지 상단에서 약 100픽셀 정도 위치
    // 검색바(약 50h) + 진행률바(약 40h) + 여백들 = 대략 100-150픽셀
    _scrollController.animateTo(
      0.0, // 맨 위로 스크롤
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
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
          controller: _scrollController,
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
                      isTheoryCompleted: false, // 로딩 중일 때는 퀴즈 버튼 잠금
                      onTheoryPressed: null,
                      onQuizPressed: null,
                    );
                  }

                  // 표시할 챕터 결정: 선택된 챕터가 있으면 선택된 챕터, 없으면 미완료 첫 번째 챕터
                  final displayChapter = provider.selectedChapter ??
                      (provider.chapters
                              .where((chapter) => !chapter.isTheoryCompleted)
                              .isNotEmpty
                          ? provider.chapters
                              .where((chapter) => !chapter.isTheoryCompleted)
                              .first
                          : provider.chapters.first);

                  // 제목과 설명 결정
                  final cardTitle = provider.hasSelectedChapter
                      ? '${displayChapter.title} ✨'
                      : displayChapter.title;
                  final cardDescription = provider.hasSelectedChapter
                      ? '선택된 챕터입니다. 이론 학습을 완료한 후 퀴즈에 도전하세요.'
                      : '현재 진행 중인 챕터입니다. 이론 학습을 완료한 후 퀴즈에 도전하세요.';

                  return CurrentLearningCard(
                    title: cardTitle,
                    description: cardDescription,
                    isTheoryCompleted: displayChapter.isTheoryCompleted,
                    isSelectedChapter: provider.hasSelectedChapter,
                    onTheoryPressed: () {
                      provider.enterTheory(displayChapter.id);
                      context.go(
                          '${AppRoutes.theory}?chapterId=${displayChapter.id}');
                    },
                    onQuizPressed: () {
                      // 퀴즈 화면으로 이동 (표시된 챕터 ID 전달)
                      context.go(
                          '${AppRoutes.quiz}?chapterId=${displayChapter.id}');
                    },
                    onClearSelection: provider.hasSelectedChapter
                        ? () {
                            provider.clearSelectedChapter();
                            debugPrint('🔄 [EDUCATION_SCREEN] 챕터 선택 해제됨');
                          }
                        : null,
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
                    return const Center(child: LoadingWidget());
                  }

                  if (provider.chaptersError != null) {
                    // 인증 에러인 경우
                    if (provider.isAuthenticationError) {
                      return ErrorMessageWidget.auth(
                        message: provider.chaptersError!,
                        onRetry: () {
                          // TODO: 로그인 화면으로 이동
                          debugPrint('🔐 [EDUCATION_SCREEN] 로그인 필요');
                        },
                      );
                    }

                    // 네트워크 에러인 경우
                    if (provider.chaptersError!.contains('네트워크') ||
                        provider.chaptersError!.contains('연결')) {
                      return ErrorMessageWidget.network(
                        message: provider.chaptersError!,
                        onRetry: () {
                          debugPrint('🔄 [EDUCATION_SCREEN] 재시도 버튼 클릭');
                          provider.clearCache().then((_) {
                            provider.loadChapters(forceRefresh: true);
                          });
                        },
                      );
                    }

                    // 기타 서버 에러
                    return ErrorMessageWidget.server(
                      message: provider.chaptersError!,
                      onRetry: () {
                        debugPrint('🔄 [EDUCATION_SCREEN] 재시도 버튼 클릭');
                        provider.clearCache().then((_) {
                          provider.loadChapters(forceRefresh: true);
                        });
                      },
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
                      } else if (chapter.isTheoryCompleted &&
                          chapter.isQuizCompleted) {
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
                          // 챕터 선택하고 CurrentLearningCard로 스크롤
                          provider.selectChapter(chapter.id);
                          debugPrint(
                              '📌 [EDUCATION_SCREEN] 챕터 선택됨: ${chapter.title}');

                          // 선택 후 부드럽게 맨 위로 스크롤 (CurrentLearningCard 위치)
                          Future.delayed(const Duration(milliseconds: 100), () {
                            _scrollToCurrentLearningCard();
                          });
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
