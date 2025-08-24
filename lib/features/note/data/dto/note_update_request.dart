// FILE: lib/features/note/data/dto/note_update_request.dart
/// 새 노트를 저장하거나 기존 노트를 수정할 때 서버에 보내는 DTO
class NoteUpdateRequest {
  final String title;
  final String content;

  NoteUpdateRequest({
    required this.title,
    required this.content,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
    };
  }
}