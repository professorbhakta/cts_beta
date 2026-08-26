import 'package:cts/theme/cts_colors.dart';
import 'package:flutter/material.dart';

class Headline extends StatelessWidget {
  const Headline({super.key, this.headline, this.fontSize, this.textColor});

  final String? headline;
  final double? fontSize;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final w = MediaQuery.of(context).size.width;
    return Container(
      height: 46,
      width: w,
      margin: const EdgeInsets.only(top: 0, bottom: 05),
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border.all(color: scheme.primary),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Center(
        child: Text(
          headline ?? "",
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: fontSize,
              color: textColor,
              decoration: TextDecoration.underline,
              fontFamily: 'Noto Serif Nyiakeng Puachue Hmong'),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
