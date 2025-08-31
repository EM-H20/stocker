/// 프로필 수정 요청 모델
/// API.md 명세: POST /api/user/profile
class ProfileUpdateRequest {
  final String? nickname;
  final String? profileImageUrl;
  final int? age;
  final String? occupation;

  ProfileUpdateRequest({
    this.nickname,
    this.profileImageUrl,
    this.age,
    this.occupation,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    
    if (nickname != null) data['nickname'] = nickname;
    if (profileImageUrl != null) data['profile_image_url'] = profileImageUrl;
    if (age != null) data['age'] = age;
    if (occupation != null) data['occupation'] = occupation;
    
    return data;
  }

  /// 수정할 항목이 있는지 확인
  bool get hasUpdates => 
      nickname != null || profileImageUrl != null || age != null || occupation != null;
}