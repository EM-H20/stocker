import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

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
    debugPrint('🔍 [ERROR_EXTRACTOR] Extracting message from: ${error.runtimeType}');

    // 1. DioException인 경우 response.data에서 직접 추출 (가장 정확)
    if (error is DioException) {
      final responseData = error.response?.data;
      debugPrint('🔍 [ERROR_EXTRACTOR] Response data: $responseData');

      if (responseData is Map<String, dynamic>) {
        final message = responseData['message'];
        if (message is String && message.isNotEmpty) {
          debugPrint('✅ [ERROR_EXTRACTOR] Extracted from response.data: $message');
          return message;
        }
      }

      // response.data가 String인 경우 (JSON 문자열)
      if (responseData is String && responseData.isNotEmpty) {
        final extracted = _extractFromJsonString(responseData);
        if (extracted != null) {
          debugPrint('✅ [ERROR_EXTRACTOR] Extracted from JSON string: $extracted');
          return extracted;
        }
      }
    }

    // 2. 문자열 파싱 폴백
    final errorString = error.toString();

    // 네트워크 관련 에러 체크
    if (errorString.contains('No host specified') ||
        errorString.contains('Connection refused') ||
        errorString.contains('timeout') ||
        errorString.contains('SocketException')) {
      return '네트워크 연결에 문제가 있습니다. 연결 상태를 확인하고 다시 시도해주세요.';
    }

    // DioException 문자열에서 message 추출 시도
    if (errorString.contains('DioException')) {
      final extracted = _extractFromJsonString(errorString);
      if (extracted != null) {
        debugPrint('✅ [ERROR_EXTRACTOR] Extracted from error string: $extracted');
        return extracted;
      }
    }

    debugPrint('⚠️ [ERROR_EXTRACTOR] Using fallback message');
    return fallbackMessage;
  }

  /// JSON 문자열에서 "message" 필드 값 추출
  static String? _extractFromJsonString(String jsonString) {
    try {
      // 정규식으로 "message": "값" 또는 "message":"값" 패턴 매칭
      // 공백 유무에 관계없이 처리
      final regex = RegExp(r'"message"\s*:\s*"([^"]*)"');
      final match = regex.firstMatch(jsonString);

      if (match != null && match.group(1) != null) {
        final message = match.group(1)!;
        if (message.isNotEmpty) {
          return message;
        }
      }
    } catch (e) {
      debugPrint('⚠️ [ERROR_EXTRACTOR] Regex extraction failed: $e');
    }
    return null;
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
