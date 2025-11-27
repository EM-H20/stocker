import 'package:go_router/go_router.dart';
import '../../../app/config/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../app/core/widgets/custom_snackbar.dart';
import '../presentation/riverpod/auth_notifier.dart';
import 'widgets/modern_text_field.dart';
import 'widgets/gradient_button.dart';

/// 🎨 회원가입 화면 - 2단계 스텝 위저드
///
/// Step 1: 계정 정보 (이메일, 비밀번호, 비밀번호 확인)
/// Step 2: 프로필 정보 (닉네임, 나이, 직업, 약관 동의)
class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  // ✅ State 클래스에서 컨트롤러 관리
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;
  late final TextEditingController _nicknameController;
  late final TextEditingController _ageController;

  // 🎯 스텝 위저드 상태
  int _currentStep = 0; // 0: 계정정보, 1: 프로필정보

  bool _agreedToTerms = false;
  String? _selectedOccupation;

  // 직업 선택 옵션들
  final List<String> _occupationOptions = [
    '학생',
    '직장인',
    '자영업자',
    '투자자',
    '프리랜서',
    '전업주부',
    '기타'
  ];

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _nicknameController = TextEditingController();
    _ageController = TextEditingController();

    // 비밀번호 일치 여부 실시간 체크
    _passwordController.addListener(_onFieldChanged);
    _confirmPasswordController.addListener(_onFieldChanged);
    _emailController.addListener(_onFieldChanged);
    _nicknameController.addListener(_onFieldChanged);
    _ageController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() => setState(() {});

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nicknameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  /// Step 1 유효성 검사: 계정 정보
  bool get _canProceedToStep2 {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    return email.isNotEmpty &&
        email.contains('@') &&
        password.length >= 8 &&
        password == confirmPassword;
  }

  /// Step 2 유효성 검사: 프로필 정보 + 전체
  bool get _canSubmit {
    final nickname = _nicknameController.text.trim();
    final age = int.tryParse(_ageController.text.trim());

    return _canProceedToStep2 &&
        nickname.isNotEmpty &&
        age != null &&
        age >= 1 &&
        age <= 120 &&
        _selectedOccupation != null &&
        _agreedToTerms;
  }

  /// 비밀번호 일치 여부
  bool get _isPasswordMatch {
    return _passwordController.text.isNotEmpty &&
        _passwordController.text == _confirmPasswordController.text;
  }

  /// Step 1 → Step 2 이동
  void _goToStep2() {
    if (_canProceedToStep2) {
      setState(() => _currentStep = 1);
      // 키보드 숨김
      FocusScope.of(context).unfocus();
    }
  }

  /// Step 2 → Step 1 이동 (뒤로가기)
  void _goToStep1() {
    setState(() => _currentStep = 0);
    FocusScope.of(context).unfocus();
  }

  /// 회원가입 처리
  Future<void> _handleSignup() async {
    if (!mounted || !_canSubmit) return;

    final authNotifier = ref.read(authNotifierProvider.notifier);

    final age = int.parse(_ageController.text.trim());

    final success = await authNotifier.signup(
      _emailController.text.trim(),
      _passwordController.text.trim(),
      _nicknameController.text.trim(),
      age: age,
      occupation: _selectedOccupation!,
      provider: 'local',
      profileImageUrl: 'https://example.com/profile.png',
    );

    if (!mounted) return;

    if (success) {
      CustomSnackBar.show(
        context: context,
        type: SnackBarType.success,
        message: '회원가입이 완료되었습니다. 로그인 해주세요.',
      );
      context.go(AppRoutes.login);
    } else {
      final currentState = ref.read(authNotifierProvider).value;
      CustomSnackBar.show(
        context: context,
        type: SnackBarType.error,
        message: currentState?.errorMessage ?? '회원가입에 실패했습니다.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.value?.isLoading ?? false;

    return PopScope(
      // Step 2에서 뒤로가기 → Step 1로
      canPop: _currentStep == 0,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (!didPop && _currentStep == 1) {
          _goToStep1();
        }
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                children: [
                  // 🔝 상단 고정 영역 (로고 + 타이틀 + Step Indicator)
                  _buildHeader(),

                  // 📄 스텝 콘텐츠 (스크롤 없이 화면에 맞춤)
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: Offset(_currentStep == 0 ? -0.1 : 0.1, 0),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: _currentStep == 0
                          ? _buildStep1(isLoading)
                          : _buildStep2(isLoading),
                    ),
                  ),

                  // 🔻 하단 고정 영역 (로그인 링크)
                  _buildFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 🔝 상단 헤더: 로고 + 타이틀 + Step Indicator
  Widget _buildHeader() {
    return Column(
      children: [
        SizedBox(height: 40.h),
        // 로고
        Center(
          child: Image.asset(
            'assets/images/stocker_logo.png',
            width: 100.w,
            height: 100.h,
          ),
        ),
        SizedBox(height: 16.h),
        // 타이틀
        Text(
          '회원가입',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        SizedBox(height: 24.h),
        // Step Indicator
        _buildStepIndicator(),
        SizedBox(height: 24.h),
      ],
    );
  }

  /// 🎯 Step Indicator: ●━━━━━○
  Widget _buildStepIndicator() {
    final primaryColor = Theme.of(context).primaryColor;
    final greyColor = Colors.grey[300]!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Step 1 dot
        _buildStepDot(isActive: true, number: 1),
        // Line
        Container(
          width: 60.w,
          height: 3.h,
          decoration: BoxDecoration(
            color: _currentStep >= 1 ? primaryColor : greyColor,
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
        // Step 2 dot
        _buildStepDot(isActive: _currentStep >= 1, number: 2),
      ],
    );
  }

  Widget _buildStepDot({required bool isActive, required int number}) {
    final primaryColor = Theme.of(context).primaryColor;
    final greyColor = Colors.grey[300]!;

    return Container(
      width: 32.w,
      height: 32.h,
      decoration: BoxDecoration(
        color: isActive ? primaryColor : greyColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '$number',
          style: TextStyle(
            color: isActive ? Colors.white : Colors.grey[600],
            fontWeight: FontWeight.bold,
            fontSize: 14.sp,
          ),
        ),
      ),
    );
  }

  /// 📄 Step 1: 계정 정보
  Widget _buildStep1(bool isLoading) {
    return SingleChildScrollView(
      key: const ValueKey('step1'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 스텝 설명
          Text(
            '계정 정보를 입력해주세요',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),

          // 이메일
          ModernTextField(
            label: '이메일',
            hint: 'example@email.com',
            prefixIcon: Icons.email_outlined,
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
          ),
          SizedBox(height: 16.h),

          // 비밀번호
          ModernTextField(
            label: '비밀번호',
            hint: '8자 이상 입력해주세요',
            prefixIcon: Icons.lock_outline,
            controller: _passwordController,
            isPassword: true,
            errorText: _passwordController.text.isNotEmpty &&
                    _passwordController.text.length < 8
                ? '비밀번호는 8자 이상이어야 합니다'
                : null,
          ),
          SizedBox(height: 16.h),

          // 비밀번호 확인
          ModernTextField(
            label: '비밀번호 확인',
            hint: '비밀번호를 다시 입력해주세요',
            prefixIcon: Icons.lock_outline,
            controller: _confirmPasswordController,
            isPassword: true,
            errorText:
                _confirmPasswordController.text.isNotEmpty && !_isPasswordMatch
                    ? '비밀번호가 일치하지 않습니다'
                    : null,
          ),
          SizedBox(height: 32.h),

          // 다음 버튼
          GradientButton(
            text: '다음',
            icon: Icons.arrow_forward,
            onPressed: _canProceedToStep2 ? _goToStep2 : null,
          ),
        ],
      ),
    );
  }

  /// 📄 Step 2: 프로필 정보
  Widget _buildStep2(bool isLoading) {
    return SingleChildScrollView(
      key: const ValueKey('step2'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 스텝 설명
          Text(
            '프로필 정보를 입력해주세요',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),

          // 닉네임
          ModernTextField(
            label: '닉네임',
            hint: '다른 사용자에게 보여질 이름',
            prefixIcon: Icons.person_outline,
            controller: _nicknameController,
          ),
          SizedBox(height: 16.h),

          // 나이
          ModernTextField(
            label: '나이',
            hint: '예: 25',
            prefixIcon: Icons.cake_outlined,
            controller: _ageController,
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 16.h),

          // 직업 드롭다운
          _buildOccupationDropdown(),
          SizedBox(height: 24.h),

          // 약관 동의
          _buildTermsCheckbox(),
          SizedBox(height: 24.h),

          // 버튼 영역: 이전 + 가입하기
          Row(
            children: [
              // 이전 버튼
              Expanded(
                flex: 1,
                child: OutlinedButton.icon(
                  onPressed: _goToStep1,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('이전'),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              // 가입하기 버튼
              Expanded(
                flex: 2,
                child: GradientButton(
                  text: '가입하기',
                  icon: Icons.person_add,
                  onPressed: _canSubmit && !isLoading ? _handleSignup : null,
                  isLoading: isLoading,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 💼 직업 드롭다운
  Widget _buildOccupationDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedOccupation,
      decoration: InputDecoration(
        labelText: '직업',
        prefixIcon: const Icon(Icons.work_outline),
        border: const OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      ),
      hint: const Text('직업을 선택해주세요'),
      items: _occupationOptions.map((String occupation) {
        return DropdownMenuItem<String>(
          value: occupation,
          child: Text(occupation),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() => _selectedOccupation = newValue);
      },
    );
  }

  /// ✅ 약관 동의 체크박스
  Widget _buildTermsCheckbox() {
    return InkWell(
      onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
        child: Row(
          children: [
            SizedBox(
              width: 24.w,
              height: 24.h,
              child: Checkbox(
                value: _agreedToTerms,
                onChanged: (val) =>
                    setState(() => _agreedToTerms = val ?? false),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.r),
                ),
                // 🎨 다크모드 대응: 테두리 및 체크 색상 명시
                side: BorderSide(
                  color: Theme.of(context).colorScheme.outline,
                  width: 1.5,
                ),
                activeColor: Theme.of(context).primaryColor,
                checkColor: Colors.white,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text.rich(
                TextSpan(
                  text: '이용약관 및 ',
                  // 🎨 다크모드 대응: 테마의 텍스트 색상 사용
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  children: [
                    TextSpan(
                      text: '개인정보처리방침',
                      style: TextStyle(
                        fontSize: 14.sp,
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    TextSpan(
                      text: '에 동의합니다',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔻 하단 푸터: 로그인 링크
  Widget _buildFooter() {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '이미 계정이 있으신가요? ',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          TextButton(
            onPressed: () => context.go(AppRoutes.login),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            ),
            child: Text(
              '로그인',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
