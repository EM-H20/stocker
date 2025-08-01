import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../data/education_api.dart';
import '../data/chapter_card_response.dart';
import '../data/theory_enter_request.dart';
import '../data/theory_enter_response.dart';
import '../data/theory_update_request.dart';
import '../data/theory_completed_request.dart';
import 'models/chapter_info.dart';
import 'models/theory_session.dart';

/// Education 관련 Repository 클래스
/// API 통신과 로컬 저장소를 통합하여 데이터 관리
/// ViewModel이 사용할 유일한 데이터 인터페이스
class EducationRepository {
  final EducationApi _api;
  final FlutterSecureStorage _storage;

  // 로컬 저장소 키 상수
  static const String _chaptersKey = 'education_chapters';
  static const String _currentTheoryKey = 'current_theory_data';
  static const String _theoryProgressKey = 'theory_progress_';

  EducationRepository(this._api, this._storage);

  /// 챕터 목록 조회
  ///
  /// 1. 로컬 캐시 확인
  /// 2. 캐시가 없거나 만료된 경우 API 호출
  /// 3. 새 데이터를 로컬에 저장
  ///
  /// Returns: List ChapterInfo
  /// Throws: Exception on error
  Future<List<ChapterInfo>> getChapters({bool forceRefresh = false}) async {
    try {
      // 강제 새로고침이 아닌 경우 로컬 캐시 확인
      if (!forceRefresh) {
        final cachedChapters = await _getCachedChapters();
        if (cachedChapters != null && cachedChapters.isNotEmpty) {
          return cachedChapters.map(_mapToChapterInfo).toList();
        }
      }

      // API에서 최신 데이터 가져오기
      final chapters = await _api.getChapters();

      // 로컬 캐시에 저장
      await _cacheChapters(chapters);

      // Domain 모델로 변환하여 반환
      return chapters.map(_mapToChapterInfo).toList();
    } catch (e) {
      // API 호출 실패 시 캐시된 데이터라도 반환 시도
      final cachedChapters = await _getCachedChapters();
      if (cachedChapters != null && cachedChapters.isNotEmpty) {
        return cachedChapters.map(_mapToChapterInfo).toList();
      }

      throw Exception('챕터 목록 조회 실패: $e');
    }
  }

  /// 이론 진입
  ///
  /// [chapterId]: 진입할 챕터 ID
  /// Returns: TheorySession
  /// Throws: Exception on error
  Future<TheorySession> enterTheory(int chapterId) async {
    try {
      final request = TheoryEnterRequest(chapterId: chapterId);
      final response = await _api.enterTheory(request);

      // 현재 이론 데이터를 로컬에 저장
      await _cacheCurrentTheory(response);

      // Domain 모델로 변환하여 반환
      return _mapToTheorySession(response);
    } catch (e) {
      throw Exception('이론 진입 실패: $e');
    }
  }

  /// 이론 진도 갱신
  ///
  /// [chapterId]: 챕터 ID
  /// [currentTheoryId]: 현재 조회 중인 이론 ID
  /// Returns: void
  /// Throws: Exception on error
  Future<void> updateTheoryProgress(int chapterId, int currentTheoryId) async {
    try {
      final request = TheoryUpdateRequest(
        chapterId: chapterId,
        currentTheoryId: currentTheoryId,
      );

      await _api.updateTheoryProgress(request);

      // 로컬 진도 정보 업데이트
      await _saveTheoryProgress(chapterId, currentTheoryId);
    } catch (e) {
      throw Exception('이론 진도 갱신 실패: $e');
    }
  }

  /// 이론 완료 처리
  ///
  /// [chapterId]: 완료할 챕터 ID
  /// Returns: void
  /// Throws: Exception on error
  Future<void> completeTheory(int chapterId) async {
    try {
      final request = TheoryCompletedRequest(chapterId: chapterId);
      await _api.completeTheory(request);

      // 로컬 캐시 업데이트 (해당 챕터의 이론 완료 상태 변경)
      await _updateChapterTheoryCompletion(chapterId, true);

      // 현재 이론 데이터 삭제
      await _clearCurrentTheory();
    } catch (e) {
      throw Exception('이론 완료 처리 실패: $e');
    }
  }

  /// 로컬에 저장된 이론 진도 조회
  ///
  /// [chapterId]: 챕터 ID
  /// Returns: 마지막 조회한 이론 ID (없으면 null)
  Future<int?> getTheoryProgress(int chapterId) async {
    try {
      final progressStr = await _storage.read(
        key: '$_theoryProgressKey$chapterId',
      );
      return progressStr != null ? int.parse(progressStr) : null;
    } catch (e) {
      return null;
    }
  }

  /// 현재 이론 데이터 조회 (로컬 캐시)
  ///
  /// Returns: 캐시된 TheorySession (없으면 null)
  Future<TheorySession?> getCurrentTheory() async {
    try {
      final theoryStr = await _storage.read(key: _currentTheoryKey);
      if (theoryStr != null) {
        final json = jsonDecode(theoryStr) as Map<String, dynamic>;
        final response = TheoryEnterResponse.fromJson(json);
        return _mapToTheorySession(response);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 로컬 캐시 전체 삭제
  Future<void> clearCache() async {
    try {
      await _storage.delete(key: _chaptersKey);
      await _storage.delete(key: _currentTheoryKey);

      // 모든 이론 진도 데이터 삭제
      final allKeys = await _storage.readAll();
      for (final key in allKeys.keys) {
        if (key.startsWith(_theoryProgressKey)) {
          await _storage.delete(key: key);
        }
      }
    } catch (e) {
      // 캐시 삭제 실패는 무시
    }
  }

  // === Private Helper Methods ===

  /// 캐시된 챕터 목록 조회
  Future<List<ChapterCardResponse>?> _getCachedChapters() async {
    try {
      final chaptersStr = await _storage.read(key: _chaptersKey);
      if (chaptersStr != null) {
        final List<dynamic> jsonList = jsonDecode(chaptersStr) as List<dynamic>;
        return jsonList
            .map(
              (json) =>
                  ChapterCardResponse.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 챕터 목록을 로컬에 캐시
  Future<void> _cacheChapters(List<ChapterCardResponse> chapters) async {
    try {
      final jsonList = chapters.map((chapter) => chapter.toJson()).toList();
      await _storage.write(key: _chaptersKey, value: jsonEncode(jsonList));
    } catch (e) {
      // 캐시 저장 실패는 무시
    }
  }

  /// 현재 이론 데이터를 로컬에 캐시
  Future<void> _cacheCurrentTheory(TheoryEnterResponse response) async {
    try {
      await _storage.write(
        key: _currentTheoryKey,
        value: jsonEncode(response.toJson()),
      );
    } catch (e) {
      // 캐시 저장 실패는 무시
    }
  }

  /// 현재 이론 데이터 삭제
  Future<void> _clearCurrentTheory() async {
    try {
      await _storage.delete(key: _currentTheoryKey);
    } catch (e) {
      // 삭제 실패는 무시
    }
  }

  /// 이론 진도 저장
  Future<void> _saveTheoryProgress(int chapterId, int currentTheoryId) async {
    try {
      await _storage.write(
        key: '$_theoryProgressKey$chapterId',
        value: currentTheoryId.toString(),
      );
    } catch (e) {
      // 진도 저장 실패는 무시
    }
  }

  /// 챕터의 이론 완료 상태 업데이트
  Future<void> _updateChapterTheoryCompletion(
    int chapterId,
    bool isCompleted,
  ) async {
    try {
      final cachedChapters = await _getCachedChapters();
      if (cachedChapters != null) {
        final updatedChapters =
            cachedChapters.map((chapter) {
              if (chapter.chapterId == chapterId) {
                return chapter.copyWith(isTheoryCompleted: isCompleted);
              }
              return chapter;
            }).toList();

        await _cacheChapters(updatedChapters);
      }
    } catch (e) {
      // 캐시 업데이트 실패는 무시
    }
  }

  // === Data to Domain Model Mappers ===

  /// ChapterCardResponse를 ChapterInfo로 변환
  ChapterInfo _mapToChapterInfo(ChapterCardResponse response) {
    return ChapterInfo(
      id: response.chapterId,
      title: response.title,
      isTheoryCompleted: response.isTheoryCompleted,
      isQuizCompleted: response.isQuizCompleted,
    );
  }

  /// TheoryEnterResponse를 TheorySession으로 변환
  TheorySession _mapToTheorySession(TheoryEnterResponse response) {
    final theories =
        response.theories.map((theory) => theory.toDomain()).toList();

    // currentTheoryId를 인덱스로 변환
    final currentIndex = theories.indexWhere(
      (theory) => theory.id == response.currentTheoryId,
    );

    return TheorySession(
      chapterId: response.chapterId,
      chapterTitle: response.chapterTitle,
      theories: theories,
      currentTheoryIndex: currentIndex >= 0 ? currentIndex : 0,
    );
  }
}
