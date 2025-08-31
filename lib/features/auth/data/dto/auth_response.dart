
// data/dto/auth_response.dart


import '../../domain/model/user.dart';

class AuthResponse {
  final int userId;
  final String email;
  final String nickname;
  final String accessToken;
  final String refreshToken;

  AuthResponse({
    required this.userId,
    required this.email,
    required this.nickname,
    required this.accessToken,
    required this.refreshToken,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    // 백엔드 응답 구조: { message, user: { id, email, nickname, access_token, refresh_token } }
    final user = json['user'] as Map<String, dynamic>? ?? {};
    
    return AuthResponse(
      userId: user['id'] ?? 0,
      email: user['email'] ?? '',
      nickname: user['nickname'] ?? '',
      accessToken: user['access_token'] ?? '', // API.md 명세: 'access_token' 사용
      refreshToken: user['refresh_token'] ?? '', // API.md 명세: 'refresh_token' 사용
    );
  }

  /// ✅ 도메인 User 객체로 변환
  User toUser() {
    return User(
      id: userId,
      email: email,
      nickname: nickname,
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }
}
