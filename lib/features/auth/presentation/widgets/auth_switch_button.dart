//로그인/회원가입 전환 버튼

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AuthSwitchButton extends StatelessWidget {
  final String buttonText;
  final VoidCallback onPressed;

  const AuthSwitchButton({
    super.key, // super.key로 변경
    required this.buttonText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        buttonText,
        style: TextStyle(
          fontSize: 14.sp,
          color: Colors.blue,
        ),
      ),
    );
  }
}
