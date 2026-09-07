import 'package:flutter/material.dart';

/// Sole in-app c2s mark for UI: yellow C · black 2 · navy S on cream.
///
/// Always use this widget when displaying the brand logo. Do not load
/// `assets/brand/cts_logo.svg` or alternate PNGs (e.g. `c2s-01-logo.png`)
/// for product chrome — those are not the approved mark.
class CtsBrandLogo extends StatelessWidget {
  const CtsBrandLogo({
    super.key,
    this.height = 100,
    this.width,
  });

  final double height;
  final double? width;

  /// Original interlocking mark — the only asset for [CtsBrandLogo].
  static const assetPath = 'assets/images/cts_icon.png';

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      height: height,
      width: width,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
    );
  }
}
