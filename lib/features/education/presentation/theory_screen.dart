import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../app/config/app_routes.dart';
import '../../../app/core/widgets/action_button.dart';
import 'education_provider.dart';
import 'widgets/education_error_widget.dart';

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
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white, size: 24.sp),
          onPressed: () => context.go(AppRoutes.education),
        ),
        title: Text(
          '이론 학습',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<EducationProvider>(
        builder: (context, provider, child) {
          // 로딩 상태
          if (provider.isLoadingTheory) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
              ),
            );
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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.book_outlined,
                    size: 64.sp,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    '이론 데이터가 없습니다',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          final theorySession = provider.currentTheorySession!;
          final theories = theorySession.theories;

          if (theories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.book_outlined,
                    size: 64.sp,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    '이론 페이지가 없습니다',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

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
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 16.w),
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 페이지 번호
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 6.h,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4CAF50),
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Text(
                                '페이지 ${index + 1}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            SizedBox(height: 20.h),

                            // 이론 제목
                            if (theory.word.isNotEmpty) ...[
                              Text(
                                theory.word,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 16.h),
                            ],

                            // 이론 내용
                            Text(
                              theory.content,
                              style: TextStyle(
                                color: Colors.grey[300],
                                fontSize: 16.sp,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // 하단 버튼들
              Container(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  children: [
                    // 이전 버튼
                    if (provider.currentTheoryIndex > 0)
                      Expanded(
                        child: ActionButton(
                          text: '이전',
                          icon: Icons.arrow_back,
                          color: Colors.grey[600]!,
                          onPressed: () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                        ),
                      ),

                    if (provider.currentTheoryIndex > 0) SizedBox(width: 12.w),

                    // 다음/완료 버튼
                    if (provider.currentTheoryIndex < theories.length - 1)
                      Expanded(
                        child: ActionButton(
                          text: '다음',
                          icon: Icons.arrow_forward,
                          color: const Color(0xFF4CAF50),
                          onPressed: () {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                        ),
                      )
                    else
                      Expanded(
                        child: ActionButton(
                          text: '이론 완료',
                          icon: Icons.check_circle,
                          color: const Color(0xFF4CAF50),
                          onPressed: () => _completeTheory(provider),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

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
