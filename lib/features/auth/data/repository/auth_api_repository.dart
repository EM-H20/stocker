// lib/features/auth/data/repository/auth_api_repository.dart
import '../../../auth/data/dto/login_request.dart';
import '../../../auth/data/dto/signup_request.dart';
import '../../data/dto/auth_response.dart';
import '../../domain/model/user.dart';
import '../../domain/auth_repository.dart';
import '../source/auth_api.dart';

class AuthApiRepository implements AuthRepository {
  final AuthApi _api;
  AuthApiRepository(this._api);

  @override
  Future<User> login(LoginRequest request) async {
    final AuthResponse res = await _api.login(request);
    // 응답 DTO -> 도메인 모델 변환
    return res.toUser(); // toUser()는 (id, nickname, accessToken?, refreshToken?) 중 네가 정의한대로
  }

  @override
  Future<void> signup(SignupRequest request) {
    return _api.signup(request);
  }

  @override
  Future<void> logout(int userId){
    return _api.logout(userId);
  }

  @override
  Future<void> refreshToken() {
    return _api.refreshToken().then((_) => null);
  }
}
 