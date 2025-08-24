
// FILE: lib/features/note/data/repository/note_api_repository.dart
import '../../domain/model/note.dart';
import '../../domain/repository/note_repository.dart';
import '../dto/note_update_request.dart';
import '../source/note_api.dart';

/// 실제 API를 호출하는 Repository 구현체
class NoteApiRepository implements NoteRepository {
  final NoteApi _api;
  NoteApiRepository(this._api);

  @override
  Future<List<Note>> getAllNotes() async {
    final dtoList = await _api.getAllNotes();
    // DTO 리스트를 도메인 모델 리스트로 변환
    return dtoList.map((dto) => dto.toModel()).toList();
  }

  @override
  Future<Note> createNote(NoteUpdateRequest request) async {
    final dto = await _api.createNote(request);
    return dto.toModel();
  }

  @override
  Future<Note> updateNote(int noteId, NoteUpdateRequest request) async {
    final dto = await _api.updateNote(noteId, request);
    return dto.toModel();
  }

  @override
  Future<void> deleteNote(int noteId) {
    return _api.deleteNote(noteId);
  }
}
