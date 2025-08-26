import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';

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
          content: Text(success ? '출석이 완료되었습니다!' : provider.errorMessage ?? '출석 처리 중 오류가 발생했습니다.'),
          backgroundColor: success ? Colors.blue : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AttendanceProvider>();

    return AlertDialog(
      title: Text('오늘의 출석 퀴즈 (${_currentIndex + 1}/${widget.quizzes.length})'),
      // ✅ [수정] content를 SizedBox로 감싸서 명시적인 너비를 제공합니다.
      // 이렇게 하면 AlertDialog가 크기를 계산할 때 발생하는 레이아웃 오류를 해결할 수 있습니다.
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8, // 화면 너비의 80%로 고정
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LinearPercentIndicator(
              percent: (_currentIndex + 1) / widget.quizzes.length,
              lineHeight: 12.0,
              center: Text(
                '${((_currentIndex + 1) / widget.quizzes.length * 100).toStringAsFixed(0)}%',
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
              backgroundColor: Colors.grey[300],
              progressColor: Theme.of(context).primaryColor,
              barRadius: const Radius.circular(6),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 80,
              child: Center(
                child: Text(
                  _currentQuiz.question,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAnswerButton(context, isO: true),
                _buildAnswerButton(context, isO: false),
              ],
            ),
            const SizedBox(height: 16),
            if (provider.isSubmitting)
              const SpinKitFadingCircle(
                color: Colors.blue,
                size: 40.0,
              ),
          ],
        ),
      ),
      // 다이얼로그의 여백을 조절하여 UI를 개선합니다.
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      actionsPadding: const EdgeInsets.only(bottom: 10, right: 10),
    );
  }

  Widget _buildAnswerButton(BuildContext context, {required bool isO}) {
    Color? buttonColor;
    IconData? resultIcon;

    if (_showResult && _selectedAnswer == isO) {
      resultIcon = _isCorrect ? Icons.check_circle_outline : Icons.highlight_off;
      buttonColor = _isCorrect ? Colors.green : Colors.red;
    }

    return ActionButton(
      text: isO ? 'O' : 'X',
      icon: resultIcon ?? (isO ? Icons.circle_outlined : Icons.clear),
      color: buttonColor ?? (_showResult ? Colors.grey : Colors.blue),
      onPressed: () => _onAnswerSelected(isO),
      width: 100,
    );
  }
}

