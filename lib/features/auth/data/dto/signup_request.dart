// features/auth/data/dto/signup_request.dart

/// 회원가입 요청을 위한 DTO (서버 전송용)
class SignupRequest {
  final String email;
  final String password;
  final String nickname;
  final int age; // 추가
  final String occupation; // 추가
  final String provider; // 추가
  final String profileImageUrl; // 추가

  SignupRequest({
    required this.email,
    required this.password,
    required this.nickname,
    required this.age,
    required this.occupation,
    required this.provider,
    required this.profileImageUrl,
  });

  // 서버로 전송할 JSON 형태로 변환
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'nickname': nickname,
      'age': age,
      'occupation': occupation,
      'provider': provider,
      'profile_image_url': profileImageUrl,
    };
  }

  @override
  String toString() {
    return 'SignupRequest(email: $email, nickname: $nickname, age: $age, occupation: $occupation, provider: $provider)';
  }
}
