import 'package:dio/dio.dart';
import '../dto/memo_request.dart';
import '../dto/memo_response.dart';
import '../../../../app/core/services/token_storage.dart';

/// 메모 시스템 API 통신 클래스
/// API.md 명세 기반으로 구현
class MemoApi {
  final Dio _dio;

  MemoApi(this._dio);

  /// 인증 헤더를 추가하는 헬퍼 메서드
  Future<Options> _getAuthOptions() async {
    final access = await TokenStorage.accessToken;
    final refresh = await TokenStorage.refreshToken;

    return Options(headers: {
      if (access != null && access.isNotEmpty)
        'Authorization': 'Bearer $access',
      if (refresh != null && refresh.isNotEmpty) 'x-refresh-token': refresh,
    });
  }

  /// 유저 메모 전체 조회
  /// API.md 명세: GET /api/memo/
  Future<MemoListResponse> getAllMemos() async {
    final options = await _getAuthOptions();

    final response = await _dio.get(
      '/api/memo/',
      options: options,
    );

    return MemoListResponse.fromJson(response.data);
  }

  /// 메모 저장·갱신
  /// API.md 명세: PUT /api/memo/
  Future<MemoSingleResponse> saveMemo(MemoRequest request) async {
    final options = await _getAuthOptions();

    final response = await _dio.put(
      '/api/memo/',
      data: request.toJson(),
      options: options,
    );

    return MemoSingleResponse.fromJson(response.data);
  }

  /// 메모 삭제
  /// API.md 명세: DELETE /api/memo/{id}
  Future<MemoDeleteResponse> deleteMemo(int memoId) async {
    final options = await _getAuthOptions();

    final response = await _dio.delete(
      '/api/memo/$memoId',
      options: options,
    );

    return MemoDeleteResponse.fromJson(response.data);
  }
}

/// 메모 템플릿 타입 열거형
enum MemoTemplateType {
  diary('일기'),
  journal('일지'),
  checklist('체크리스트');

  const MemoTemplateType(this.displayName);
  final String displayName;

  /// 문자열로부터 템플릿 타입 생성
  static MemoTemplateType fromString(String value) {
    return MemoTemplateType.values.firstWhere(
      (type) => type.displayName == value,
      orElse: () => MemoTemplateType.journal,
    );
  }

  @override
  String toString() => displayName;
}
