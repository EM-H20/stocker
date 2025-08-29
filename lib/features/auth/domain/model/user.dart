class User {
  final int id;
  final String email; // 이메일 추가 (로그아웃 시 필요)
  final String nickname;
  final String accessToken;
  final String refreshToken;

  const User({
    required this.id,
    required this.email,
    required this.nickname,
    required this.accessToken,
    required this.refreshToken,
  });

  
}

