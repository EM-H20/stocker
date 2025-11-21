/// 서버 에러 메시지 추출 유틸리티
///
/// DioException에서 서버가 보낸 `message` 필드를 추출합니다.
class ErrorMessageExtractor {
  /// DioException에서 서버 메시지 추출
  ///
  /// 서버 응답의 JSON에서 "message" 필드를 찾아 반환합니다.
  /// 추출 실패 시 [fallbackMessage]를 반환합니다.
  static String extractServerMessage(
    dynamic error, {
    String fallbackMessage = '서버와의 통신에 실패했습니다.',
  }) {
    final errorString = error.toString();

    // DioException인지 확인
    if (!errorString.contains('DioException')) {
      // 네트워크 관련 에러 체크
      if (errorString.contains('No host specified') ||
          errorString.contains('Connection refused') ||
          errorString.contains('timeout') ||
          errorString.contains('SocketException')) {
        return '네트워크 연결에 문제가 있습니다. 연결 상태를 확인하고 다시 시도해주세요.';
      }
      return fallbackMessage;
    }

    try {
      // JSON response에서 message 필드 추출
      if (errorString.contains('"message":')) {
        final messageStart = errorString.indexOf('"message":') + 11;
        final messageEnd = errorString.indexOf('"', messageStart);

        if (messageEnd > messageStart) {
          final extractedMessage =
              errorString.substring(messageStart, messageEnd);
          return extractedMessage;
        }
      }
    } catch (_) {
      // 추출 실패 시 fallback
    }

    return fallbackMessage;
  }

  /// 인증 관련 에러 메시지 추출 (fallback 메시지 커스터마이징)
  static String extractAuthError(dynamic error) {
    return extractServerMessage(
      error,
      fallbackMessage: '인증 처리 중 문제가 발생했습니다. 다시 시도해주세요.',
    );
  }

  /// 데이터 로딩 관련 에러 메시지 추출
  static String extractDataLoadError(dynamic error, String dataType) {
    return extractServerMessage(
      error,
      fallbackMessage: '$dataType 정보를 불러올 수 없습니다. 잠시 후 다시 시도해주세요.',
    );
  }

  /// 제출/저장 관련 에러 메시지 추출
  static String extractSubmissionError(dynamic error, String action) {
    return extractServerMessage(
      error,
      fallbackMessage: '$action 처리 중 문제가 발생했습니다. 다시 시도해주세요.',
    );
  }
}
