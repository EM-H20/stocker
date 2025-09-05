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

  /// 퀴즈 진입 (API.md 스펙 준수)
  ///
  /// 서버에서 퀴즈 세션을 시작하고 로컬에 저장
  ///
  /// Returns: QuizSession
  Future<QuizSession> enterQuiz(int chapterId) async {
    try {
      // 서버에서 퀴즈 진입
      final session = await _api.enterQuiz(chapterId);

      // 로컬에 진행 상황 저장
      await _saveQuizProgress(session);

      return session;
    } catch (e) {
      debugPrint('퀴즈 진입 실패: $e');
      rethrow;
    }
  }

  /// 퀴즈 진도 업데이트
  ///
  /// 서버에 현재 퀴즈 진행 상황을 업데이트하고 로컬 상태 업데이트
  Future<void> updateQuizProgress(
    int chapterId,
    int currentQuizId,
  ) async {
    try {
      // 서버에 진도 업데이트
      await _api.updateQuizProgress(chapterId, currentQuizId);

      // 로컬 진행 상황 업데이트
      await _updateLocalProgressForQuizId(chapterId, currentQuizId);
    } catch (e) {
      debugPrint('퀴즈 진도 업데이트 실패: $e');
      rethrow;
    }
  }

  /// 퀴즈 완료
  ///
  /// 서버에 퀴즈 완료를 알리고 결과를 받아옴
  ///
  /// Returns: QuizResult
  Future<QuizResult> completeQuiz(
    int chapterId,
    List<Map<String, int>> answers,
  ) async {
    try {
      // 서버에서 퀴즈 완료 처리
      final result = await _api.completeQuiz(chapterId, answers);

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

  /// 퀴즈 결과 조회 (로컬에서만)
  ///
  /// 특정 챕터의 퀴즈 결과 목록 조회 (로컬 캐시만 사용)
  ///
  /// Returns: `List<QuizResult>`
  Future<List<QuizResult>> getQuizResults(int chapterId) async {
    try {
      return await _getLocalQuizResults(chapterId);
    } catch (e) {
      debugPrint('퀴즈 결과 조회 실패: $e');
      return [];
    }
  }

  /// 현재 진행 중인 퀴즈 세션 조회 (로컬에서만)
  ///
  /// Returns: QuizSession? (null이면 진행 중인 퀴즈 없음)
  Future<QuizSession?> getCurrentQuizSession() async {
    try {
      return await _getLocalQuizProgress();
    } catch (e) {
      debugPrint('현재 퀴즈 세션 조회 실패: $e');
      return null;
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

  /// 로컬 진행 상황에서 답안 업데이트 (인덱스 기반)
  Future<void> updateLocalAnswer(
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
      debugPrint('로컬 답안 업데이트 실패: $e');
    }
  }

  /// 로컬 진행 상황 업데이트 (퀴즈 ID 기반)
  Future<void> _updateLocalProgressForQuizId(
    int chapterId,
    int currentQuizId,
  ) async {
    try {
      final session = await _getLocalQuizProgress();
      if (session != null && session.chapterId == chapterId) {
        final updatedSession = session.copyWith(currentQuizId: currentQuizId);
        await _saveQuizProgress(updatedSession);
      }
    } catch (e) {
      debugPrint('로컬 퀴즈 ID 업데이트 실패: $e');
    }
  }

  /// 로컬에서 퀴즈 진행 상황 조회
  Future<QuizSession?> _getLocalQuizProgress() async {
    try {
      final allKeys = await _storage.readAll();
      for (final entry in allKeys.entries) {
        if (entry.key.startsWith(_quizProgressKey)) {
          final json = jsonDecode(entry.value);
          return QuizSession.fromLocalJson(json as Map<String, dynamic>);
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
        results = existingList
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
