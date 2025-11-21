// lib/app/core/network/dio_interceptor.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../services/token_storage.dart';
import '../utils/api_logger.dart';

class AuthInterceptor extends Interceptor {
  final Dio _dio;
  AuthInterceptor(this._dio);

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final accessToken = await TokenStorage.accessToken;
    final refreshToken = await TokenStorage.refreshToken;

    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    // 백엔드 미들웨어가 x-refresh-token 헤더를 확인함
    if (refreshToken != null && refreshToken.isNotEmpty) {
      options.headers['x-refresh-token'] = refreshToken;
    }

    // API 요청 로깅 (Real API 모드에서만)
    ApiLogger.logRequest(
      method: options.method,
      url: '${options.baseUrl}${options.path}',
      data: options.data is Map<String, dynamic> ? options.data : null,
      queryParameters: options.queryParameters,
    );

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // API 응답 로깅 (Real API 모드에서만)
    ApiLogger.logResponse(
      method: response.requestOptions.method,
      url: '${response.requestOptions.baseUrl}${response.requestOptions.path}',
      statusCode: response.statusCode ?? 0,
      data: response.data,
    );

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // API 에러 로깅 (Real API 모드에서만)
    ApiLogger.logError(
      method: err.requestOptions.method,
      url: '${err.requestOptions.baseUrl}${err.requestOptions.path}',
      error: err,
    );

    // 네트워크 문제 및 백엔드 연결 오류 감지 (사용자 친화적 메시지)
    String userFriendlyMessage = '네트워크 오류가 발생했어요';

    if (err.type == DioExceptionType.connectionTimeout) {
      debugPrint('⏰ [AUTH_INTERCEPTOR] 연결 타임아웃 - 서버 응답이 느려요');
      userFriendlyMessage = '서버 연결이 느려요. 잠시 후 다시 시도해주세요.';
    } else if (err.type == DioExceptionType.receiveTimeout) {
      debugPrint('📡 [AUTH_INTERCEPTOR] 응답 타임아웃 - 서버가 바빠요');
      userFriendlyMessage = '서버가 바빠요. 잠시 후 다시 시도해주세요.';
    } else if (err.message != null &&
        err.message!.contains('No host specified')) {
      debugPrint('💥 [AUTH_INTERCEPTOR] URL 설정 문제 감지!');
      userFriendlyMessage = '서버 주소 설정에 문제가 있어요.';
    } else if (err.type == DioExceptionType.connectionError) {
      debugPrint('🚫 [AUTH_INTERCEPTOR] 백엔드 서버 연결 실패 - 네트워크 확인 필요');
      userFriendlyMessage = '인터넷 연결을 확인해주세요.';
    }

    // 에러 객체에 사용자 친화적 메시지 추가
    err.requestOptions.extra['userMessage'] = userFriendlyMessage;

    // access token 만료 (401) 시 처리
    if (err.response?.statusCode == 401) {
      if (kDebugMode) {
        debugPrint(
            '🔄 [AUTH_INTERCEPTOR] Token expired, attempting refresh...');
      }

      // 백엔드 미들웨어가 x-access-token 헤더에 새로운 access token을 넣어줄 수 있음
      final newAccessToken = err.response?.headers['x-access-token']?.first;

      if (newAccessToken != null && newAccessToken.isNotEmpty) {
        if (kDebugMode) {
          debugPrint(
              '✨ [AUTH_INTERCEPTOR] New token received, updating storage...');
        }

        try {
          // 새로운 access token 저장 (사용자 정보 포함)
          final userId = await TokenStorage.userId;
          final refreshToken = await TokenStorage.refreshToken;
          final userEmail = await TokenStorage.userEmail;
          final userNickname = await TokenStorage.userNickname;

          if (userId != null && refreshToken != null && userEmail != null) {
            // 완전한 사용자 세션 정보 저장
            await TokenStorage.saveUserSession(
              accessToken: newAccessToken,
              refreshToken: refreshToken,
              userId: userId,
              email: userEmail,
              nickname: userNickname,
            );

            // 실패했던 요청을 새로운 토큰으로 재시도
            final req = err.requestOptions;
            final newHeaders = Map<String, dynamic>.from(req.headers);
            newHeaders['Authorization'] = 'Bearer $newAccessToken';

            final retryResponse = await _dio.fetch(
              req.copyWith(headers: newHeaders),
            );

            if (kDebugMode) {
              debugPrint(
                  '✅ [AUTH_INTERCEPTOR] Token refreshed and request retried successfully');
            }

            handler.resolve(retryResponse);
            return;
          }
        } catch (retryError) {
          if (kDebugMode) {
            debugPrint(
                '❌ [AUTH_INTERCEPTOR] Failed to retry request: $retryError');
          }
        }
      } else {
        // 백엔드에서 새로운 토큰을 주지 않았다면 refresh token도 만료된 것
        if (kDebugMode) {
          debugPrint(
              '🚪 [AUTH_INTERCEPTOR] Refresh token expired - login required');
        }
        await TokenStorage.clear(); // 만료된 토큰들 모두 정리

        // 사용자 친화적 메시지 설정
        err.requestOptions.extra['userMessage'] = '로그인이 만료되었습니다. 다시 로그인해주세요.';
      }
    }

    handler.next(err);
  }
}
