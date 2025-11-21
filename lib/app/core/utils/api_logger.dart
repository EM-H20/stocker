// lib/app/core/utils/api_logger.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

/// API 통신 로깅 유틸리티
///
/// Real API 모드에서 모든 API 요청/응답을 상세하게 로깅합니다.
/// 개발 환경에서만 동작하며, 운영 환경에서는 자동으로 비활성화됩니다.
class ApiLogger {
  /// API 요청 로깅
  ///
  /// [method]: HTTP 메서드 (GET, POST, PUT, DELETE 등)
  /// [url]: API 엔드포인트 URL
  /// [data]: Request Body (optional)
  /// [queryParameters]: Query Parameters (optional)
  static void logRequest({
    required String method,
    required String url,
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
  }) {
    if (!kDebugMode) return;

    debugPrint('');
    debugPrint('╔═══════════════════════════════════════════════════════════');
    debugPrint('║ 🚀 API REQUEST');
    debugPrint('╠═══════════════════════════════════════════════════════════');
    debugPrint('║ Method: $method');
    debugPrint('║ URL: $url');

    if (queryParameters != null && queryParameters.isNotEmpty) {
      debugPrint('║ Query Parameters:');
      queryParameters.forEach((key, value) {
        debugPrint('║   - $key: $value');
      });
    }

    if (data != null && data.isNotEmpty) {
      debugPrint('║ Request Body:');
      try {
        final prettyJson = JsonEncoder.withIndent('  ').convert(data);
        prettyJson.split('\n').forEach((line) {
          debugPrint('║   $line');
        });
      } catch (e) {
        debugPrint('║   $data');
      }
    }

    debugPrint('╚═══════════════════════════════════════════════════════════');
    debugPrint('');
  }

  /// API 응답 로깅 (성공)
  ///
  /// [method]: HTTP 메서드
  /// [url]: API 엔드포인트 URL
  /// [statusCode]: HTTP 상태 코드
  /// [data]: Response Body
  /// [duration]: API 호출 소요 시간 (optional)
  static void logResponse({
    required String method,
    required String url,
    required int statusCode,
    required dynamic data,
    Duration? duration,
  }) {
    if (!kDebugMode) return;

    debugPrint('');
    debugPrint('╔═══════════════════════════════════════════════════════════');
    debugPrint('║ ✅ API RESPONSE SUCCESS');
    debugPrint('╠═══════════════════════════════════════════════════════════');
    debugPrint('║ Method: $method');
    debugPrint('║ URL: $url');
    debugPrint('║ Status: $statusCode');

    if (duration != null) {
      debugPrint('║ Duration: ${duration.inMilliseconds}ms');
    }

    debugPrint('║ Response Data:');
    try {
      final prettyJson = JsonEncoder.withIndent('  ').convert(data);
      prettyJson.split('\n').forEach((line) {
        debugPrint('║   $line');
      });
    } catch (e) {
      debugPrint('║   $data');
    }

    debugPrint('╚═══════════════════════════════════════════════════════════');
    debugPrint('');
  }

  /// API 응답 로깅 (에러)
  ///
  /// [method]: HTTP 메서드
  /// [url]: API 엔드포인트 URL
  /// [error]: DioException 또는 기타 에러
  static void logError({
    required String method,
    required String url,
    required dynamic error,
  }) {
    if (!kDebugMode) return;

    debugPrint('');
    debugPrint('╔═══════════════════════════════════════════════════════════');
    debugPrint('║ ❌ API ERROR');
    debugPrint('╠═══════════════════════════════════════════════════════════');
    debugPrint('║ Method: $method');
    debugPrint('║ URL: $url');

    if (error is DioException) {
      debugPrint('║ Error Type: ${error.type}');
      debugPrint('║ Message: ${error.message ?? "No message"}');

      if (error.response != null) {
        debugPrint('║ Status Code: ${error.response!.statusCode}');
        debugPrint('║ Response Data:');
        try {
          final responseData = error.response!.data;
          if (responseData is Map || responseData is List) {
            final prettyJson =
                JsonEncoder.withIndent('  ').convert(responseData);
            prettyJson.split('\n').forEach((line) {
              debugPrint('║   $line');
            });
          } else {
            debugPrint('║   $responseData');
          }
        } catch (e) {
          debugPrint('║   ${error.response!.data}');
        }

        debugPrint('║ Headers:');
        error.response!.headers.forEach((name, values) {
          debugPrint('║   - $name: ${values.join(", ")}');
        });
      } else {
        debugPrint('║ No Response (Network Error or Timeout)');
      }
    } else {
      debugPrint('║ Error: $error');
    }

    debugPrint('╚═══════════════════════════════════════════════════════════');
    debugPrint('');
  }

  /// 간단한 로그 (디버깅용)
  ///
  /// [tag]: 로그 태그
  /// [message]: 로그 메시지
  static void log(String tag, String message) {
    if (!kDebugMode) return;
    debugPrint('[$tag] $message');
  }
}
