// FILE: lib/features/note/data/source/note_api.dart
import 'package:dio/dio.dart';
import '../dto/note_dto.dart';
import '../dto/note_update_request.dart';

/// 노트 관련 API를 호출하는 클래스
class NoteApi {
  final Dio _dio;
  NoteApi(this._dio);

  /// 모든 노트 목록 조회 API
  Future<List<NoteDto>> getAllNotes() async {
    final response = await _dio.get('/api/memo');  // ✅ 백엔드 라우트와 일치
    final List<dynamic> data = response.data as List<dynamic>? ?? [];
    return data.map((json) => NoteDto.fromJson(json)).toList();
  }

  /// 새 노트 생성 API  
  Future<NoteDto> createNote(NoteUpdateRequest request) async {
    final response = await _dio.put(  // ✅ 백엔드는 PUT으로 저장·갱신
      '/api/memo',
      data: request.toJson(),
    );
    return NoteDto.fromJson(response.data);
  }

  /// 노트 수정 API
  Future<NoteDto> updateNote(int noteId, NoteUpdateRequest request) async {
    final response = await _dio.put(  // ✅ 백엔드는 PUT으로 저장·갱신
      '/api/memo',
      data: request.toJson(),
    );
    return NoteDto.fromJson(response.data);
  }

  /// 노트 삭제 API
  Future<void> deleteNote(int noteId) async {
    await _dio.delete('/api/memo/$noteId');  // ✅ 백엔드 라우트와 일치
  }
}
