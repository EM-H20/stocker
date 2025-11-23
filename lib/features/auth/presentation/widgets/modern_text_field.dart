import 'package:flutter/material.dart';

/// 🎨 ModernTextField - 심플한 커스텀 입력 필드
///
/// 특징:
/// - 에러 상태 시각화
/// - 비밀번호 가시성 토글 버튼
class ModernTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final bool isPassword;
  final TextEditingController? controller;
  final String? errorText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  const ModernTextField({
    super.key,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.isPassword = false,
    this.controller,
    this.errorText,
    this.keyboardType,
    this.onChanged,
  });

  @override
  State<ModernTextField> createState() => _ModernTextFieldState();
}

class _ModernTextFieldState extends State<ModernTextField> {
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: widget.controller,
          obscureText: widget.isPassword && _obscureText,
          keyboardType: widget.keyboardType,
          onChanged: widget.onChanged,
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hint,
            prefixIcon: widget.prefixIcon != null
                ? Icon(widget.prefixIcon)
                : null,
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscureText
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: () {
                      setState(() => _obscureText = !_obscureText);
                    },
                  )
                : null,
            border: const OutlineInputBorder(),
          ),
        ),
        if (widget.errorText != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.error_outline,
                size: 16,
                color: Colors.red[700],
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  widget.errorText!,
                  style: TextStyle(
                    color: Colors.red[700],
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
