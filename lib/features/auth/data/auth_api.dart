// features/auth/data/auth_api.dart
import 'package:dio/dio.dart';
import '../data/dto/auth_response.dart';
import '../data/dto/login_request.dart';
import '../data/dto/signup_request.dart';

class AuthApi {
  final Dio _dio;

  // Dio 객체를 주입 받아 API 호출
  AuthApi(this._dio);

  // 로그인 API 호출
  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await _dio.post(
        'https://api.stocker.app/api/auth/login',  // 로그인 API URL
        data: request.toJson(),  // 로그인 데이터 전송
      );

      // 서버 응답을 AuthResponse 객체로 변환하여 반환
      return AuthResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('로그인 실패: $e');  // 오류 발생 시 예외 처리
    }
  }

  // 회원가입 API 호출
  Future<void> signup(SignupRequest request) async {
    try {
      await _dio.post(
        'https://api.stocker.app/api/auth/register',  // 회원가입 API URL
        data: request.toJson(),  // 회원가입 데이터 전송
      );
    } catch (e) {
      throw Exception('회원가입 실패: $e');  // 오류 발생 시 예외 처리
    }
  }
}
