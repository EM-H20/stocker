// lib/app/core/network/dio_interceptor.dart
import 'package:dio/dio.dart';
import '../services/token_storage.dart';

class AuthInterceptor extends Interceptor {
  final Dio _dio;
  AuthInterceptor(this._dio);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final accessToken = await TokenStorage.accessToken; // static getter
    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // access token 만료 (401) 시 처리
    if (err.response?.statusCode == 401) {
      try {
        final refreshToken = await TokenStorage.refreshToken;
        final userId = await TokenStorage.userId;

        if (refreshToken == null || userId == null) {
          handler.next(err);
          return;
        }

        // 1) refresh 호출
        final refreshRes = await _dio.post(
          '/api/auth/refresh',
          data: {
            'user_id': int.tryParse(userId) ?? userId, // 백엔드 명세에 맞게 숫자/문자 처리
            'refresh_token': refreshToken,
          },
        );

        // 2) 새 토큰 저장
        final newAccess = refreshRes.data['access_token'] as String?;
        final newRefresh = refreshRes.data['refresh_token'] as String?; // 내려주면 갱신, 아니면 무시
        if (newAccess == null || newAccess.isEmpty) {
          handler.next(err);
          return;
        }
        await TokenStorage.saveTokens(
          newAccess,
          newRefresh ?? refreshToken, // 새 refresh 없으면 기존 유지
          int.tryParse(userId) ?? userId,
        );

        // 3) 실패했던 요청 재시도
        final req = err.requestOptions;
        final newHeaders = Map<String, dynamic>.from(req.headers);
        newHeaders['Authorization'] = 'Bearer $newAccess';

        final retryResponse = await _dio.fetch(
          req.copyWith(headers: newHeaders),
        );
        handler.resolve(retryResponse);
        return;
      } catch (_) {
        // refresh 실패 => 토큰 제거(선택)
        // await TokenStorage.clear();
        handler.next(err);
        return;
      }
    }

    handler.next(err);
  }
}
