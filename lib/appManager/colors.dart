import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  // Primary Color Scheme - Black, White, Yellow
  static const Color acBlack = Color(0xFF000000);
  static const Color acBlackLight = Color(0xFF1A1A1A);
  static const Color acBlackLighter = Color(0xFF2D2D2D);
  static const Color acWhite = Color(0xFFFFFFFF);
  static const Color acWhiteOff = Color(0xFFF5F5F5);
  static const Color acWhiteSoft = Color(0xFFFAFAFA);

  // Yellow Variations - Primary Brand Color
  static const Color acYellow = Color(0xFFFFD700);
  static const Color acYellowBright = Color(0xFFFFEB3B);
  static const Color acYellowWarm = Color(0xFFFFC107);
  static const Color acYellowSoft = Color(0xFFFFF9C4);
  static const Color acYellowLight = Color(0xFFFFF59D);
  static const Color acYellowDark = Color(0xFFF9A825);

  // Orange Variations - Complementary to Yellow (for alternation)
  static const Color acOrange = Color(0xFFFF9800);
  static const Color acOrangeBright = Color(0xFFFFB74D);
  static const Color acOrangeWarm = Color(0xFFFF6F00);
  static const Color acOrangeSoft = Color(0xFFFFE0B2);
  static const Color acOrangeLight = Color(0xFFFFCC80);
  static const Color acOrangeDark = Color(0xFFE65100);

  // Accent Colors (for actions and status)
  static const Color acRed = Color(0xFFD32F2F);
  static const Color acGreen = Color(0xFF388E3C);
  static const Color acBlue = Color(0xFF1976D2);

  // UI Segment Colors (variations of black/white/yellow)
  static Color get acShadowColor => Colors.black.withValues(alpha: 0.1);
  static const Color acBackGround = acWhiteSoft;
  static const Color acListWidget = acWhiteOff;

  // Dashboard Card Colors (yellow variations)
  static const Color dashboardPrimary = acYellowWarm;
  static const Color dashboardSecondary = acYellowBright;
  static const Color dashboardAccent = acYellowDark;

  // Drawer Colors
  static const Color drawerBackground = acBlack;
  static const Color drawerHeader = acYellowWarm;

  // List Item Colors (subtle yellow tints)
  static const Color listItemBackground = acWhite;
  static const Color listItemBorder = acYellowSoft;
}
