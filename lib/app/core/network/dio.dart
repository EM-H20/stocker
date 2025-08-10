// lib/app/core/network/dio.dart

import 'package:dio/dio.dart';
import '../services/dio_interceptor.dart';

final Dio dio = Dio(
  BaseOptions(
    baseUrl: 'https://api.stocker.app',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    contentType: 'application/json',
  ),
);

Future<void> setupDio() async {
  dio.interceptors.clear();
  dio.interceptors.add(AuthInterceptor(dio)); // ✅ storage 제거, 인자 1개만
  // (선택) 로깅
  // dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
}