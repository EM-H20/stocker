
// data/dto/auth_response.dart


class AuthResponse {
  final String token;
  final String userId;
  final String nickname;

  AuthResponse({
    required this.token,
    required this.userId,
    required this.nickname,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'],
      userId: json['user_id'],
      nickname: json['nickname'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'user_id': userId,
      'nickname': nickname,
    };
  }
}
