import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../data/quiz_api.dart';
import 'models/quiz_session.dart';
import 'models/quiz_result.dart';

/// 퀴즈 Repository
/// API 통신과 로컬 저장소를 통합 관리
class QuizRepository {
  final QuizApi _api;
  final FlutterSecureStorage _storage;

  // 로컬 저장소 키
  static const String _quizProgressKey = 'quiz_progress_';
  static const String _quizResultsKey = 'quiz_results_';

  QuizRepository(this._api, this._storage);

  /// 퀴즈 시작
  ///
  /// 서버에서 퀴즈 세션을 시작하고 로컬에 저장
  ///
  /// Returns: QuizSession
  Future<QuizSession> startQuiz(int chapterId) async {
    try {
      // 서버에서 퀴즈 세션 시작
      final session = await _api.startQuiz(chapterId);

      // 로컬에 진행 상황 저장
      await _saveQuizProgress(session);

      return session;
    } catch (e) {
      debugPrint('퀴즈 시작 실패: $e');
      rethrow;
    }
  }

  /// 답안 제출
  ///
  /// 서버에 답안을 제출하고 로컬 진행 상황 업데이트
  Future<void> submitAnswer(
    int chapterId,
    int quizIndex,
    int selectedAnswer,
  ) async {
    try {
      // 서버에 답안 제출
      await _api.submitAnswer(chapterId, quizIndex, selectedAnswer);

      // 로컬 진행 상황 업데이트
      await _updateLocalProgress(chapterId, quizIndex, selectedAnswer);
    } catch (e) {
      debugPrint('답안 제출 실패: $e');
      rethrow;
    }
  }

  /// 퀴즈 완료
  ///
  /// 서버에 퀴즈 완료를 알리고 결과를 받아옴
  ///
  /// Returns: QuizResult
  Future<QuizResult> completeQuiz(int chapterId, int timeSpentSeconds) async {
    try {
      // 서버에서 퀴즈 완료 처리
      final result = await _api.completeQuiz(chapterId, timeSpentSeconds);

      // 로컬에 결과 저장
      await _saveQuizResult(result);

      // 진행 상황 삭제
      await _clearQuizProgress(chapterId);

      return result;
    } catch (e) {
      debugPrint('퀴즈 완료 실패: $e');
      rethrow;
    }
  }

  /// 퀴즈 결과 조회
  ///
  /// 특정 챕터의 퀴즈 결과 목록 조회
  ///
  /// Returns: List QuizResult
  Future<List<QuizResult>> getQuizResults(int chapterId) async {
    try {
      // 로컬 캐시 확인
      final localResults = await _getLocalQuizResults(chapterId);
      if (localResults.isNotEmpty) {
        return localResults;
      }

      // 서버에서 결과 조회
      final results = await _api.getQuizResults(chapterId);

      // 로컬에 캐시 저장
      for (final result in results) {
        await _saveQuizResult(result);
      }

      return results;
    } catch (e) {
      debugPrint('퀴즈 결과 조회 실패: $e');
      // 로컬 캐시라도 반환
      return await _getLocalQuizResults(chapterId);
    }
  }

  /// 현재 진행 중인 퀴즈 세션 조회
  ///
  /// Returns: QuizSession? (null이면 진행 중인 퀴즈 없음)
  Future<QuizSession?> getCurrentQuizSession() async {
    try {
      // 서버에서 현재 세션 조회
      final session = await _api.getCurrentQuizSession();

      if (session != null) {
        // 로컬에 저장
        await _saveQuizProgress(session);
      }

      return session;
    } catch (e) {
      debugPrint('현재 퀴즈 세션 조회 실패: $e');
      // 로컬 캐시 확인
      return await _getLocalQuizProgress();
    }
  }

  /// 퀴즈 캐시 삭제
  ///
  /// 로컬에 저장된 퀴즈 관련 데이터 삭제
  Future<void> clearQuizCache() async {
    try {
      // 여기서는 간단히 처리
      final allKeys = await _storage.readAll();
      for (final key in allKeys.keys) {
        if (key.startsWith(_quizResultsKey) ||
            key.startsWith(_quizProgressKey)) {
          await _storage.delete(key: key);
        }
      }
    } catch (e) {
      debugPrint('퀴즈 캐시 삭제 실패: $e');
    }
  }

  // === 로컬 저장소 관련 private 메서드들 ===

  /// 퀴즈 진행 상황을 로컬에 저장
  Future<void> _saveQuizProgress(QuizSession session) async {
    try {
      final key = '$_quizProgressKey${session.chapterId}';
      final json = jsonEncode(session.toJson());
      await _storage.write(key: key, value: json);
    } catch (e) {
      debugPrint('퀴즈 진행 상황 저장 실패: $e');
    }
  }

  /// 로컬 진행 상황 업데이트
  Future<void> _updateLocalProgress(
    int chapterId,
    int quizIndex,
    int selectedAnswer,
  ) async {
    try {
      final session = await _getLocalQuizProgress();
      if (session != null && session.chapterId == chapterId) {
        final updatedAnswers = List<int?>.from(session.userAnswers);
        updatedAnswers[quizIndex] = selectedAnswer;

        final updatedSession = session.copyWith(userAnswers: updatedAnswers);
        await _saveQuizProgress(updatedSession);
      }
    } catch (e) {
      debugPrint('로컬 진행 상황 업데이트 실패: $e');
    }
  }

  /// 로컬에서 퀴즈 진행 상황 조회
  Future<QuizSession?> _getLocalQuizProgress() async {
    try {
      final allKeys = await _storage.readAll();
      for (final entry in allKeys.entries) {
        if (entry.key.startsWith(_quizProgressKey)) {
          final json = jsonDecode(entry.value);
          return QuizSession.fromJson(json as Map<String, dynamic>);
        }
      }
      return null;
    } catch (e) {
      debugPrint('로컬 퀴즈 진행 상황 조회 실패: $e');
      return null;
    }
  }

  /// 퀴즈 결과를 로컬에 저장
  Future<void> _saveQuizResult(QuizResult result) async {
    try {
      final key = '$_quizResultsKey${result.chapterId}';
      final existingData = await _storage.read(key: key);

      List<QuizResult> results = [];
      if (existingData != null) {
        final existingList = jsonDecode(existingData) as List;
        results =
            existingList
                .map(
                  (item) => QuizResult.fromJson(item as Map<String, dynamic>),
                )
                .toList();
      }

      // 새 결과 추가 (최신 순으로 정렬)
      results.insert(0, result);

      // 최대 10개까지만 저장
      if (results.length > 10) {
        results = results.take(10).toList();
      }

      final json = jsonEncode(results.map((r) => r.toJson()).toList());
      await _storage.write(key: key, value: json);
    } catch (e) {
      debugPrint('퀴즈 결과 저장 실패: $e');
    }
  }

  /// 로컬에서 퀴즈 결과 조회
  Future<List<QuizResult>> _getLocalQuizResults(int chapterId) async {
    try {
      final key = '$_quizResultsKey$chapterId';
      final data = await _storage.read(key: key);

      if (data != null) {
        final list = jsonDecode(data) as List;
        return list
            .map((item) => QuizResult.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      debugPrint('로컬 퀴즈 결과 조회 실패: $e');
      return [];
    }
  }

  /// 퀴즈 진행 상황 삭제
  Future<void> _clearQuizProgress(int chapterId) async {
    try {
      final key = '$_quizProgressKey$chapterId';
      await _storage.delete(key: key);
    } catch (e) {
      debugPrint('퀴즈 진행 상황 삭제 실패: $e');
    }
  }
}
