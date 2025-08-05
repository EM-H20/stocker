
// login_request.dart
class LoginRequest {
  final String email;
  final String password;

  LoginRequest({
    required this.email,
    required this.password,
  });

  // toJson 메서드 추가
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

