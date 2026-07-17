import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Role-home app bar with the C2S logo.
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
      title: Image.asset(
        'assets/images/c2s-01-logo.png',
        height: 40,
      ),
      actions: actions,
    );
  }
}
