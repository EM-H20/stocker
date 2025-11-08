import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../../app/config/app_theme.dart';
import '../../../../app/core/utils/theme_utils.dart';
import '../../../attendance/presentation/provider/attendance_provider.dart';
import '../../../attendance/data/dto/quiz_submission_dto.dart';
import 'quiz_item_widget.dart';

/// 메인 대시보드 퀴즈 섹션 위젯 (실제 출석 API 연동)
class QuizSectionWidget extends StatefulWidget {
  const QuizSectionWidget({super.key});

  @override
  State<QuizSectionWidget> createState() => _QuizSectionWidgetState();
}

class _QuizSectionWidgetState extends State<QuizSectionWidget> {
  List<bool?> _userAnswers = [null, null, null]; // 사용자 답변 저장
  bool _isSubmitting = false; // 제출 중인지 확인

  @override
  void initState() {
    super.initState();
    // 화면 로드시 퀴즈 데이터 가져오기
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTodaysQuiz();
    });
  }

  /// 오늘의 퀴즈 로드
  Future<void> _loadTodaysQuiz() async {
    final attendanceProvider = context.read<AttendanceProvider>();
    await attendanceProvider.fetchTodaysQuiz();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AttendanceProvider>(
      builder: (context, attendanceProvider, child) {
        final quizzes = attendanceProvider.quizzes;
        final isLoading = attendanceProvider.isQuizLoading;

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 섹션 헤더
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '오늘의 퀴즈',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w600,
                          color: ThemeUtils.getColorByTheme(
                            context,
                            lightColor: AppTheme.grey900,
                            darkColor: Colors.white,
                          ),
                        ),
                  ),
                  if (!isLoading && quizzes.isNotEmpty)
                    TextButton.icon(
                      onPressed: _hasAllAnswers() ? _submitQuiz : null,
                      icon: Icon(
                        Icons.check_circle,
                        size: 18.sp,
                        color: _hasAllAnswers()
                            ? AppTheme.successColor
                            : AppTheme.grey500,
                      ),
                      label: Text(
                        '제출하기',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: _hasAllAnswers()
                              ? AppTheme.successColor
                              : AppTheme.grey500,
                        ),
                      ),
                    ),
                ],
              ),

              SizedBox(height: 16.h),

              // 퀴즈 컨테이너
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: ThemeUtils.getColorWithOpacity(
                      context,
                      lightColor: AppTheme.grey300,
                      darkColor: AppTheme.grey700,
                      opacity: ThemeUtils.isDarkMode(context) ? 0.3 : 0.5,
                    ),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          Theme.of(context).shadowColor.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: _buildQuizContent(isLoading, quizzes),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 퀴즈 내용 빌드
  Widget _buildQuizContent(bool isLoading, List quizzes) {
    if (isLoading) {
      return _buildLoadingState();
    }

    if (quizzes.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        for (int i = 0; i < quizzes.length && i < 3; i++) ...[
          QuizItemWidget(
            number: i + 1,
            question: quizzes[i].question,
            selectedAnswer: _userAnswers[i],
            onAnswerO: () => _handleAnswer(i, true),
            onAnswerX: () => _handleAnswer(i, false),
            isEnabled: !_isSubmitting,
          ),
          if (i < quizzes.length - 1 && i < 2) SizedBox(height: 16.h),
        ],
        if (_hasAllAnswers()) ...[
          SizedBox(height: 20.h),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppTheme.successColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: AppTheme.successColor.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppTheme.successColor,
                  size: 20.sp,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    '모든 문제를 풀었습니다! 제출하기 버튼을 눌러 출석을 완료하세요.',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppTheme.successColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  /// 로딩 상태 위젯
  Widget _buildLoadingState() {
    return Column(
      children: [
        SizedBox(height: 40.h),
        CircularProgressIndicator(
          color: Theme.of(context).primaryColor,
        ),
        SizedBox(height: 16.h),
        Text(
          '오늘의 퀴즈를 불러오는 중...',
          style: TextStyle(
            fontSize: 14.sp,
            color: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.color
                ?.withValues(alpha: 0.7),
          ),
        ),
        SizedBox(height: 40.h),
      ],
    );
  }

  /// 빈 상태 위젯
  Widget _buildEmptyState() {
    return Column(
      children: [
        SizedBox(height: 20.h),
        Icon(
          Icons.quiz_outlined,
          size: 48.sp,
          color: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.color
              ?.withValues(alpha: 0.5),
        ),
        SizedBox(height: 12.h),
        Text(
          '오늘의 퀴즈가 없습니다',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.color
                ?.withValues(alpha: 0.8),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          '내일 다시 확인해보세요!',
          style: TextStyle(
            fontSize: 12.sp,
            color: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.color
                ?.withValues(alpha: 0.6),
          ),
        ),
        SizedBox(height: 20.h),
      ],
    );
  }

  /// 퀴즈 답변 처리
  void _handleAnswer(int index, bool answer) {
    if (_isSubmitting) return;

    setState(() {
      _userAnswers[index] = answer;
    });

    // 답변 피드백
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${index + 1}번 문제: ${answer ? "O" : "X"} 선택',
          style: TextStyle(fontSize: 14.sp),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  /// 모든 답변이 완료되었는지 확인
  bool _hasAllAnswers() {
    final attendanceProvider = context.read<AttendanceProvider>();
    final quizCount = attendanceProvider.quizzes.length;

    if (quizCount == 0) return false;

    for (int i = 0; i < quizCount && i < 3; i++) {
      if (_userAnswers[i] == null) return false;
    }
    return true;
  }

  /// 퀴즈 제출 및 출석 처리
  Future<void> _submitQuiz() async {
    if (_isSubmitting || !_hasAllAnswers()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final attendanceProvider = context.read<AttendanceProvider>();
      final quizzes = attendanceProvider.quizzes;

      // QuizAnswerDto 리스트 생성
      final answers = <QuizAnswerDto>[];
      for (int i = 0; i < quizzes.length && i < 3; i++) {
        if (_userAnswers[i] != null) {
          answers.add(QuizAnswerDto(
            quizId: quizzes[i].id,
            userAnswer: _userAnswers[i]!,
          ));
        }
      }

      final success = await attendanceProvider.submitQuiz(answers);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white, size: 20.sp),
                  SizedBox(width: 8.w),
                  Text(
                    '출석이 완료되었습니다! 🎉',
                    style:
                        TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              backgroundColor: AppTheme.successColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              duration: const Duration(seconds: 3),
            ),
          );

          // 답변 상태 초기화 (다음에 다시 풀 수 있도록)
          setState(() {
            _userAnswers = [null, null, null];
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                attendanceProvider.errorMessage ?? '출석 처리 중 오류가 발생했습니다.',
                style: TextStyle(fontSize: 14.sp),
              ),
              backgroundColor: AppTheme.errorColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '출석 처리 중 오류가 발생했습니다: $e',
              style: TextStyle(fontSize: 14.sp),
            ),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}
