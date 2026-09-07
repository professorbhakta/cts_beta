import 'package:cts/theme/cts_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Visual chrome for [CommonTextFormField].
///
/// [boxed] — legacy grey fill + 2px border (admin CRUD default).
/// [hairline] — cream-friendly bottom rule only (login / new surfaces).
enum CommonTextFormFieldVariant { boxed, hairline }

class CommonTextFormField extends StatefulWidget {
  const CommonTextFormField({
    super.key,
    this.autoFocus,
    this.prefixIcon,
    this.onChange,
    this.controller,
    this.style,
    this.hintText,
    this.textInputType,
    this.textInputAction,
    this.enabled,
    this.hintStyle,
    this.label,
    this.labelStyle,
    this.onFieldSubmitted,
    this.focusNode,
    required this.obscureText,
    this.validator,
    this.autofillHints,
    this.readOnly,
    this.contentPadding,
    this.suffixIcon,
    this.suffixIconTap,
    this.margin,
    this.inputFormatters,
    this.maxLength = 255,
    this.padding,
    this.autofocus,
    this.fillColor,
    this.prefixImage,
    this.border,
    this.textCapitalization = TextCapitalization.none,
    this.keyboardType,
    this.variant = CommonTextFormFieldVariant.boxed,
  });

  final bool? autoFocus;
  final ValueChanged<String>? onChange;
  final Icon? prefixIcon;
  final TextStyle? style;
  final String? hintText;
  final String? label;
  final TextInputType? textInputType;
  final TextInputAction? textInputAction;
  final TextEditingController? controller;
  final TextStyle? hintStyle;
  final TextStyle? labelStyle;
  final bool? enabled;
  final bool obscureText;
  final Widget? suffixIcon;
  final bool? suffixIconTap;
  final bool? readOnly;
  final EdgeInsetsGeometry? contentPadding;
  final FormFieldValidator<String>? validator;
  final Iterable<String>? autofillHints;
  final FocusNode? focusNode;
  final ValueChanged<String>? onFieldSubmitted;
  final EdgeInsetsGeometry? margin;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLength;
  final EdgeInsetsGeometry? padding;
  final bool? autofocus;
  final Color? fillColor;
  final String? prefixImage;
  final TextInputType? keyboardType;
  final BoxBorder? border;
  final TextCapitalization textCapitalization;

  /// Defaults to [CommonTextFormFieldVariant.boxed] so existing forms stay.
  final CommonTextFormFieldVariant variant;

  @override
  CommonTextFormFieldState createState() => CommonTextFormFieldState();
}

class CommonTextFormFieldState extends State<CommonTextFormField> {
  FocusNode? _ownedFocus;
  late FocusNode _focusNode;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _attachFocus(widget.focusNode);
  }

  @override
  void didUpdateWidget(covariant CommonTextFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      _detachFocus();
      _attachFocus(widget.focusNode);
    }
  }

  @override
  void dispose() {
    _detachFocus();
    super.dispose();
  }

  void _attachFocus(FocusNode? external) {
    if (external != null) {
      _focusNode = external;
      _ownedFocus = null;
    } else {
      _ownedFocus = FocusNode();
      _focusNode = _ownedFocus!;
    }
    _focused = _focusNode.hasFocus;
    _focusNode.addListener(_onFocusChange);
  }

  void _detachFocus() {
    _focusNode.removeListener(_onFocusChange);
    _ownedFocus?.dispose();
    _ownedFocus = null;
  }

  void _onFocusChange() {
    if (!mounted) return;
    setState(() => _focused = _focusNode.hasFocus);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.variant == CommonTextFormFieldVariant.hairline) {
      return _buildHairline(context);
    }
    return _buildBoxed(context);
  }

  Widget _buildBoxed(BuildContext context) {
    final scheme = context.scheme;

    return Container(
      padding: widget.padding,
      margin: widget.margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7),
        color: widget.fillColor ?? Colors.grey.shade50,
        border:
            widget.border ?? Border.all(color: scheme.onSurface, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 0, right: 10, bottom: 0, left: 10),
        child: TextFormField(
          textInputAction: widget.textInputAction ?? TextInputAction.done,
          keyboardType: widget.keyboardType ?? widget.textInputType,
          cursorColor: Colors.blueAccent,
          controller: widget.controller,
          focusNode: _focusNode,
          validator: widget.validator,
          textCapitalization: widget.textCapitalization,
          obscureText: widget.obscureText,
          onChanged: widget.onChange,
          onFieldSubmitted: widget.onFieldSubmitted,
          enabled: widget.enabled,
          readOnly: widget.readOnly ?? false,
          autofocus: widget.autofocus ?? widget.autoFocus ?? false,
          inputFormatters: widget.inputFormatters,
          maxLength: widget.maxLength,
          autofillHints: widget.autofillHints,
          style: widget.style ??
              TextStyle(
                fontFamily: 'DMSans_Medium',
                fontSize: 14,
                letterSpacing: 0.5,
                color: scheme.onSurface,
              ),
          decoration: InputDecoration(
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            counterText: '',
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.suffixIcon,
            hintStyle: widget.hintStyle ??
                const TextStyle(
                  fontFamily: 'DMSans_Medium',
                  fontSize: 18,
                  letterSpacing: 0.5,
                  color: Colors.grey,
                ),
            hintText: widget.hintText,
          ),
        ),
      ),
    );
  }

  Widget _buildHairline(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final idleLine = scheme.onSurface.withValues(alpha: 0.2);
    // Focus: theme primary (yellow); idle hairline navy/onSurface.
    final activeLine = scheme.primary;
    final lineColor = _focused ? activeLine : idleLine;

    final field = TextFormField(
      textInputAction: widget.textInputAction ?? TextInputAction.done,
      keyboardType: widget.keyboardType ?? widget.textInputType,
      cursorColor: scheme.primary,
      controller: widget.controller,
      focusNode: _focusNode,
      validator: widget.validator,
      textCapitalization: widget.textCapitalization,
      obscureText: widget.obscureText,
      onChanged: widget.onChange,
      onFieldSubmitted: widget.onFieldSubmitted,
      enabled: widget.enabled,
      readOnly: widget.readOnly ?? false,
      autofocus: widget.autofocus ?? widget.autoFocus ?? false,
      inputFormatters: widget.inputFormatters,
      maxLength: widget.maxLength,
      autofillHints: widget.autofillHints,
      style: widget.style ??
          theme.textTheme.bodyLarge?.copyWith(
            color: scheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
      decoration: InputDecoration(
        isDense: true,
        filled: false,
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
        counterText: '',
        contentPadding: widget.contentPadding ??
            const EdgeInsets.symmetric(vertical: 12),
        prefixIcon: widget.prefixIcon,
        prefixIconConstraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        suffixIcon: widget.suffixIcon,
        suffixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        hintStyle: widget.hintStyle ??
            theme.textTheme.bodyLarge?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.35),
              fontWeight: FontWeight.w400,
            ),
        hintText: widget.hintText,
        errorStyle: theme.textTheme.bodySmall?.copyWith(
          color: scheme.error,
        ),
      ),
    );

    return Padding(
      padding: widget.padding ?? EdgeInsets.zero,
      child: Container(
        margin: widget.margin,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.label != null && widget.label!.isNotEmpty) ...[
              Text(
                widget.label!.toUpperCase(),
                style: widget.labelStyle ??
                    theme.textTheme.labelSmall?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.65),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
              ),
              const SizedBox(height: 4),
            ],
            DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border(
                  bottom: BorderSide(color: lineColor, width: 1),
                ),
              ),
              child: field,
            ),
          ],
        ),
      ),
    );
  }
}
