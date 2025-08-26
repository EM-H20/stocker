import 'package:flutter/material.dart';
import '../domain/wrong_note_repository.dart';
import '../data/wrong_note_mock_repository.dart';
import '../data/models/wrong_note_request.dart';
import '../data/models/wrong_note_response.dart';

/// 오답노트 상태 관리 Provider
class WrongNoteProvider extends ChangeNotifier {
  final WrongNoteRepository? _repository;
  final WrongNoteMockRepository? _mockRepository;

  // 상태 변수들
  List<WrongNoteItem> _wrongNotes = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<WrongNoteItem> get wrongNotes => _wrongNotes;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  /// 실제 API Repository 사용 생성자
  WrongNoteProvider(this._repository) : _mockRepository = null;

  /// Mock Repository 사용 생성자
  WrongNoteProvider.withMock(this._mockRepository) : _repository = null;

  /// 오답노트 목록 로드
  Future<void> loadWrongNotes() async {
    _setLoading(true);
    _clearError();

    try {
      final WrongNoteResponse response;
      
      if (_mockRepository != null) {
        // Mock 데이터 사용
        response = await _mockRepository.getWrongNotes('mock_user');
      } else if (_repository != null) {
        // 실제 API 사용
        response = await _repository.getWrongNotes();
      } else {
        throw Exception('Repository가 설정되지 않았습니다.');
      }

      _wrongNotes = response.wrongNotes;
      notifyListeners();
    } catch (e) {
      _setError('오답노트 로드 실패: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 퀴즈 결과 제출
  Future<void> submitQuizResults(WrongNoteRequest request) async {
    try {
      if (_mockRepository != null) {
        await _mockRepository.submitQuizResults(request);
      } else if (_repository != null) {
        await _repository.submitQuizResults(request);
      }

      // 제출 후 오답노트 다시 로드
      await loadWrongNotes();
    } catch (e) {
      _setError('퀴즈 결과 제출 실패: $e');
    }
  }

  /// 문제 재시도 표시
  Future<void> markAsRetried(int quizId) async {
    try {
      if (_mockRepository != null) {
        await _mockRepository.markAsRetried('mock_user', quizId);
      } else if (_repository != null) {
        await _repository.markAsRetried(quizId);
      }

      // 로컬 상태 업데이트
      final index = _wrongNotes.indexWhere((item) => item.quizId == quizId);
      if (index != -1) {
        _wrongNotes[index] = _wrongNotes[index].copyWith(isRetried: true);
        notifyListeners();
      }
    } catch (e) {
      _setError('재시도 표시 실패: $e');
    }
  }

  /// 오답노트에서 문제 삭제 (정답 처리 시)
  Future<void> removeWrongNote(int quizId) async {
    try {
      if (_mockRepository != null) {
        await _mockRepository.removeWrongNote('mock_user', quizId);
      } else if (_repository != null) {
        await _repository.removeWrongNote(quizId);
      }

      // 로컬 상태에서 제거
      _wrongNotes.removeWhere((item) => item.quizId == quizId);
      notifyListeners();
    } catch (e) {
      _setError('오답노트 삭제 실패: $e');
    }
  }

  /// 챕터별 필터링
  List<WrongNoteItem> getWrongNotesByChapter(int chapterId) {
    return _wrongNotes.where((item) => item.chapterId == chapterId).toList();
  }

  /// 재시도 여부별 필터링
  List<WrongNoteItem> getWrongNotesByRetryStatus(bool isRetried) {
    return _wrongNotes.where((item) => item.isRetried == isRetried).toList();
  }

  /// 통계 정보 가져오기
  Map<String, int> getStatistics() {
    final totalCount = _wrongNotes.length;
    final retriedCount = _wrongNotes.where((item) => item.isRetried).length;
    final pendingCount = totalCount - retriedCount;

    return {
      'total': totalCount,
      'retried': retriedCount,
      'pending': pendingCount,
    };
  }

  /// 로딩 상태 설정
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// 에러 설정
  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  /// 에러 클리어
  void _clearError() {
    _errorMessage = null;
  }

  /// 에러 클리어 (외부에서 호출 가능)
  void clearError() {
    _clearError();
    notifyListeners();
  }
}
