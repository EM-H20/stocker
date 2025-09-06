/// 프로필 수정 응답 모델
/// API.md 명세: POST /api/user/profile 응답
class ProfileUpdateResponse {
  final String message;
  final UserProfile user;

  ProfileUpdateResponse({
    required this.message,
    required this.user,
  });

  factory ProfileUpdateResponse.fromJson(Map<String, dynamic> json) {
    return ProfileUpdateResponse(
      message: json['message'] ?? '',
      user: UserProfile.fromJson(json['user'] as Map<String, dynamic>? ?? {}),
    );
  }
}

/// 사용자 프로필 정보
class UserProfile {
  final int id;
  final String email;
  final String nickname;
  final String? profileImageUrl;
  final String provider;
  final int? age;
  final String? occupation;
  final String createdDate;

  UserProfile({
    required this.id,
    required this.email,
    required this.nickname,
    this.profileImageUrl,
    required this.provider,
    this.age,
    this.occupation,
    required this.createdDate,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      nickname: json['nickname'] ?? '',
      profileImageUrl: json['profile_image_url'],
      provider: json['provider'] ?? 'local',
      age: json['age'],
      occupation: json['occupation'],
      createdDate: json['created_date'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nickname': nickname,
      if (profileImageUrl != null) 'profile_image_url': profileImageUrl,
      'provider': provider,
      if (age != null) 'age': age,
      if (occupation != null) 'occupation': occupation,
      'created_date': createdDate,
    };
  }
}
