import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// 분리된 위젯들 import
import 'widgets/search_bar_widget.dart';
import 'widgets/recommended_chapter_card.dart';
import 'widgets/current_learning_card.dart';
import 'widgets/global_progress_bar.dart';
import 'package:stocker/app/config/app_routes.dart';
import 'package:go_router/go_router.dart';
import 'riverpod/education_notifier.dart';
import '../../../app/core/widgets/loading_widget.dart';
import '../../../app/core/widgets/error_message_widget.dart';

class EducationScreen extends ConsumerStatefulWidget {
  const EducationScreen({super.key});

  @override
  ConsumerState<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends ConsumerState<EducationScreen> {
  /// 검색 입력 컨트롤러
  final TextEditingController _searchController = TextEditingController();

  /// 디바운스 타이머 (300ms 지연)
  Timer? _debounceTimer;

  /// 디바운스 시간 (밀리초)
  static const int _debounceDuration = 300;

  @override
  void initState() {
    super.initState();

    // 화면 로드 시 챕터 목록을 가져옴 (캐시 활용)
    Future.microtask(() {
      final educationState = ref.read(educationNotifierProvider);
      final educationNotifier = ref.read(educationNotifierProvider.notifier);

      // ✅ 데이터가 없을 때만 로드 (캐시 활용으로 불필요한 API 호출 방지)
      if (educationState.chapters.isEmpty && !educationState.isLoadingChapters) {
        debugPrint('📚 [EDUCATION_SCREEN] 챕터 데이터 없음 - API 호출');
        educationNotifier.loadChapters();
      } else {
        debugPrint('✅ [EDUCATION_SCREEN] 캐시된 챕터 데이터 사용 (${educationState.chapters.length}개)');
      }
    });
  }

  @override
  void dispose() {
    // 메모리 누수 방지: 타이머와 컨트롤러 정리
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  /// 검색어 변경 핸들러 (디바운싱 적용)
  void _onSearchChanged(String query) {
    // 기존 타이머 취소
    _debounceTimer?.cancel();

    // 새 타이머 설정 (300ms 후 검색 실행)
    _debounceTimer = Timer(
      const Duration(milliseconds: _debounceDuration),
      () {
        debugPrint('🔍 [EDUCATION_SCREEN] 검색 실행: "$query"');
        ref.read(educationNotifierProvider.notifier).setSearchQuery(query);
      },
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
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 검색바 (상단으로 이동) - 디바운싱 적용된 실시간 검색
              SearchBarWidget(
                hintText: '챕터나 주제를 검색하세요',
                controller: _searchController,
                onChanged: _onSearchChanged,
                onClear: () {
                  // 클리어 버튼 클릭 시 검색어 초기화
                  debugPrint('🧹 [EDUCATION_SCREEN] 검색어 클리어');
                  ref.read(educationNotifierProvider.notifier).clearSearch();
                },
              ),
              SizedBox(height: 16.h),

              // 전체 진행률 바 (재사용 가능한 컴포넌트)
              const GlobalProgressBar(),
              SizedBox(height: 12.h),

              // 현재 진행 학습 카드 - Riverpod 데이터 사용
              Consumer(
                builder: (context, ref, child) {
                  final educationState = ref.watch(educationNotifierProvider);
                  final educationNotifier =
                      ref.read(educationNotifierProvider.notifier);

                  // 로딩 중이거나 챕터가 없는 경우 기본 카드 표시
                  if (educationState.isLoadingChapters ||
                      educationState.chapters.isEmpty) {
                    return const CurrentLearningCard(
                      title: '학습 준비 중...',
                      description: '챕터 정보를 불러오고 있습니다.',
                      isTheoryCompleted: false, // 로딩 중일 때는 퀴즈 버튼 잠금
                      onTheoryPressed: null,
                      onQuizPressed: null,
                    );
                  }

                  // 표시할 챕터 결정: 선택된 챕터가 있으면 선택된 챕터, 없으면 미완료 첫 번째 챕터
                  final displayChapter = educationState.getSelectedChapter() ??
                      (educationState.chapters
                              .where((chapter) => !chapter.isTheoryCompleted)
                              .isNotEmpty
                          ? educationState.chapters
                              .where((chapter) => !chapter.isTheoryCompleted)
                              .first
                          : educationState.chapters.first);

                  // 제목과 설명 결정
                  final cardTitle = educationState.hasSelectedChapter
                      ? '${displayChapter.title} ✨'
                      : displayChapter.title;
                  final cardDescription = educationState.hasSelectedChapter
                      ? '선택된 챕터입니다. 이론 학습을 완료한 후 퀴즈에 도전하세요.'
                      : '현재 진행 중인 챕터입니다. 이론 학습을 완료한 후 퀴즈에 도전하세요.';

                  return CurrentLearningCard(
                    title: cardTitle,
                    description: cardDescription,
                    isTheoryCompleted: displayChapter.isTheoryCompleted,
                    isSelectedChapter: educationState.hasSelectedChapter,
                    onTheoryPressed: () {
                      educationNotifier.enterTheory(displayChapter.id);
                      context.go(
                          '${AppRoutes.theory}?chapterId=${displayChapter.id}');
                    },
                    onQuizPressed: () {
                      // 퀴즈 화면으로 이동 (표시된 챕터 ID 전달)
                      context.go(
                          '${AppRoutes.quiz}?chapterId=${displayChapter.id}');
                    },
                    onClearSelection: educationState.hasSelectedChapter
                        ? () {
                            educationNotifier.clearSelectedChapter();
                            debugPrint('🔄 [EDUCATION_SCREEN] 챕터 선택 해제됨');
                          }
                        : null,
                  );
                },
              ),
              SizedBox(height: 28.h),

              // 추천 학습 챕터 제목 - 검색 중이면 "검색 결과" 표시
              Consumer(
                builder: (context, ref, child) {
                  final educationState = ref.watch(educationNotifierProvider);
                  final isSearching = educationState.isSearching;

                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5.w),
                    child: Row(
                      children: [
                        Text(
                          isSearching ? '검색 결과' : '추천 학습 챕터',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (isSearching) ...[
                          SizedBox(width: 8.w),
                          Text(
                            '(${educationState.filteredChapters.length}건)',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
              SizedBox(height: 16.h),

              // 추천 학습 챕터 리스트 - Riverpod 데이터 사용 (검색 필터링 적용)
              Consumer(
                builder: (context, ref, child) {
                  final educationState = ref.watch(educationNotifierProvider);
                  final educationNotifier =
                      ref.read(educationNotifierProvider.notifier);

                  if (educationState.isLoadingChapters) {
                    return const Center(child: LoadingWidget());
                  }

                  if (educationState.chaptersError != null) {
                    // 인증 에러인 경우
                    if (educationState.isAuthenticationError) {
                      return ErrorMessageWidget.auth(
                        message: educationState.chaptersError!,
                        onRetry: () {
                          // TODO: 로그인 화면으로 이동
                          debugPrint('🔐 [EDUCATION_SCREEN] 로그인 필요');
                        },
                      );
                    }

                    // 네트워크 에러인 경우
                    if (educationState.chaptersError!.contains('네트워크') ||
                        educationState.chaptersError!.contains('연결')) {
                      return ErrorMessageWidget.network(
                        message: educationState.chaptersError!,
                        onRetry: () {
                          debugPrint('🔄 [EDUCATION_SCREEN] 재시도 버튼 클릭');
                          educationNotifier.clearCache().then((_) {
                            educationNotifier.loadChapters(forceRefresh: true);
                          });
                        },
                      );
                    }

                    // 기타 서버 에러
                    return ErrorMessageWidget.server(
                      message: educationState.chaptersError!,
                      onRetry: () {
                        debugPrint('🔄 [EDUCATION_SCREEN] 재시도 버튼 클릭');
                        educationNotifier.clearCache().then((_) {
                          educationNotifier.loadChapters(forceRefresh: true);
                        });
                      },
                    );
                  }

                  // 🔍 검색 결과가 없는 경우
                  final chaptersToDisplay = educationState.filteredChapters;
                  if (chaptersToDisplay.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40.h),
                        child: Column(
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 48.sp,
                              color: colorScheme.onSurface.withValues(alpha: 0.4),
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              '"${educationState.searchQuery}" 검색 결과가 없습니다',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: chaptersToDisplay.map((chapter) {
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
                          // 챕터 선택
                          educationNotifier.selectChapter(chapter.id);
                          debugPrint(
                              '📌 [EDUCATION_SCREEN] 챕터 선택됨: ${chapter.title}');
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
