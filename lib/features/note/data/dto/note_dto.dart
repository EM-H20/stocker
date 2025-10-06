
import '../../domain/model/note.dart';

class NoteDto {
  final int id;
  final int userId;
  final String templateType;
  final Map<String, dynamic> content;
  final String createdAt;

  NoteDto({
    required this.id,
    required this.userId,
    required this.templateType,
    required this.content,
    required this.createdAt,
  });

  factory NoteDto.fromJson(Map<String, dynamic> json) {
    return NoteDto(
      id: json['id'] as int? ?? 0,
      userId: json['user_id'] as int? ?? 0,
      templateType: json['template_type'] as String? ?? '일지',
      content: json['content'] as Map<String, dynamic>? ?? {},
      createdAt: json['created_at'] as String? ?? DateTime.now().toIso8601String(),
    );
  }

  Note toModel() {
    // content 객체에서 title과 text 추출
    String title = '제목 없음';
    String contentText = '[{"insert":"\\n"}]'; // Quill 빈 문서 기본값

    if (content.isNotEmpty) {
      title = content['title'] as String? ?? '제목 없음';
      final textData = content['text'];
      
      if (textData is String && textData.isNotEmpty) {
        contentText = textData;
      }
    }

    return Note(
      id: id,
      title: title,
      content: contentText,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(createdAt), // 서버에 updated_at이 없으므로 created_at 사용
    );
  }
}