/// API 관련 예외 처리를 위한 커스텀 예외 클래스
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? code;
  final String? userFriendlyMessage;

  ApiException(
    this.message, {
    this.statusCode,
    this.code,
    this.userFriendlyMessage,
  });

  /// DioException을 ApiException으로 변환하는 팩토리
  factory ApiException.fromDio(dynamic error) {
    if (error == null) {
      return ApiException('알 수 없는 오류가 발생했습니다.');
    }

    String message = error.toString();
    int? statusCode;
    String? code;
    String? userMessage;

    // DioException의 경우
    try {
      statusCode = error.response?.statusCode;
      
      // 백엔드 에러 응답 구조 파싱
      if (error.response?.data is Map<String, dynamic>) {
        final data = error.response!.data as Map<String, dynamic>;
        message = data['message'] ?? message;
        code = data['code'];
      }

      // 인터셉터에서 설정된 사용자 친화적 메시지 사용
      userMessage = error.requestOptions?.extra['userMessage'] as String?;

      // 상태 코드별 기본 메시지
      userMessage ??= _getDefaultUserMessage(statusCode);
      
    } catch (e) {
      // 파싱 실패 시 기본 처리
    }

    return ApiException(
      message,
      statusCode: statusCode,
      code: code,
      userFriendlyMessage: userMessage ?? '요청 처리 중 문제가 발생했습니다.',
    );
  }

  /// 상태 코드별 기본 사용자 메시지 반환
  static String _getDefaultUserMessage(int? statusCode) {
    switch (statusCode) {
      case 400:
        return '잘못된 요청입니다. 입력 정보를 확인해주세요.';
      case 401:
        return '로그인이 필요합니다. 다시 로그인해주세요.';
      case 403:
        return '접근 권한이 없습니다.';
      case 404:
        return '요청하신 정보를 찾을 수 없습니다.';
      case 429:
        return '너무 많은 요청입니다. 잠시 후 다시 시도해주세요.';
      case 500:
        return '서버에 문제가 발생했습니다. 잠시 후 다시 시도해주세요.';
      case 502:
      case 503:
      case 504:
        return '서버가 일시적으로 사용할 수 없습니다.';
      default:
        return '네트워크 오류가 발생했습니다.';
    }
  }

  @override
  String toString() {
    return 'ApiException(message: $message, statusCode: $statusCode, code: $code)';
  }

  /// 디버깅용 상세 정보
  String get debugInfo {
    return '''
ApiException Details:
- Message: $message
- Status Code: $statusCode
- Error Code: $code
- User Message: $userFriendlyMessage
    ''';
  }
}