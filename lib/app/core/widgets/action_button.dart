import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Theory/Quiz 등의 액션 버튼 위젯
///
/// 재사용 가능한 버튼 컴포넌트로, 아이콘과 텍스트를 포함하며
/// 색상과 동작을 커스터마이징할 수 있습니다.
class ActionButton extends StatelessWidget {
  const ActionButton({
    super.key,
    required this.text,
    required this.icon,
    required this.color,
    required this.onPressed,
    this.width,
    this.height,
  });

  final String text;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16.sp),
      label: Text(
        text,
        style: theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        minimumSize: Size(width ?? 80.w, height ?? 36.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      ),
    );
  }
}
