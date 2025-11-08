import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/model/note.dart';
import '../../domain/repository/note_repository.dart';
import '../../data/dto/note_update_request.dart';
import '../../../../app/core/providers/riverpod/repository_providers.dart';
import 'note_state.dart';

part 'note_notifier.g.dart';

@riverpod
class NoteNotifier extends _$NoteNotifier {
  @override
  NoteState build() {
    return const NoteState();
  }

  NoteRepository get _repository => ref.read(noteRepositoryProvider);

  Future<void> fetchAllNotes() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final notes = await _repository.getAllNotes();
      notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

      state = state.copyWith(
        notes: notes,
        isLoading: false,
      );

      debugPrint('[NOTE_NOTIFIER] Fetched ${notes.length} notes');
    } catch (e) {
      debugPrint('[NOTE_NOTIFIER] Failed to fetch notes: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: '노트를 불러오는 데 실패했습니다: ${e.toString()}',
      );
    }
  }

  Future<Note?> createNote(NoteUpdateRequest request) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final newNote = await _repository.createNote(request);
      await fetchAllNotes();

      debugPrint('[NOTE_NOTIFIER] Created note: ${newNote.id}');
      return newNote;
    } catch (e) {
      debugPrint('[NOTE_NOTIFIER] Failed to create note: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: '노트 생성에 실패했습니다: ${e.toString()}',
      );
      return null;
    }
  }

  Future<bool> updateNote(int noteId, NoteUpdateRequest request) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _repository.updateNote(noteId, request);
      await fetchAllNotes();

      debugPrint('[NOTE_NOTIFIER] Updated note: $noteId');
      return true;
    } catch (e) {
      debugPrint('[NOTE_NOTIFIER] Failed to update note: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: '노트 수정에 실패했습니다: ${e.toString()}',
      );
      return false;
    }
  }

  Future<bool> deleteNote(int noteId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _repository.deleteNote(noteId);
      await fetchAllNotes();

      debugPrint('[NOTE_NOTIFIER] Deleted note: $noteId');
      return true;
    } catch (e) {
      debugPrint('[NOTE_NOTIFIER] Failed to delete note: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: '노트 삭제에 실패했습니다: ${e.toString()}',
      );
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
