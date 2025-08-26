
// data/dto/auth_response.dart


import '../../domain/model/user.dart';

class AuthResponse {
  final int userId;
  final String nickname;
  final String accessToken;
  final String refreshToken;

  AuthResponse({
    required this.userId,
    required this.nickname,
    required this.accessToken,
    required this.refreshToken,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      userId: json['user_id'],
      nickname: json['nickname'],
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
    );
  }

  /// ✅ 도메인 User 객체로 변환
  User toUser() {
    return User(
      id: userId,
      nickname: nickname,
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }
}
