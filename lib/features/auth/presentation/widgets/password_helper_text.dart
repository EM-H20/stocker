//비밀번호 조건 안내

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PasswordHelperText extends StatelessWidget {
  final bool isValid;

  const PasswordHelperText({
    super.key,  // super.key로 변경
    required this.isValid,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      isValid
          ? '비밀번호가 적합합니다.'
          : '비밀번호는 영문, 숫자, 특수기호 포함 8자 이상이어야 합니다.',
      style: TextStyle(
        fontSize: 12.sp,
        color: isValid ? Colors.green : Colors.red,
      ),
    );
  }
}
