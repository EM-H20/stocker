// FILE: lib/features/note/data/dto/note_update_request.dart

/// 새 노트를 저장하거나 기존 노트를 수정할 때 서버에 보내는 DTO
class NoteUpdateRequest {
  final String title;
  final String content;
  final String templateType;

  NoteUpdateRequest({
    required this.title,
    required this.content,
    this.templateType = '일지',
  });

  Map<String, dynamic> toJson() {
    return {
      'template_type': templateType,
      'content': {
        'title': title,
        'text': content, // Quill JSON 텍스트를 여기에 저장
      },
    };
  }
}
