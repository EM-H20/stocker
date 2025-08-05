import 'package:flutter/material.dart';


class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  String _errorMessage = '';
  String? _user;

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String? get user => _user;

  // 더미 데이터 (로그인/회원가입에 사용될 값)
  final String dummyEmail = "test@example.com";
  final String dummyPassword = "Password123!";
  final String dummyNickname = "dummyUser";

  // 로그인 처리 (더미 데이터 사용)
  Future<void> login(String email, String password) async {
    _setLoading(true);
    try {
      // 더미 데이터로 로그인 처리
      if (email == dummyEmail && password == dummyPassword) {
        // 로그인 성공
        _user = email;
        _errorMessage = '';
      } else {
        // 로그인 실패
        _errorMessage = '아이디 또는 비밀번호가 틀렸습니다.';
      }
      _setLoading(false);
    } catch (e) {
      _errorMessage = "로그인 실패: $e";
      _setLoading(false);
    }
    notifyListeners();  // UI에 알림
  }

  // 회원가입 처리 (더미 데이터 사용)
  Future<void> signup(String email, String password, String nickname) async {
    _setLoading(true);
    try {
      // 더미 데이터로 회원가입 처리
      if (email == dummyEmail && password == dummyPassword && nickname == dummyNickname) {
        // 회원가입 성공
        _user = email;
        _errorMessage = '';
      } else {
        // 회원가입 실패
        _errorMessage = '입력한 정보가 잘못되었습니다.';
      }
      _setLoading(false);
    } catch (e) {
      _errorMessage = "회원가입 실패: $e";
      _setLoading(false);
    }
    notifyListeners();  // UI에 알림
  }

  // 로딩 상태 설정
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();  // UI에 알림
  }

  // 로그아웃 처리
  void logout() {
    _user = null;
    _errorMessage = '';
    notifyListeners();  // UI에 알림
  }

  // setUser 메서드 추가
  void setUser(String email) {
    _user = email;
    _errorMessage = '';
    notifyListeners();  // UI에 알림
  }

  // setErrorMessage 메서드 추가
  void setErrorMessage(String message) {
    _errorMessage = message;
    notifyListeners();  // UI에 알림
  }
}
