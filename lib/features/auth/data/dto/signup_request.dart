//ok
// signup_request.dart
class SignupRequest {
  final String email;
  final String password;
  final String nickname;

  SignupRequest({
    required this.email,
    required this.password,
    required this.nickname,
  });

  // toJson 메서드 추가
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'nickname': nickname,
    };
  }
}
