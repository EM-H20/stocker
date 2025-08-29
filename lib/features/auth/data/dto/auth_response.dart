
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
    // 백엔드 응답 구조: { token, refreshToken, user: { id, email, nickname } }
    final user = json['user'] as Map<String, dynamic>? ?? {};
    
    return AuthResponse(
      userId: user['id'] ?? 0,
      email: user['email'] ?? '',
      nickname: user['nickname'] ?? '',
      accessToken: json['token'] ?? '', // 백엔드는 'token' 필드 사용
      refreshToken: json['refreshToken'] ?? '', // 백엔드는 'refreshToken' 필드 사용
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
