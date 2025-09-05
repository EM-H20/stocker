// FILE: lib/features/note/domain/model/note.dart
/// 노트 한 개를 나타내는 도메인 모델
class Note {
  final int id;
  final String title;
  final String content; // Quill 에디터의 Delta(JSON) 데이터가 저장될 필드
  final DateTime createdAt;
  final DateTime updatedAt;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });
}
