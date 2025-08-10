// api 요청 관리, dio 를 설정하여 api와의 통신을 담당함

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../app/core/services/token_storage_service.dart';

class ApiClient {
  final Dio dio;

  ApiClient(this.dio) {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // access token 주입
        final token = await TokenStorageService().getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (e, handler) async {
        if (e.response?.statusCode == 401) {
          // access token 만료 시 refresh 시도
          final refreshToken = await TokenStorageService().getRefreshToken();

          try {
            final refreshResponse = await dio.post('/auth/refresh',
              data: {'refreshToken': refreshToken},
            );

            final newAccessToken = refreshResponse.data['accessToken'];
            final newRefreshToken = refreshResponse.data['refreshToken'];

            await TokenStorageService().saveTokens(newAccessToken, newRefreshToken);

            // 실패했던 요청에 토큰 다시 주입해서 재시도
            final options = e.requestOptions;
            options.headers['Authorization'] = 'Bearer $newAccessToken';

            final response = await dio.fetch(options);
            return handler.resolve(response);
          } catch (e) {
            // refresh 실패 시 로그아웃
            await TokenStorageService().deleteTokens();
            return handler.reject(e as DioException);
          }
        }

        return handler.next(e);
      },
    ));
  }
}
