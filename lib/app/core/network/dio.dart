// lib/app/core/network/dio.dart

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../services/dio_interceptor.dart';

final Dio dio = Dio();

Future<void> setupDio() async {
  // 환경 변수에서 API URL 가져오기 (백엔드 8080 포트 기본값)
  final baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://168.107.22.83:8080';
  final connectTimeout =
      (int.tryParse(dotenv.env['CONNECT_TIMEOUT'] ?? '15') ?? 15)*1000;
  final receiveTimeout =
      (int.tryParse(dotenv.env['RECEIVE_TIMEOUT'] ?? '30') ?? 30)*1000;

  // URL 검증
  if (!_isValidUrl(baseUrl)) {
    debugPrint('🚨 [DIO] 잘못된 BASE_URL 감지: $baseUrl');
    throw ArgumentError(
        'Invalid BASE_URL: $baseUrl. URL must start with http:// or https://');
  }

  debugPrint('🌐 [DIO] Setting up Dio with baseUrl: $baseUrl');
  debugPrint(
      '⏰ [DIO] Timeouts - Connect: ${connectTimeout}s, Receive: ${receiveTimeout}s');

  dio.options = BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: Duration(seconds: connectTimeout),
    receiveTimeout: Duration(seconds: receiveTimeout),
    contentType: 'application/json',
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      // MySQL/JWT 백엔드와의 호환성을 위한 추가 헤더
      'Cache-Control': 'no-cache',
      'X-Requested-With': 'XMLHttpRequest',
    },
    // 리다이렉트 자동 처리 (로그인 플로우 등에서 유용)
    followRedirects: true,
    maxRedirects: 5,
  );

  // 인터셉터 설정
  dio.interceptors.clear();
  dio.interceptors.add(AuthInterceptor(dio));

  // // 개발 환경에서만 로깅 활성화
  // if (dotenv.env['DEBUG_MODE'] == 'true' && kDebugMode) {
  //   debugPrint('📊 [DIO] Enabling request/response logging in debug mode');
  //   dio.interceptors.add(
  //     LogInterceptor(
  //       requestBody: true,
  //       responseBody: true,
  //       requestHeader: true,
  //       responseHeader: false,
  //       error: true,
  //       logPrint: (obj) => debugPrint('🌐 [DIO_LOG] $obj'),
  //     ),
  //   );
  // }

  // debugPrint('✅ [DIO] Setup completed successfully');
}

/// URL 유효성 검증 헬퍼 함수
bool _isValidUrl(String url) {
  if (url.isEmpty) return false;

  try {
    final uri = Uri.parse(url);
    return uri.hasScheme &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.hasAuthority;
  } catch (e) {
    debugPrint('🚨 [DIO] URL 파싱 실패: $e');
    return false;
  }
}
