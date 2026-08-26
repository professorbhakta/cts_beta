import 'package:cts/appManager/colors.dart';
import 'package:flutter/material.dart';

/// Brand / status colors beside [ColorScheme].
/// Seeded from [AppColors]; UI reads via [CtsThemeContext.cts].
@immutable
class CtsColors extends ThemeExtension<CtsColors> {
  const CtsColors({
    required this.yellow,
    required this.yellowBright,
    required this.yellowWarm,
    required this.yellowSoft,
    required this.yellowLight,
    required this.yellowDark,
    required this.navy,
    required this.navyLight,
    required this.navySoft,
    required this.orange,
    required this.orangeBright,
    required this.orangeWarm,
    required this.orangeSoft,
    required this.orangeLight,
    required this.orangeDark,
    required this.success,
    required this.info,
    required this.shadow,
    required this.listBackground,
    required this.drawerHeader,
    required this.listItemBorder,
  });

  factory CtsColors.light() {
    return CtsColors(
      yellow: AppColors.acYellow,
      yellowBright: AppColors.acYellowBright,
      yellowWarm: AppColors.acYellowWarm,
      yellowSoft: AppColors.acYellowSoft,
      yellowLight: AppColors.acYellowLight,
      yellowDark: AppColors.acYellowDark,
      navy: AppColors.acNavy,
      navyLight: AppColors.acNavyLight,
      navySoft: AppColors.acNavySoft,
      // Legacy orange* → navy brand accents
      orange: AppColors.acNavy,
      orangeBright: AppColors.acNavyLight,
      orangeWarm: AppColors.acNavy,
      orangeSoft: AppColors.acNavySoft,
      orangeLight: AppColors.acNavyMuted,
      orangeDark: AppColors.acOrangeDark,
      success: AppColors.acGreen,
      info: AppColors.acNavy,
      shadow: AppColors.acShadowColor,
      listBackground: AppColors.acListWidget,
      drawerHeader: AppColors.drawerHeader,
      listItemBorder: AppColors.listItemBorder,
    );
  }

  factory CtsColors.dark() {
    return CtsColors(
      yellow: AppColors.acYellow,
      yellowBright: AppColors.acYellowBright,
      yellowWarm: AppColors.acYellowWarm,
      yellowSoft: AppColors.acYellowDark.withValues(alpha: 0.35),
      yellowLight: AppColors.acYellowDark.withValues(alpha: 0.45),
      yellowDark: AppColors.acYellowDark,
      navy: AppColors.acNavyLight,
      navyLight: AppColors.acNavyMuted,
      navySoft: AppColors.acNavy.withValues(alpha: 0.45),
      orange: AppColors.acNavyLight,
      orangeBright: AppColors.acNavyMuted,
      orangeWarm: AppColors.acNavyLight,
      orangeSoft: AppColors.acNavy.withValues(alpha: 0.35),
      orangeLight: AppColors.acNavy.withValues(alpha: 0.45),
      orangeDark: AppColors.acOrangeDark,
      success: AppColors.acGreen,
      info: AppColors.acNavyLight,
      shadow: Colors.black.withValues(alpha: 0.35),
      listBackground: AppColors.acBlackLighter,
      drawerHeader: AppColors.acYellowWarm,
      listItemBorder: AppColors.acBlackLighter,
    );
  }

  final Color yellow;
  final Color yellowBright;
  final Color yellowWarm;
  final Color yellowSoft;
  final Color yellowLight;
  final Color yellowDark;
  final Color navy;
  final Color navyLight;
  final Color navySoft;
  final Color orange;
  final Color orangeBright;
  final Color orangeWarm;
  final Color orangeSoft;
  final Color orangeLight;
  final Color orangeDark;
  final Color success;
  final Color info;
  final Color shadow;
  final Color listBackground;
  final Color drawerHeader;
  final Color listItemBorder;

  @override
  CtsColors copyWith({
    Color? yellow,
    Color? yellowBright,
    Color? yellowWarm,
    Color? yellowSoft,
    Color? yellowLight,
    Color? yellowDark,
    Color? navy,
    Color? navyLight,
    Color? navySoft,
    Color? orange,
    Color? orangeBright,
    Color? orangeWarm,
    Color? orangeSoft,
    Color? orangeLight,
    Color? orangeDark,
    Color? success,
    Color? info,
    Color? shadow,
    Color? listBackground,
    Color? drawerHeader,
    Color? listItemBorder,
  }) {
    return CtsColors(
      yellow: yellow ?? this.yellow,
      yellowBright: yellowBright ?? this.yellowBright,
      yellowWarm: yellowWarm ?? this.yellowWarm,
      yellowSoft: yellowSoft ?? this.yellowSoft,
      yellowLight: yellowLight ?? this.yellowLight,
      yellowDark: yellowDark ?? this.yellowDark,
      navy: navy ?? this.navy,
      navyLight: navyLight ?? this.navyLight,
      navySoft: navySoft ?? this.navySoft,
      orange: orange ?? this.orange,
      orangeBright: orangeBright ?? this.orangeBright,
      orangeWarm: orangeWarm ?? this.orangeWarm,
      orangeSoft: orangeSoft ?? this.orangeSoft,
      orangeLight: orangeLight ?? this.orangeLight,
      orangeDark: orangeDark ?? this.orangeDark,
      success: success ?? this.success,
      info: info ?? this.info,
      shadow: shadow ?? this.shadow,
      listBackground: listBackground ?? this.listBackground,
      drawerHeader: drawerHeader ?? this.drawerHeader,
      listItemBorder: listItemBorder ?? this.listItemBorder,
    );
  }

  @override
  CtsColors lerp(ThemeExtension<CtsColors>? other, double t) {
    if (other is! CtsColors) return this;
    return CtsColors(
      yellow: Color.lerp(yellow, other.yellow, t)!,
      yellowBright: Color.lerp(yellowBright, other.yellowBright, t)!,
      yellowWarm: Color.lerp(yellowWarm, other.yellowWarm, t)!,
      yellowSoft: Color.lerp(yellowSoft, other.yellowSoft, t)!,
      yellowLight: Color.lerp(yellowLight, other.yellowLight, t)!,
      yellowDark: Color.lerp(yellowDark, other.yellowDark, t)!,
      navy: Color.lerp(navy, other.navy, t)!,
      navyLight: Color.lerp(navyLight, other.navyLight, t)!,
      navySoft: Color.lerp(navySoft, other.navySoft, t)!,
      orange: Color.lerp(orange, other.orange, t)!,
      orangeBright: Color.lerp(orangeBright, other.orangeBright, t)!,
      orangeWarm: Color.lerp(orangeWarm, other.orangeWarm, t)!,
      orangeSoft: Color.lerp(orangeSoft, other.orangeSoft, t)!,
      orangeLight: Color.lerp(orangeLight, other.orangeLight, t)!,
      orangeDark: Color.lerp(orangeDark, other.orangeDark, t)!,
      success: Color.lerp(success, other.success, t)!,
      info: Color.lerp(info, other.info, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
      listBackground: Color.lerp(listBackground, other.listBackground, t)!,
      drawerHeader: Color.lerp(drawerHeader, other.drawerHeader, t)!,
      listItemBorder: Color.lerp(listItemBorder, other.listItemBorder, t)!,
    );
  }
}

extension CtsThemeContext on BuildContext {
  ThemeData get theme => Theme.of(this);

  ColorScheme get scheme => theme.colorScheme;

  TextTheme get texts => theme.textTheme;

  CtsColors get cts => theme.extension<CtsColors>() ?? CtsColors.light();
}
