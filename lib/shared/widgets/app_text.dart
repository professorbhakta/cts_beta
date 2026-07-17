import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';


class AppText extends StatelessWidget {
  const AppText(
      this.text, {
        super.key,
        this.color,
        this.fontSize,
        this.fontWeight,
        this.textAlign,
        this.maxLines = 1, // Default to 1 line for truncation safety
        this.overflow = TextOverflow.ellipsis,
        this.characterLimit,
        this.restrictScaling = false, // To ignore system font size changes
        this.minFontSize = 10.0, // Used by AutoSizeText
        this.maxFontSize = 30.0, // Used by AutoSizeText
      });

  final String text;
  final Color? color;
  final double? fontSize;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  final int? characterLimit;
  final bool restrictScaling;
  final double minFontSize;
  final double maxFontSize;

  // --- Helper Method 1: Character Limiting ---
  String _getProcessedText() {
    String processedText = text;

    // Limits the text to the specified number of characters.
    if (characterLimit != null && text.length > characterLimit!) {
      processedText = text.substring(0, characterLimit!);
    }
    return processedText;
  }

  // --- Helper Method 2: Text Scaling Restriction (Requires Context) ---
  // THIS IS THE CORRECTED METHOD SIGNATURE
  Widget _wrapWithScaleRestriction(BuildContext context, Widget child) {
    if (restrictScaling) {
      // Use MediaQuery to force the text scale factor to no scaling (1.0).
      // This is crucial for UI elements that must not change size due to
      // user accessibility settings (e.g., small navigation items).
      return MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
        child: child,
      );
    }
    return child;
  }

  @override
  Widget build(BuildContext context) {
    // 1. Process the text (apply character limit)
    final displayedText = _getProcessedText();

    // Determine the style based on theme and overrides
    final textTheme = Theme.of(context).textTheme;
    TextStyle baseStyle = textTheme.bodyMedium ?? const TextStyle();

    final finalFontSize = fontSize ?? baseStyle.fontSize;

    final finalStyle = baseStyle.copyWith(
      color: color,
      fontSize: finalFontSize,
      fontWeight: fontWeight,
    );

    // 2. Use AutoSizeText for responsiveness (shrink/fit)
    final autoSizeTextWidget = AutoSizeText(
      displayedText,
      style: finalStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      minFontSize: minFontSize,
      maxFontSize: finalFontSize ?? maxFontSize,
    );

    // 3. Apply accessibility restriction (passing the context correctly)
    return _wrapWithScaleRestriction(context, autoSizeTextWidget);
  }
}