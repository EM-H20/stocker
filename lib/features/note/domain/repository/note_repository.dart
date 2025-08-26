// FILE: lib/features/note/domain/repository/note_repository.dart
import '../model/note.dart';
import '../../data/dto/note_update_request.dart';

/// 노트 관련 데이터 처리를 위한 Repository 추상 클래스 (설계도)
abstract class NoteRepository {
  /// 사용자의 모든 노트를 가져옵니다.
  Future<List<Note>> getAllNotes();

  /// 새 노트를 생성합니다.
  Future<Note> createNote(NoteUpdateRequest request);

  /// 기존 노트를 수정합니다.
  Future<Note> updateNote(int noteId, NoteUpdateRequest request);

  /// 특정 노트를 삭제합니다.
  Future<void> deleteNote(int noteId);
}
