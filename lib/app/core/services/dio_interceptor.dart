// lib/app/core/network/dio_interceptor.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../services/token_storage.dart';

class AuthInterceptor extends Interceptor {
  final Dio _dio;
  AuthInterceptor(this._dio);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final accessToken = await TokenStorage.accessToken;
    final refreshToken = await TokenStorage.refreshToken;
    
    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    
    // 백엔드 미들웨어가 x-refresh-token 헤더를 확인함
    if (refreshToken != null && refreshToken.isNotEmpty) {
      options.headers['x-refresh-token'] = refreshToken;
    }
    
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // 에러 상세 로깅
    debugPrint('🚨 [AUTH_INTERCEPTOR] HTTP 에러 발생');
    debugPrint('🚨 [AUTH_INTERCEPTOR] Error Type: ${err.type}');
    debugPrint('🚨 [AUTH_INTERCEPTOR] Message: ${err.message}');
    debugPrint('🚨 [AUTH_INTERCEPTOR] Request URL: ${err.requestOptions.uri}');
    
    if (err.response != null) {
      debugPrint('🚨 [AUTH_INTERCEPTOR] Response Status: ${err.response!.statusCode}');
      debugPrint('🚨 [AUTH_INTERCEPTOR] Response Data: ${err.response!.data}');
    }

    // 네트워크 문제 및 백엔드 연결 오류 감지 (사용자 친화적 메시지)
    String userFriendlyMessage = '네트워크 오류가 발생했어요';
    
    if (err.type == DioExceptionType.connectionTimeout) {
      debugPrint('⏰ [AUTH_INTERCEPTOR] 연결 타임아웃 - 서버 응답이 느려요');
      userFriendlyMessage = '서버 연결이 느려요. 잠시 후 다시 시도해주세요.';
    } else if (err.type == DioExceptionType.receiveTimeout) {
      debugPrint('📡 [AUTH_INTERCEPTOR] 응답 타임아웃 - 서버가 바빠요');
      userFriendlyMessage = '서버가 바빠요. 잠시 후 다시 시도해주세요.';
    } else if (err.message != null && err.message!.contains('No host specified')) {
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
      debugPrint('🔑 [AUTH_INTERCEPTOR] 401 Unauthorized - 백엔드 미들웨어가 토큰을 자동 갱신해줌');
      
      // 백엔드 미들웨어가 x-access-token 헤더에 새로운 access token을 넣어줄 수 있음
      final newAccessToken = err.response?.headers['x-access-token']?.first;
      
      if (newAccessToken != null && newAccessToken.isNotEmpty) {
        debugPrint('✨ [AUTH_INTERCEPTOR] 백엔드에서 새로운 access token 받음');
        
        // 새로운 access token 저장
        final userId = await TokenStorage.userId;
        final refreshToken = await TokenStorage.refreshToken;
        
        if (userId != null && refreshToken != null) {
          await TokenStorage.saveTokens(newAccessToken, refreshToken, userId);
          
          // 실패했던 요청을 새로운 토큰으로 재시도
          final req = err.requestOptions;
          final newHeaders = Map<String, dynamic>.from(req.headers);
          newHeaders['Authorization'] = 'Bearer $newAccessToken';
          
          final retryResponse = await _dio.fetch(
            req.copyWith(headers: newHeaders),
          );
          handler.resolve(retryResponse);
          debugPrint('✅ [AUTH_INTERCEPTOR] 토큰 갱신 및 재요청 성공!');
          return;
        }
      } else {
        // 백엔드에서 새로운 토큰을 주지 않았다면 refresh token도 만료된 것
        debugPrint('🚪 [AUTH_INTERCEPTOR] Refresh 토큰도 만료됨 - 재로그인 필요');
        await TokenStorage.clear(); // 만료된 토큰들 모두 정리
      }
    }

    handler.next(err);
  }
}
