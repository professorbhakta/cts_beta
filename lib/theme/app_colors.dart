import 'package:flutter/material.dart';

/// c2s brand triad (logo): yellow · black · navy on cream.
///
/// On-color rules:
/// - Black / navy backgrounds → white text
/// - Yellow backgrounds → black text
/// - Cream / white surfaces → black text
class AppColors {
  const AppColors._();

  // ── Brand core ──────────────────────────────────────────────
  static const Color acBlack = Color(0xFF0A0A0A);
  static const Color acBlackLight = Color(0xFF1A1A1A);
  static const Color acBlackLighter = Color(0xFF2D2D2D);

  static const Color acWhite = Color(0xFFFFFFFF);
  static const Color acWhiteOff = Color(0xFFF5F5F5);
  static const Color acCream = Color(0xFFF7F4EE);
  static const Color acWhiteSoft = acCream;

  /// Logo yellow (c)
  static const Color acYellow = Color(0xFFF5C400);
  static const Color acYellowWarm = Color(0xFFF5C400);
  static const Color acYellowBright = Color(0xFFFFD54F);
  static const Color acYellowSoft = Color(0xFFFFF3CD);
  static const Color acYellowLight = Color(0xFFFFE082);
  static const Color acYellowDark = Color(0xFFD4A800);

  /// Logo navy (s)
  static const Color acNavy = Color(0xFF0B1F4A);
  static const Color acNavyLight = Color(0xFF163A6B);
  static const Color acNavySoft = Color(0xFFD6DEEB);
  static const Color acNavyMuted = Color(0xFF3A4F73);

  // Legacy orange names → navy family (brand triad; avoid orange as primary)
  static const Color acOrange = acNavy;
  static const Color acOrangeBright = acNavyLight;
  static const Color acOrangeWarm = acNavy;
  static const Color acOrangeSoft = acNavySoft;
  static const Color acOrangeLight = acNavyMuted;
  static const Color acOrangeDark = Color(0xFF071533);

  // Status (keep for success / error only)
  static const Color acRed = Color(0xFFD32F2F);
  static const Color acGreen = Color(0xFF388E3C);
  /// Prefer [acNavy] for brand; kept for rare info links
  static const Color acBlue = acNavy;

  static Color get acShadowColor => Colors.black.withValues(alpha: 0.1);
  static const Color acBackGround = acCream;
  static const Color acListWidget = acWhiteOff;

  static const Color dashboardPrimary = acYellowWarm;
  static const Color dashboardSecondary = acNavy;
  static const Color dashboardAccent = acYellowDark;

  static const Color drawerBackground = acBlack;
  /// Yellow header → black text/icons on it
  static const Color drawerHeader = acYellowWarm;

  static const Color listItemBackground = acWhite;
  static const Color listItemBorder = acYellowSoft;

  /// Text/icon on a filled brand surface (yellow → black; navy/black → white).
  static Color onColor(Color background) {
    return ThemeData.estimateBrightnessForColor(background) == Brightness.dark
        ? acWhite
        : acBlack;
  }
}
