import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cts/widgets/cts_brand_logo.dart';

/// Role-home app bar with the c2s brand mark.
///
/// iOS/macOS: centered title (platform convention).
/// Android/other: start-aligned (Material 3 / theme default).
class BrandAppBar extends StatelessWidget implements PreferredSizeWidget {
  const BrandAppBar({
    super.key,
    this.actions,
    this.automaticallyImplyLeading = true,
  });

  final List<Widget>? actions;
  final bool automaticallyImplyLeading;

  static bool get platformCentersTitle {
    return switch (defaultTargetPlatform) {
      TargetPlatform.iOS || TargetPlatform.macOS => true,
      _ => false,
    };
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: platformCentersTitle,
      automaticallyImplyLeading: automaticallyImplyLeading,
      title: const CtsBrandLogo(height: 40),
      actions: actions,
    );
  }
}
