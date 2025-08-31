//ok
// signup_request.dart
class SignupRequest {
  final String email;
  final String password;
  final String nickname;
  final int? age;
  final String? occupation;
  final String? provider;
  final String? profileImageUrl;

  SignupRequest({
    required this.email,
    required this.password,
    required this.nickname,
    this.age,
    this.occupation,
    this.provider = 'local',
    this.profileImageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'nickname': nickname,
      if (age != null) 'age': age,
      if (occupation != null) 'occupation': occupation,
      'provider': provider ?? 'local',
      if (profileImageUrl != null) 'profile_image_url': profileImageUrl,
    };
  }
}
