// API 요청 관리 - 이미 설정된 Dio 인스턴스를 사용
// 주의: JWT 토큰 처리는 dio_interceptor.dart의 AuthInterceptor에서 처리됩니다.

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../network/dio.dart'; // 이미 설정된 Dio 인스턴스 사용
import 'token_storage.dart';

class ApiClient {
  // 싱글톤 패턴으로 전역에서 하나의 Dio 인스턴스만 사용
  static Dio get _dio => dio;

  /// ✅ GET 요청 헬퍼 메서드
  static Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    debugPrint('📡 [API_CLIENT] GET 요청: $path');
    return await _dio.get(path, queryParameters: queryParameters);
  }

  /// ✅ POST 요청 헬퍼 메서드
  static Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    debugPrint('📤 [API_CLIENT] POST 요청: $path');
    return await _dio.post(path, data: data, queryParameters: queryParameters);
  }

  /// ✅ PUT 요청 헬퍼 메서드  
  static Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    debugPrint('🔄 [API_CLIENT] PUT 요청: $path');
    return await _dio.put(path, data: data, queryParameters: queryParameters);
  }

  /// ✅ DELETE 요청 헬퍼 메서드
  static Future<Response> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    debugPrint('🗑️ [API_CLIENT] DELETE 요청: $path');
    return await _dio.delete(path, queryParameters: queryParameters);
  }

  /// ✅ 토큰 상태 확인 (디버깅용)
  static Future<bool> hasValidToken() async {
    final accessToken = await TokenStorage.accessToken;
    final refreshToken = await TokenStorage.refreshToken;
    final userId = await TokenStorage.userId;
    
    final isValid = accessToken != null && 
                   accessToken.isNotEmpty &&
                   refreshToken != null && 
                   refreshToken.isNotEmpty &&
                   userId != null;
                   
    debugPrint('🔐 [API_CLIENT] 토큰 상태: ${isValid ? "유효" : "무효"}');
    return isValid;
  }

  /// ✅ 로그아웃 처리 (토큰 정리)
  static Future<void> logout() async {
    debugPrint('🚪 [API_CLIENT] 로그아웃 - 토큰 정리 중...');
    await TokenStorage.clear();
    debugPrint('✅ [API_CLIENT] 로그아웃 완료');
  }
}
