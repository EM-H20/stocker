// import 'package:flutter/material.dart';
// // import '../../domain/model/attendance_day.dart';
// import '../../domain/model/attendance_quiz.dart';
// import '../../domain/repository/attendance_repository.dart';
// import '../../../auth/presentation/auth_provider.dart';
// import '../../data/dto/quiz_submission_dto.dart';

// class AttendanceProvider with ChangeNotifier {
//   final AttendanceRepository _repository;
//   final AuthProvider _authProvider;

//   AttendanceProvider(this._repository, this._authProvider);

//   Map<DateTime, bool> _attendanceStatus = {};
//   Map<DateTime, bool> get attendanceStatus => _attendanceStatus;

//   List<AttendanceQuiz> _quizzes = [];
//   List<AttendanceQuiz> get quizzes => _quizzes;

//   DateTime _focusedMonth = DateTime.now();
  
//   // ✅ [수정] 로딩 상태 분리
//   bool _isLoading = false; // 달력 데이터 로딩
//   bool get isLoading => _isLoading;

//   bool _isQuizLoading = false; // 퀴즈 데이터 로딩
//   bool get isQuizLoading => _isQuizLoading;

//   bool _isSubmitting = false; // 퀴즈 제출 로딩
//   bool get isSubmitting => _isSubmitting;

//   String? _errorMessage;
//   String? get errorMessage => _errorMessage;

//   void initialize() {
//     fetchAttendanceStatus(_focusedMonth);
//   }
  
//   // ✅ [추가] 퀴즈 로딩 상태를 수동으로 제어하는 함수
//   Future<void> setQuizLoading(bool value) async {
//     _isQuizLoading = value;
//     notifyListeners();
//   }

//   Future<void> fetchAttendanceStatus(DateTime month) async {
//     _focusedMonth = month;
//     _isLoading = true;
//     notifyListeners();

//     try {
//       final attendanceList = await _repository.getAttendanceStatus(month);
//       _attendanceStatus = {for (var day in attendanceList) DateTime.utc(day.date.year, day.date.month, day.date.day): day.isPresent};
//       _errorMessage = null;
//     } catch (e) {
//       _errorMessage = '출석 현황 로딩 실패: ${e.toString()}';
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   Future<bool> fetchTodaysQuiz() async {
//     // 이 함수는 이제 로딩 상태를 직접 제어하지 않습니다.
//     try {
//       _quizzes = await _repository.getTodaysQuiz();
//       _errorMessage = null;
//       return true;
//     } catch (e) {
//       _errorMessage = '퀴즈 로딩 실패: ${e.toString()}';
//       _quizzes = [];
//       return false;
//     }
//   }

//   Future<bool> submitQuiz(List<QuizAnswerDto> userAnswers) async {
//     final userId = _authProvider.user?.id;
//     if (userId == null) {
//       _errorMessage = '로그인 정보가 필요합니다.';
//       notifyListeners();
//       return false;
//     }

//     _isSubmitting = true;
//     notifyListeners();

//     try {
//       final submission = QuizSubmissionDto(userId: userId, answers: userAnswers);
//       await _repository.submitAttendance(submission);
//       _errorMessage = null;
//       await fetchAttendanceStatus(_focusedMonth);
//       return true;
//     } catch (e) {
//       _errorMessage = '출석 처리 실패: ${e.toString()}';
//       return false;
//     } finally {
//       _isSubmitting = false;
//       notifyListeners();
//     }
//   }
// }

import 'package:flutter/material.dart';
import '../../domain/model/attendance_day.dart';
import '../../domain/model/attendance_quiz.dart';
import '../../domain/repository/attendance_repository.dart';
import '../../../auth/presentation/auth_provider.dart';
import '../../data/dto/quiz_submission_dto.dart';

class AttendanceProvider with ChangeNotifier {
  final AttendanceRepository _repository;
  final AuthProvider _authProvider;

  AttendanceProvider(this._repository, this._authProvider);

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

  void initialize() {
    fetchAttendanceStatus(_focusedMonth);
  }
  
  Future<void> setQuizLoading(bool value) async {
    _isQuizLoading = value;
    notifyListeners();
  }

  Future<void> fetchAttendanceStatus(DateTime month) async {
    _focusedMonth = month;
    _isLoading = true;
    notifyListeners();

    try {
      final attendanceList = await _repository.getAttendanceStatus(month);
      _attendanceStatus = {for (var day in attendanceList) DateTime.utc(day.date.year, day.date.month, day.date.day): day.isPresent};
      _errorMessage = null;
    } catch (e) {
      _errorMessage = '출석 현황 로딩 실패: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> fetchTodaysQuiz() async {
    print("[DEBUG] 1. fetchTodaysQuiz 시작");
    try {
      _quizzes = await _repository.getTodaysQuiz();
      _errorMessage = null;
      print("[DEBUG] 2. 퀴즈 가져오기 성공! 퀴즈 개수: ${_quizzes.length}");
      return true;
    } catch (e) {
      _errorMessage = '퀴즈 로딩 실패: ${e.toString()}';
      _quizzes = [];
      print("[DEBUG] 2. 퀴즈 가져오기 실패: $e");
      return false;
    }
  }

  Future<bool> submitQuiz(List<QuizAnswerDto> userAnswers) async {
    final userId = _authProvider.user?.id;
    if (userId == null) {
      _errorMessage = '로그인 정보가 필요합니다.';
      notifyListeners();
      return false;
    }

    _isSubmitting = true;
    notifyListeners();

    try {
      final submission = QuizSubmissionDto(userId: userId, answers: userAnswers);
      await _repository.submitAttendance(submission);
      _errorMessage = null;
      await fetchAttendanceStatus(_focusedMonth);
      return true;
    } catch (e) {
      _errorMessage = '출석 처리 실패: ${e.toString()}';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}
