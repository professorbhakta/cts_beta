import 'package:cts/theme/cts_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CommonTextFormField extends StatefulWidget {
  const CommonTextFormField(
      {super.key,
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
      this.keyboardType});

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

  @override
  CommonTextFormFieldState createState() => CommonTextFormFieldState();
}

class CommonTextFormFieldState extends State<CommonTextFormField> {
  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;

    return Container(
      padding: widget.padding,
      margin: widget.margin,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7),
          color: Colors.grey.shade50,
          border:
              widget.border ?? Border.all(color: scheme.onSurface, width: 2)),
      child: Padding(
        padding: const EdgeInsets.only(top: 0, right: 10, bottom: 0, left: 10),
        child: TextFormField(
          textInputAction: widget.textInputAction ?? TextInputAction.done,
          keyboardType: widget.keyboardType ?? widget.textInputType,
          cursorColor: Colors.blueAccent,
          controller: widget.controller,
          focusNode: widget.focusNode,
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
                  color: scheme.onSurface),
          decoration: InputDecoration(
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              suffixIcon: widget.suffixIcon,
              hintStyle: widget.hintStyle ??
                  const TextStyle(
                      fontFamily: 'DMSans_Medium',
                      fontSize: 18,
                      letterSpacing: 0.5,
                      color: Colors.grey),
              hintText: '${widget.hintText}'),
        ),
      ),
    );
  }
}
