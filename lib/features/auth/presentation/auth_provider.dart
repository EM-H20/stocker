// //C:\Users\TOP\Desktop\seeds\stocker\lib\features\auth\presentation\auth_provider.dart

import 'package:flutter/material.dart';
import '../domain/auth_repository.dart';
import '../domain/model/user.dart';
import '../data/dto/login_request.dart';
import '../data/dto/signup_request.dart';

class AuthProvider with ChangeNotifier {
  final AuthRepository _repository;
  AuthProvider(this._repository);

  User? _user;
  String? _errorMessage;
  bool _isLoading = false;

  User? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    try {
      final request = LoginRequest(email: email, password: password);
      _user = await _repository.login(request);
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = '로그인 실패: ${e.toString()}';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signup(String email, String password, String nickname) async {
    _setLoading(true);
    try {
      final request = SignupRequest(email: email, password: password, nickname: nickname);
      await _repository.signup(request);
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = '회원가입 실패: ${e.toString()}';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    if (_user == null) return;
    await _repository.logout(_user!.id);
    _user = null;
    notifyListeners();
  }

  Future<void> refreshToken() async {
    try {
      await _repository.refreshToken();
    } catch (_) {
      // 실패해도 앱에서 따로 처리 가능
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
