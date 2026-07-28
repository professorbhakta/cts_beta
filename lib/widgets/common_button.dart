import 'package:flutter/material.dart';

class CommonPrimaryButton extends StatelessWidget {
  final String? label;
  final Color? borderColor;
  final String? fontFamily;
  final double? fontSize;
  final VoidCallback? onPressed;
  final double? radius;
  final double? width;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? textColor;
  final Color? backgroundColor;
  final BorderRadiusGeometry? borderRadius;
  final AlignmentGeometry? alignment;
  final bool isLoading;
  final Widget? icon;

  const CommonPrimaryButton({
    super.key,
    this.label,
    this.fontFamily,
    this.borderColor,
    this.fontSize,
    this.onPressed,
    this.radius,
    this.width,
    this.padding,
    this.margin,
    this.borderRadius,
    this.textColor,
    this.backgroundColor,
    this.alignment,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final effectivePadding = padding ??
        const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 16,
        );
    final resolvedRadius = borderRadius ??
        BorderRadius.circular(radius ?? 12);

    final button = FilledButton(
      onPressed: isLoading ? null : onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: backgroundColor ?? scheme.primary,
        foregroundColor: textColor ?? scheme.onPrimary,
        disabledBackgroundColor:
            (backgroundColor ?? scheme.primary).withValues(alpha: 0.6),
        disabledForegroundColor:
            (textColor ?? scheme.onPrimary).withValues(alpha: 0.8),
        padding: effectivePadding,
        minimumSize: Size(width ?? 48, 48),
        alignment: alignment ?? Alignment.center,
        shape: RoundedRectangleBorder(
          borderRadius: resolvedRadius is BorderRadius
              ? resolvedRadius
              : BorderRadius.circular(radius ?? 12),
          side: borderColor != null
              ? BorderSide(color: borderColor!, width: 2)
              : BorderSide.none,
        ),
        textStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: fontSize,
          fontFamily: fontFamily,
        ),
      ),
      child: isLoading
          ? SizedBox(
              height: fontSize ?? 20,
              width: fontSize ?? 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(
                  textColor ?? scheme.onPrimary,
                ),
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  icon!,
                  const SizedBox(width: 8),
                ],
                Text(label ?? ''),
              ],
            ),
    );

    if (margin != null || width != null) {
      return Container(
        margin: margin,
        width: width,
        child: button,
      );
    }
    return button;
  }
}
