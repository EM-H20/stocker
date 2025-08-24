
// FILE: lib/features/note/data/repository/note_mock_repository.dart
import '../../domain/model/note.dart';
import '../../domain/repository/note_repository.dart';
import '../dto/note_update_request.dart';

/// 테스트용 더미 데이터를 반환하는 Repository 구현체
class NoteMockRepository implements NoteRepository {
  // Mock 데이터를 저장할 리스트
  final List<Note> _mockNotes = [
    Note(
      id: 1,
      title: '나의 첫 투자 노트',
      content: '[{"insert":"삼성전자 매수 이유 분석\\n"}]',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Note(
      id: 2,
      title: '재무제표 분석 템플릿 사용기',
      content: '[{"insert":"매출액: 1,000억\\n영업이익: 100억\\n"}]',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now(),
    ),
  ];
  int _nextId = 3;

  @override
  Future<List<Note>> getAllNotes() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockNotes;
  }

  @override
  Future<Note> createNote(NoteUpdateRequest request) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final newNote = Note(
      id: _nextId++,
      title: request.title,
      content: request.content,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _mockNotes.add(newNote);
    return newNote;
  }

  @override
  Future<Note> updateNote(int noteId, NoteUpdateRequest request) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _mockNotes.indexWhere((note) => note.id == noteId);
    if (index != -1) {
      final updatedNote = Note(
        id: noteId,
        title: request.title,
        content: _mockNotes[index].content, // Mock에서는 content 수정은 제외
        createdAt: _mockNotes[index].createdAt,
        updatedAt: DateTime.now(),
      );
      _mockNotes[index] = updatedNote;
      return updatedNote;
    }
    throw Exception('Note not found');
  }

  @override
  Future<void> deleteNote(int noteId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _mockNotes.removeWhere((note) => note.id == noteId);
  }
}