import '../../domain/model/user.dart';
import '../../domain/auth_repository.dart';
import '../dto/login_request.dart';
import '../dto/signup_request.dart';

class AuthMockRepository implements AuthRepository {

  @override
  Future<User> login(LoginRequest request) async {
    return User(
      id: 1,
      nickname: 'MockUser',
      accessToken: 'mock_access_token',
      refreshToken: 'mock_refresh_token',
    );
  }

  @override
  Future<void> signup(SignupRequest request) async {
    // 회원가입 더미 로직
    await Future.delayed(Duration(milliseconds: 500));
  }

  @override
  Future<void> logout(int userId) async {
    await Future.delayed(Duration(milliseconds: 200));
  }

  @override
  Future<User> refreshToken() async {
    return User(
      id: 1,
      nickname: 'MockUser',
      accessToken: 'new_mock_access_token',
      refreshToken: 'new_mock_refresh_token',
    );
  }
}

