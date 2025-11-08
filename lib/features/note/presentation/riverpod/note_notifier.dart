import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/repository/note_repository.dart';
import '../../domain/model/note.dart';
import '../../data/dto/note_update_request.dart';
import '../../../../app/core/providers/riverpod/repository_providers.dart';
import 'note_state.dart';

part 'note_notifier.g.dart';

/// 🔥 Riverpod 기반 노트 상태 관리 Notifier
@riverpod
class NoteNotifier extends _$NoteNotifier {
  @override
  NoteState build() {
    // 초기 상태 생성
    return const NoteState();
  }

  /// NoteRepository 접근
  NoteRepository get _repository => ref.read(noteRepositoryProvider);

  /// 모든 노트 조회
  Future<void> fetchAllNotes() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final notes = await _repository.getAllNotes();

      // updatedAt 기준 내림차순 정렬
      notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

      state = state.copyWith(
        notes: notes,
        isLoading: false,
        errorMessage: null,
      );

      debugPrint('✅ [NOTE] 노트 목록 로드 완료: ${notes.length}개');
    } catch (e) {
      debugPrint('❌ [NOTE] 노트 로딩 실패: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: '노트를 불러오는 데 실패했습니다: ${e.toString()}',
      );
    }
  }

  /// 노트 생성
  Future<Note?> createNote(NoteUpdateRequest request) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final newNote = await _repository.createNote(request);

      debugPrint('✅ [NOTE] 노트 생성 완료: ${newNote.id}');

      // 노트 목록 새로고침
      await fetchAllNotes();

      return newNote;
    } catch (e) {
      debugPrint('❌ [NOTE] 노트 생성 실패: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: '노트 생성에 실패했습니다: ${e.toString()}',
      );
      return null;
    }
  }

  /// 노트 수정
  Future<bool> updateNote(int noteId, NoteUpdateRequest request) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _repository.updateNote(noteId, request);

      debugPrint('✅ [NOTE] 노트 수정 완료: $noteId');

      // 노트 목록 새로고침
      await fetchAllNotes();

      return true;
    } catch (e) {
      debugPrint('❌ [NOTE] 노트 수정 실패: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: '노트 수정에 실패했습니다: ${e.toString()}',
      );
      return false;
    }
  }

  /// 노트 삭제
  Future<bool> deleteNote(int noteId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _repository.deleteNote(noteId);

      debugPrint('✅ [NOTE] 노트 삭제 완료: $noteId');

      // 노트 목록 새로고침
      await fetchAllNotes();

      return true;
    } catch (e) {
      debugPrint('❌ [NOTE] 노트 삭제 실패: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: '노트 삭제에 실패했습니다: ${e.toString()}',
      );
      return false;
    }
  }
}
