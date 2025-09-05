import 'dart:convert'; // ✅ [추가] JSON 인코딩을 위해 import 합니다.
import '../../domain/model/note.dart';

/// 서버로부터 노트 데이터를 수신하는 DTO
class NoteDto {
  final int id;
  final String title;
  final String content;
  final String createdAt;
  final String updatedAt;

  NoteDto({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NoteDto.fromJson(Map<String, dynamic> json) {
    // ✅ [수정] content 필드를 안전하게 처리하는 로직
    String contentString;
    final dynamic contentData = json['content'];

    if (contentData is String) {
      // 이미 문자열 형태라면 그대로 사용
      contentString = contentData;
    } else if (contentData is Map || contentData is List) {
      // 만약 Map이나 List 형태(JSON 객체)라면, 문자열로 변환(encode)
      contentString = jsonEncode(contentData);
    } else {
      // 그 외의 경우 (null 등) Quill의 기본 빈 값으로 설정
      contentString = '[{"insert":"\\n"}]';
    }

    return NoteDto(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '제목 없음',
      content: contentString, // 안전하게 변환된 문자열 사용
      createdAt:
          json['created_at'] as String? ?? DateTime.now().toIso8601String(),
      updatedAt:
          json['updated_at'] as String? ?? DateTime.now().toIso8601String(),
    );
  }

  // toModel() 함수는 그대로 유지
  Note toModel() {
    return Note(
      id: id,
      title: title,
      content: content,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
    );
  }
}
