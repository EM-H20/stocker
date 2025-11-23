import 'package:flutter/material.dart';

/// 🎨 GradientButton - 모던한 그라데이션 버튼
///
/// 특징:
/// - Linear Gradient 배경
/// - 로딩 시 스피너 표시
/// - Disabled 상태 시각화
/// - Press 효과 애니메이션 (scale)
/// - 부드러운 그림자 효과
class GradientButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final List<Color>? gradientColors;
  final IconData? icon;
  final double height;
  final double borderRadius;

  const GradientButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.gradientColors,
    this.icon,
    this.height = 48,
    this.borderRadius = 12,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    // 기본 그라데이션 색상 (Primary Color 기반)
    final colors = widget.gradientColors ??
        [
          primaryColor,
          Color.lerp(primaryColor, Colors.black, 0.2)!,
        ];

    final isEnabled = widget.onPressed != null && !widget.isLoading;

    return GestureDetector(
      onTapDown: isEnabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: isEnabled
          ? (_) {
              setState(() => _isPressed = false);
              widget.onPressed!();
            }
          : null,
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          height: widget.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isEnabled
                  ? colors
                  : [Colors.grey[400]!, Colors.grey[400]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: isEnabled
                ? [
                    BoxShadow(
                      color: colors[0].withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isEnabled ? widget.onPressed : null,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              child: Center(
                child: widget.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.icon != null) ...[
                            Icon(
                              widget.icon,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            widget.text,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
