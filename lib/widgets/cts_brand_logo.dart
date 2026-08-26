import 'package:flutter/material.dart';

/// Primary c2s mark (yellow · black · navy on cream).
class CtsBrandLogo extends StatelessWidget {
  const CtsBrandLogo({super.key, this.height = 100});

  final double height;

  static const assetPath = 'assets/images/cts_icon.png';

  @override
  Widget build(BuildContext context) {
    return Image.asset(assetPath, height: height);
  }
}
