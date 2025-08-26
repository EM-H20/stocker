import 'package:flutter/material.dart';
import 'package:stocker/app/core/services/token_storage.dart';
import '../domain/auth_repository.dart';
import '../domain/model/user.dart';
import '../data/dto/login_request.dart';
import '../data/dto/signup_request.dart';
import 'package:logger/logger.dart';



class AuthProvider with ChangeNotifier {
  final AuthRepository _repository;
  final Logger _logger = Logger();
  AuthProvider(this._repository);

  // --- 상태 변수 ---
  User? _user;
  String? _errorMessage;
  bool _isLoading = false;
  bool _isInitializing = true; // 앱 시작 시 토큰 확인 중인지 여부

  // --- 이벤트 Notifier ---
  // 로그인 성공 이벤트를 외부(HomeShell)에 알리기 위한 장치
  final ValueNotifier<bool> loginSuccessNotifier = ValueNotifier(false);

  // --- Getter ---
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isInitializing => _isInitializing;
  bool get isLoggedIn => _user != null; // 로그인 상태를 쉽게 확인

  // --- 로직 메서드 ---

  /// 앱 시작 시 저장된 토큰을 확인하여 자동 로그인 처리
  Future<void> initialize() async {
    final token = await TokenStorage.accessToken;
    if (token != null) {
      // 실제 앱에서는 이 토큰으로 /api/user/me 같은 API를 호출하여
      // 사용자 정보를 가져와 _user에 할당해야 합니다.
      _user = User(id: 0, nickname: 'Stocker', accessToken: token, refreshToken: '');
    }
    _isInitializing = false;
    notifyListeners();
  }

  /// 로그인
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    try {
      final request = LoginRequest(email: email, password: password);
      _user = await _repository.login(request);
      _errorMessage = null;
      
      // 로그인 성공 상태를 알림
      loginSuccessNotifier.value = true;
      // 잠시 후 다시 false로 초기화하여, 다음 이벤트를 위해 준비
      Future.delayed(const Duration(milliseconds: 100), () {
        loginSuccessNotifier.value = false;
      });

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = '로그인 실패: ${e.toString()}';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 회원가입
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

  /// 로그아웃
  Future<void> logout() async {
    if (_user == null) return;
    try {
      await _repository.logout(_user!.id);
    } catch (e) {
      // 로그아웃 API 실패 시에도 로컬에서는 로그아웃 처리
      _logger.e('Logout API failed: $e');    //print와 같은 역할, _logger는 로그를 남기는 역할을 합니다.
    } finally {
      _user = null;
      await TokenStorage.clear(); // 로컬 토큰 삭제
      notifyListeners();
    }
  }

  /// ✅ [유지] 토큰 갱신 (Dio 인터셉터 등에서 사용)
  Future<void> refreshToken() async {
    try {
      await _repository.refreshToken();
    } catch (_) {
      // 토큰 갱신 실패 시, 로그인 화면으로 보내는 등의 처리가 필요할 수 있음
    }
  }

  /// 로딩 상태 변경 및 UI 업데이트 알림
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}