import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/repository/attendance_repository.dart';
import '../../data/dto/quiz_submission_dto.dart';
import '../../../../app/core/providers/riverpod/repository_providers.dart';
import '../../../../app/core/utils/error_message_extractor.dart';
import 'attendance_state.dart';

part 'attendance_notifier.g.dart';

/// 🔥 Riverpod 기반 출석 상태 관리 Notifier
@riverpod
class AttendanceNotifier extends _$AttendanceNotifier {
  @override
  AttendanceState build() {
    // 초기 상태 생성 (현재 월로 시작)
    final now = DateTime.now();
    final initialState = AttendanceState(
      focusedMonth: DateTime(now.year, now.month),
    );

    // 초기화 (출석 현황 로드)
    Future.microtask(() => fetchAttendanceStatus(initialState.focusedMonth));

    return initialState;
  }

  /// AttendanceRepository 접근
  AttendanceRepository get _repository =>
      ref.read(attendanceRepositoryProvider);

  /// 퀴즈 로딩 상태 설정
  void setQuizLoading(bool value) {
    state = state.copyWith(isQuizLoading: value);
  }

  /// 출석 현황 조회
  Future<void> fetchAttendanceStatus(DateTime month) async {
    state = state.copyWith(
      focusedMonth: month,
      isLoading: true,
      errorMessage: null,
    );

    try {
      final attendanceList = await _repository.getAttendanceStatus(month);
      final attendanceMap = {
        for (var day in attendanceList)
          DateTime.utc(day.date.year, day.date.month, day.date.day):
              day.isPresent
      };

      state = state.copyWith(
        attendanceStatus: attendanceMap,
        isLoading: false,
        errorMessage: null,
      );

      debugPrint('✅ [ATTENDANCE] 출석 현황 로드 완료: ${attendanceMap.length}일');
    } catch (e) {
      debugPrint('❌ [ATTENDANCE] 출석 현황 로딩 실패: $e');

      final errorMessage =
          ErrorMessageExtractor.extractDataLoadError(e, '출석 현황');

      state = state.copyWith(
        isLoading: false,
        errorMessage: errorMessage,
      );
    }
  }

  /// 오늘의 퀴즈 조회
  Future<bool> fetchTodaysQuiz() async {
    try {
      final quizzes = await _repository.getTodaysQuiz();

      state = state.copyWith(
        quizzes: quizzes,
        errorMessage: null,
      );

      debugPrint('✅ [ATTENDANCE] 오늘의 퀴즈 로드 완료: ${quizzes.length}개');
      return true;
    } catch (e) {
      debugPrint('❌ [ATTENDANCE] 퀴즈 로딩 실패: $e');

      final errorMessage = ErrorMessageExtractor.extractDataLoadError(e, '퀴즈');

      state = state.copyWith(
        quizzes: [],
        errorMessage: errorMessage,
      );
      return false;
    }
  }

  /// 퀴즈 제출 및 출석 처리
  Future<bool> submitQuiz(List<QuizAnswerDto> userAnswers) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);

    try {
      // API 문서에 따르면 출석 제출은 단순히 { "isPresent": true } 형식
      // 퀴즈 답변과 관계없이 퀴즈를 풀었다는 것 자체가 출석을 의미
      await _repository.submitAttendance({"isPresent": true});

      debugPrint('✅ [ATTENDANCE] 출석 처리 완료');

      // 출석 현황 새로고침
      await fetchAttendanceStatus(state.focusedMonth);

      state = state.copyWith(isSubmitting: false, errorMessage: null);
      return true;
    } catch (e) {
      debugPrint('❌ [ATTENDANCE] 출석 처리 실패: $e');

      final errorMessage =
          ErrorMessageExtractor.extractSubmissionError(e, '출석 처리');

      state = state.copyWith(
        isSubmitting: false,
        errorMessage: errorMessage,
      );
      return false;
    }
  }

  /// 포커스된 월 변경
  void changeFocusedMonth(DateTime month) {
    fetchAttendanceStatus(month);
  }
}
