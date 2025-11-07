import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/config/app_routes.dart';
import '../../../app/config/app_theme.dart';
import 'education_provider.dart';
import 'widgets/education_error_widget.dart';
import 'widgets/theory_page_widget.dart';
import 'widgets/theory_navigation_widget.dart';
import 'widgets/theory_empty_state_widget.dart';
import '../../../app/core/utils/theme_utils.dart';

class TheoryScreen extends StatefulWidget {
  const TheoryScreen({super.key, required this.chapterId});

  final int chapterId;

  @override
  State<TheoryScreen> createState() => _TheoryScreenState();
}

class _TheoryScreenState extends State<TheoryScreen> {
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    debugPrint('🎓 [THEORY_SCREEN] 이론 진입 시작 - 챕터 ID: ${widget.chapterId}');
    // 이론 진입
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EducationProvider>().enterTheory(widget.chapterId);
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
      body: Consumer<EducationProvider>(
        builder: (context, provider, child) {
          // 로딩 상태
          if (provider.isLoadingTheory) {
            return _buildLoadingState();
          }

          // 에러 상태
          if (provider.theoryError != null) {
            return EducationErrorWidget(
              title: '이론을 불러오는데 실패했습니다',
              errorMessage: provider.theoryError!,
              onRetry: () => provider.enterTheory(widget.chapterId),
            );
          }

          // 이론 세션이 없는 경우
          if (provider.currentTheorySession == null) {
            return const TheoryEmptyStateWidget(message: '이론 데이터가 없습니다');
          }

          final theorySession = provider.currentTheorySession!;
          final theories = theorySession.theories;

          if (theories.isEmpty) {
            return const TheoryEmptyStateWidget(message: '이론 페이지가 없습니다');
          }

          return _buildTheoryContent(context, provider, theories);
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
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.successColor),
      ),
    );
  }

  /// 이론 콘텐츠 빌드
  Widget _buildTheoryContent(
    BuildContext context,
    EducationProvider provider,
    List<dynamic> theories,
  ) {
    return Column(
      children: [
        // 이론 내용
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              provider.setCurrentTheoryIndex(index);
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
          currentIndex: provider.currentTheoryIndex,
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
          onComplete: () => _completeTheory(provider),
        ),
      ],
    );
  }

  /// 이론 완료 처리
  Future<void> _completeTheory(EducationProvider provider) async {
    try {
      await provider.completeTheory();

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
