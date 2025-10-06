import 'package:flutter/material.dart';
import '../../domain/model/attendance_quiz.dart';
import '../../domain/repository/attendance_repository.dart';
import '../../../auth/presentation/auth_provider.dart';
import '../../data/dto/quiz_submission_dto.dart';

class AttendanceProvider with ChangeNotifier {
  final AttendanceRepository _repository;
  final AuthProvider _authProvider;

  AttendanceProvider(this._repository, this._authProvider);

  // dispose 상태 체크를 위한 플래그
  bool _disposed = false;

  Map<DateTime, bool> _attendanceStatus = {};
  Map<DateTime, bool> get attendanceStatus => _attendanceStatus;

  List<AttendanceQuiz> _quizzes = [];
  List<AttendanceQuiz> get quizzes => _quizzes;

  DateTime _focusedMonth = DateTime.now();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isQuizLoading = false;
  bool get isQuizLoading => _isQuizLoading;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  /// dispose 상태를 확인하고 안전하게 listener에게 알림
  void _safeNotifyListeners() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  void initialize() {
    fetchAttendanceStatus(_focusedMonth);
  }

  Future<void> setQuizLoading(bool value) async {
    _isQuizLoading = value;
    _safeNotifyListeners();
  }

  Future<void> fetchAttendanceStatus(DateTime month) async {
    _focusedMonth = month;
    _isLoading = true;
    _safeNotifyListeners();

    try {
      final attendanceList = await _repository.getAttendanceStatus(month);
      _attendanceStatus = {
        for (var day in attendanceList)
          DateTime.utc(day.date.year, day.date.month, day.date.day):
              day.isPresent
      };
      _errorMessage = null;
    } catch (e) {
      _errorMessage = '출석 현황 로딩 실패: ${e.toString()}';
    } finally {
      _isLoading = false;
      _safeNotifyListeners(); // 에러 발생 지점 수정!
    }
  }

  Future<bool> fetchTodaysQuiz() async {
    try {
      _quizzes = await _repository.getTodaysQuiz();
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = '퀴즈 로딩 실패: ${e.toString()}';
      _quizzes = [];
      return false;
    }
  }
  
  /// 퀴즈 제출 및 출석 처리 (API 문서에 맞춘 형식)
  Future<bool> submitQuiz(List<QuizAnswerDto> userAnswers) async {
    _isSubmitting = true;
   _safeNotifyListeners();

    try {
      // API 문서에 따르면 출석 제출은 단순히 { "isPresent": true } 형식
      // 퀴즈 답변과 관계없이 퀴즈를 풀었다는 것 자체가 출석을 의미
     await _repository.submitAttendance({"isPresent": true});
    
     _errorMessage = null;
      await fetchAttendanceStatus(_focusedMonth);
     return true;
    } catch (e) {
      _errorMessage = '출석 처리 실패: ${e.toString()}';
      return false;
    } finally {
      _isSubmitting = false;
      _safeNotifyListeners();
   }
  }
}
