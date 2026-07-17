import 'package:cts/appManager/colors.dart';
import 'package:flutter/material.dart';

class TextFieldWidget extends StatefulWidget {
  const TextFieldWidget(
      {super.key,
      this.hintText,
      this.labelText,
      this.errorText,
      this.onChange,
      this.controller,
      this.obscureText,
      this.keyboardType,
      this.textInputAction,
      this.focusNode,
      this.prefixIcon,
      this.readOnly,
      this.validator});

  final String? hintText;
  final String? labelText;
  final String? errorText;
  final ValueChanged<String>? onChange;
  final TextEditingController? controller;
  final bool? obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final Icon? prefixIcon;
  final bool? readOnly;
  final FormFieldValidator<String>? validator;

  @override
  State<TextFieldWidget> createState() => _TextFieldWidgetState();
}

class _TextFieldWidgetState extends State<TextFieldWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        decoration: InputDecoration(
          hintText: widget.hintText,
          labelText: widget.labelText,
          errorText: widget.errorText,
          hintStyle: const TextStyle(
            fontFamily: "Noto Serif Nyiakeng Puachue Hmong",
          ),
          filled: true,
          fillColor: Colors.grey[200],
          labelStyle: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.acShadowColor,
              fontSize: 13),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: AppColors.acYellowWarm),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: Colors.grey[400]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: AppColors.acBlack),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 14.0,
          ),
          prefixIcon: widget.prefixIcon,
        ),
        readOnly: widget.readOnly ?? false,
        validator: widget.validator,
        controller: widget.controller,
        obscureText: widget.obscureText ?? false,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        onChanged: widget.onChange,
        style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.acBlack,
            fontSize: 13,
            fontFamily: "Noto Serif Nyiakeng Puachue Hmong"),
      ),
    );
  }
}

