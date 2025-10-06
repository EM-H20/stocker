import '../data/dto/login_request.dart';
import '../data/dto/signup_request.dart';
import 'model/user.dart';

abstract class AuthRepository {
  Future<User> login(LoginRequest request);
  Future<void> signup(SignupRequest request);
  Future<void> logout(String email);
  Future<void> refreshToken();
  
  /// 🆕 프로필 수정 메서드 추가
  Future<User> updateProfile({
    String? nickname,
    String? profileImageUrl,
    int? age,
    String? occupation,
  });
}