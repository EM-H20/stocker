import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/config/app_routes.dart';
import '../../../app/config/app_theme.dart';
import 'riverpod/education_notifier.dart';
import 'riverpod/education_state.dart';
import 'widgets/education_error_widget.dart';
import 'widgets/theory_page_widget.dart';
import 'widgets/theory_navigation_widget.dart';
import 'widgets/theory_empty_state_widget.dart';
import '../../../app/core/utils/theme_utils.dart';
import '../../../app/core/widgets/loading_widget.dart';

class TheoryScreen extends ConsumerStatefulWidget {
  const TheoryScreen({super.key, required this.chapterId});

  final int chapterId;

  @override
  ConsumerState<TheoryScreen> createState() => _TheoryScreenState();
}

class _TheoryScreenState extends ConsumerState<TheoryScreen> {
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    debugPrint('🎓 [THEORY_SCREEN] 이론 진입 시작 - 챕터 ID: ${widget.chapterId}');
    // 이론 진입
    Future.microtask(() {
      ref
          .read(educationNotifierProvider.notifier)
          .enterTheory(widget.chapterId);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
      body: Consumer(
        builder: (context, ref, child) {
          final educationState = ref.watch(educationNotifierProvider);
          final educationNotifier =
              ref.read(educationNotifierProvider.notifier);

          // 로딩 상태
          if (educationState.isLoadingTheory) {
            return _buildLoadingState();
          }

          // 에러 상태
          if (educationState.theoryError != null) {
            return EducationErrorWidget(
              title: '이론을 불러오는데 실패했습니다',
              errorMessage: educationState.theoryError!,
              onRetry: () => educationNotifier.enterTheory(widget.chapterId),
            );
          }

          // 이론 세션이 없는 경우
          if (educationState.currentTheorySession == null) {
            return const TheoryEmptyStateWidget(message: '이론 데이터가 없습니다');
          }

          final theorySession = educationState.currentTheorySession!;
          final theories = theorySession.theories;

          if (theories.isEmpty) {
            return const TheoryEmptyStateWidget(message: '이론 페이지가 없습니다');
          }

          return _buildTheoryContent(
              context, educationState, educationNotifier, theories);
        },
      ),
    );
  }

  /// AppBar 빌드
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final isDarkMode = ThemeUtils.isDarkMode(context);

    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: isDarkMode ? Colors.white : AppTheme.grey900,
          size: 24.sp,
        ),
        onPressed: () => context.go(AppRoutes.education),
      ),
      title: Text(
        '이론 학습',
        style: TextStyle(
          color: isDarkMode ? Colors.white : AppTheme.grey900,
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
    );
  }

  /// 로딩 상태 위젯
  Widget _buildLoadingState() {
    return const Center(child: LoadingWidget());
  }

  /// 이론 콘텐츠 빌드
  Widget _buildTheoryContent(
    BuildContext context,
    EducationState educationState,
    EducationNotifier educationNotifier,
    List<dynamic> theories,
  ) {
    return Column(
      children: [
        // 이론 내용
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              educationNotifier.setCurrentTheoryIndex(index);
            },
            itemCount: theories.length,
            itemBuilder: (context, index) {
              final theory = theories[index];
              return TheoryPageWidget(theory: theory, pageIndex: index);
            },
          ),
        ),

        // 하단 네비게이션
        TheoryNavigationWidget(
          currentIndex: educationState.currentTheoryIndex,
          totalPages: theories.length,
          onPrevious: () {
            _pageController.previousPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
          onNext: () {
            _pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
          onComplete: () => _completeTheory(educationNotifier),
        ),
      ],
    );
  }

  /// 이론 완료 처리
  Future<void> _completeTheory(EducationNotifier educationNotifier) async {
    try {
      await educationNotifier.completeTheory();

      if (mounted) {
        // 이론 완료 후 퀴즈로 이동
        context.go('${AppRoutes.quiz}?chapterId=${widget.chapterId}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('이론 완료 처리 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
