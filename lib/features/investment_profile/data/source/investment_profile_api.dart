import 'package:dio/dio.dart';
import '../dto/investment_test_response.dart';
import '../dto/investment_result_request.dart';
import '../dto/investment_result_response.dart';
import '../../../../app/core/services/token_storage.dart';

/// 투자성향 검사 관련 API 통신 클래스
/// API.md 명세 기반으로 구현
class InvestmentProfileApi {
  final Dio _dio;

  InvestmentProfileApi(this._dio);

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

  /// 투자성향 검사지 조회
  /// API.md 명세: GET /api/investment_profile/test?version=v1.1
  Future<InvestmentTestResponse> getInvestmentTest(
      {String version = 'v1.1'}) async {
    final options = await _getAuthOptions();

    final response = await _dio.get(
      '/api/investment_profile/test',
      queryParameters: {'version': version},
      options: options,
    );

    return InvestmentTestResponse.fromJson(response.data);
  }

  /// 투자성향 검사 결과 최초 저장
  /// API.md 명세: POST /api/investment_profile/result
  Future<InvestmentResultResponse> submitInvestmentResult(
      InvestmentResultRequest request) async {
    final options = await _getAuthOptions();

    final response = await _dio.post(
      '/api/investment_profile/result',
      data: request.toJson(),
      options: options,
    );

    return InvestmentResultResponse.fromJson(response.data);
  }

  /// 투자성향 검사 결과 조회
  /// API.md 명세: GET /api/investment_profile/result
  Future<InvestmentResultResponse?> getInvestmentResult() async {
    final options = await _getAuthOptions();

    try {
      final response = await _dio.get(
        '/api/investment_profile/result',
        options: options,
      );

      if (response.data['profile'] == null) {
        return null; // 결과가 없는 경우
      }

      return InvestmentResultResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null; // 결과가 없는 경우
      }
      rethrow;
    }
  }

  /// 투자성향 검사 재검사 (갱신)
  /// API.md 명세: PUT /api/investment_profile/result
  Future<InvestmentResultResponse> updateInvestmentResult(
      InvestmentResultRequest request) async {
    final options = await _getAuthOptions();

    final response = await _dio.put(
      '/api/investment_profile/result',
      data: request.toJson(),
      options: options,
    );

    return InvestmentResultResponse.fromJson(response.data);
  }

  /// 모든 투자 거장 정보 조회
  /// API.md 명세: GET /api/investment_profile/masters
  Future<List<InvestmentMaster>> getAllMasters() async {
    final options = await _getAuthOptions();

    final response = await _dio.get(
      '/api/investment_profile/masters',
      options: options,
    );

    return (response.data as List<dynamic>)
        .map((masterData) =>
            InvestmentMaster.fromJson(masterData as Map<String, dynamic>))
        .toList();
  }
}
