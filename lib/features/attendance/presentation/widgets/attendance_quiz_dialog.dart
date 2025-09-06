import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';

import '../../../../app/config/app_theme.dart';
import '../../../../app/core/widgets/action_button.dart';
import '../../data/dto/quiz_submission_dto.dart';
import '../../domain/model/attendance_quiz.dart';
import '../provider/attendance_provider.dart';

/// 출석 퀴즈 팝업 다이얼로그 (StatefulWidget)
class AttendanceQuizDialog extends StatefulWidget {
  final List<AttendanceQuiz> quizzes;

  const AttendanceQuizDialog({super.key, required this.quizzes});

  @override
  State<AttendanceQuizDialog> createState() => _AttendanceQuizDialogState();
}

class _AttendanceQuizDialogState extends State<AttendanceQuizDialog> {
  int _currentIndex = 0;
  bool? _selectedAnswer;
  bool _showResult = false;
  final List<QuizAnswerDto> _userAnswers = [];

  AttendanceQuiz get _currentQuiz => widget.quizzes[_currentIndex];
  bool get _isCorrect => _selectedAnswer == _currentQuiz.answer;

  void _nextQuestion() {
    if (_currentIndex >= widget.quizzes.length - 1) {
      _submitAttendance();
    } else {
      setState(() {
        _currentIndex++;
        _selectedAnswer = null;
        _showResult = false;
      });
    }
  }

  void _onAnswerSelected(bool answer) {
    if (_showResult) return;
    setState(() {
      _selectedAnswer = answer;
      _showResult = true;
      _userAnswers.add(
        QuizAnswerDto(quizId: _currentQuiz.id, userAnswer: answer),
      );
    });
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) _nextQuestion();
    });
  }

  Future<void> _submitAttendance() async {
    if (!mounted) return;
    final provider = context.read<AttendanceProvider>();
    final success = await provider.submitQuiz(_userAnswers);

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? '출석이 완료되었습니다!'
              : provider.errorMessage ?? '출석 처리 중 오류가 발생했습니다.'),
          backgroundColor:
              success ? AppTheme.successColor : AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AttendanceProvider>();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      title: Text('오늘의 출석 퀴즈 (${_currentIndex + 1}/${widget.quizzes.length})'),
      content: SizedBox(
        width: 0.8.sw,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 개선된 Progress Indicator
            LinearPercentIndicator(
              percent: (_currentIndex + 1) / widget.quizzes.length,
              lineHeight: 14.h, // 두께 증가
              center: Text(
                '${((_currentIndex + 1) / widget.quizzes.length * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black87,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  shadows: isDarkMode
                      ? [Shadow(color: Colors.black54, blurRadius: 1)]
                      : [Shadow(color: Colors.white70, blurRadius: 1)],
                ),
              ),
              backgroundColor: isDarkMode ? AppTheme.grey700 : AppTheme.grey200,
              progressColor: AppTheme.successColor, // 교육 위젯과 동일한 초록색
              barRadius: Radius.circular(7.r),
            ),
            SizedBox(height: 28.h),
            // 동적 높이 조정된 질문 영역
            Container(
              constraints: BoxConstraints(
                minHeight: 80.h,
                maxHeight: 120.h,
              ),
              child: Center(
                child: Text(
                  _currentQuiz.question,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ),
            SizedBox(height: 28.h),
            // 💎 슈퍼 업그레이드된 OX 버튼 레이아웃
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAnswerButton(context, isO: true),
                SizedBox(width: 24.w), // 더 여유로운 간격
                _buildAnswerButton(context, isO: false),
              ],
            ),
            SizedBox(height: 20.h),
            if (provider.isSubmitting)
              SpinKitFadingCircle(
                color: AppTheme.successColor,
                size: 40.r,
              ),
          ],
        ),
      ),
      contentPadding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 20.h),
      actionsPadding: EdgeInsets.only(bottom: 12.h, right: 12.w),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
    );
  }

  Widget _buildAnswerButton(BuildContext context, {required bool isO}) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    Color buttonColor;
    IconData buttonIcon;

    if (_showResult && _selectedAnswer == isO) {
      // 🎯 선택된 답안 결과 - 더 임팩트 있는 아이콘과 색상
      buttonIcon =
          _isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded;
      buttonColor = _isCorrect ? AppTheme.successColor : AppTheme.errorColor;
    } else if (_showResult) {
      // 선택되지 않은 답안은 은은한 회색
      buttonIcon = isO ? Icons.panorama_fish_eye : Icons.close_rounded;
      buttonColor = isDarkMode ? AppTheme.grey600 : AppTheme.grey400;
    } else {
      // 🎨 기본 상태 - 더 매력적인 아이콘과 색상
      buttonIcon = isO ? Icons.panorama_fish_eye : Icons.close_rounded;
      buttonColor = isDarkMode ? AppTheme.grey600 : AppTheme.grey500;
    }

    // 🚀 완전 새로워진 정사각형 ActionButton
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: ActionButton(
        text: isO ? 'O' : 'X',
        icon: buttonIcon,
        color: buttonColor,
        onPressed: _showResult ? null : () => _onAnswerSelected(isO),
        width: 80.w, // 🔥 정사각형 스타일
        height: 80.h, // 🔥 정사각형 스타일
      ),
    );
  }
}
