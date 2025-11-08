// FILE: lib/features/note/data/source/note_api.dart
import 'package:dio/dio.dart';
import '../dto/note_dto.dart';
import '../dto/note_update_request.dart';
import '../../../../app/core/services/token_storage.dart';

/// 노트 관련 API를 호출하는 클래스
class NoteApi {
  final Dio _dio;
  NoteApi(this._dio);

  /// 인증 헤더를 추가하는 헬퍼 메서드
  Future<Options> _getAuthOptions() async {
    final access = await TokenStorage.accessToken;
    final refresh = await TokenStorage.refreshToken;

    return Options(headers: {
      if (access != null && access.isNotEmpty)
        'Authorization': 'Bearer $access',
      if (refresh != null && refresh.isNotEmpty) 'x-refresh-token': refresh,
      'Content-Type': 'application/json',
    });
  }

  /// 모든 노트 목록 조회 API
  Future<List<NoteDto>> getAllNotes() async {
    final options = await _getAuthOptions();
    final response = await _dio.get('/api/memo/', options: options);

    // API 응답이 { "memos": [...] } 형식인지 확인
    final data = response.data;
    List<dynamic> memosList;

    if (data is Map<String, dynamic> && data.containsKey('memos')) {
      memosList = data['memos'] as List<dynamic>? ?? [];
    } else if (data is List<dynamic>) {
      memosList = data;
    } else {
      memosList = [];
    }

    return memosList.map((json) => NoteDto.fromJson(json)).toList();
  }

  /// 새 노트 생성 API
  Future<NoteDto> createNote(NoteUpdateRequest request) async {
    final options = await _getAuthOptions();
    final response = await _dio.put(
      '/api/memo/',
      data: request.toJson(),
      options: options,
    );

    // API 응답이 { "memo": {...} } 형식인지 확인
    final data = response.data;
    if (data is Map<String, dynamic> && data.containsKey('memo')) {
      return NoteDto.fromJson(data['memo']);
    } else {
      return NoteDto.fromJson(data);
    }
  }

  /// 노트 수정 API
  Future<NoteDto> updateNote(int noteId, NoteUpdateRequest request) async {
    final options = await _getAuthOptions();

    // 수정 시에는 id 필드를 요청에 포함
    final requestData = request.toJson();
    requestData['id'] = noteId;

    final response = await _dio.put(
      '/api/memo/',
      data: requestData,
      options: options,
    );

    // API 응답이 { "memo": {...} } 형식인지 확인
    final data = response.data;
    if (data is Map<String, dynamic> && data.containsKey('memo')) {
      return NoteDto.fromJson(data['memo']);
    } else {
      return NoteDto.fromJson(data);
    }
  }

  /// 노트 삭제 API
  Future<void> deleteNote(int noteId) async {
    final options = await _getAuthOptions();
    await _dio.delete('/api/memo/$noteId', options: options);
  }
}
