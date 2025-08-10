import '../data/dto/login_request.dart';
import '../data/dto/signup_request.dart';
import 'model/user.dart';

abstract class AuthRepository {
  Future<User> login(LoginRequest request);
  Future<void> signup(SignupRequest request);
  Future<void> logout(int userId);
  Future<void> refreshToken();
}
