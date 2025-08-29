import '../data/dto/login_request.dart';
import '../data/dto/signup_request.dart';
import 'model/user.dart';

abstract class AuthRepository {
  Future<User> login(LoginRequest request);
  Future<void> signup(SignupRequest request);
  Future<void> logout(String email); // userId 대신 email 사용
  Future<void> refreshToken();
}
