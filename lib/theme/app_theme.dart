import 'package:cts/appManager/colors.dart';
import 'package:cts/theme/cts_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    final colorScheme = ColorScheme.light(
      primary: AppColors.acYellowWarm,
      onPrimary: AppColors.acBlack,
      primaryContainer: AppColors.acYellowSoft,
      onPrimaryContainer: AppColors.acBlack,
      secondary: AppColors.acNavy,
      onSecondary: AppColors.acWhite,
      secondaryContainer: AppColors.acNavySoft,
      onSecondaryContainer: AppColors.acNavy,
      tertiary: AppColors.acYellowBright,
      onTertiary: AppColors.acBlack,
      error: AppColors.acRed,
      onError: AppColors.acWhite,
      surface: AppColors.acWhite,
      onSurface: AppColors.acBlack,
      surfaceContainerHighest: AppColors.acCream,
      onSurfaceVariant: AppColors.acBlackLight,
      outline: AppColors.acBlackLighter.withValues(alpha: 0.2),
      outlineVariant: AppColors.acYellowSoft,
      inverseSurface: AppColors.acBlack,
      onInverseSurface: AppColors.acWhite,
    );

    return _buildTheme(
      colorScheme: colorScheme,
      ctsColors: CtsColors.light(),
      scaffoldBackground: AppColors.acCream,
      appBarBackground: AppColors.acBlack,
      appBarForeground: AppColors.acWhite,
      cardColor: AppColors.acWhite,
      chipBackground: AppColors.acYellowSoft,
      chipSelected: AppColors.acYellowWarm,
      textOnSurface: AppColors.acBlack,
      brightness: Brightness.light,
    );
  }

  static ThemeData dark() {
    final colorScheme = ColorScheme.dark(
      primary: AppColors.acYellowWarm,
      onPrimary: AppColors.acBlack,
      primaryContainer: AppColors.acYellowDark,
      onPrimaryContainer: AppColors.acBlack,
      secondary: AppColors.acNavyLight,
      onSecondary: AppColors.acWhite,
      secondaryContainer: AppColors.acNavy,
      onSecondaryContainer: AppColors.acWhite,
      tertiary: AppColors.acNavyMuted,
      onTertiary: AppColors.acWhite,
      error: AppColors.acRed,
      onError: AppColors.acWhite,
      surface: AppColors.acBlackLight,
      onSurface: AppColors.acWhite,
      surfaceContainerHighest: AppColors.acBlackLighter,
      onSurfaceVariant: AppColors.acWhiteOff,
      outline: AppColors.acWhite.withValues(alpha: 0.24),
      outlineVariant: AppColors.acBlackLighter,
      inverseSurface: AppColors.acCream,
      onInverseSurface: AppColors.acBlack,
    );

    return _buildTheme(
      colorScheme: colorScheme,
      ctsColors: CtsColors.dark(),
      scaffoldBackground: AppColors.acBlack,
      appBarBackground: AppColors.acBlack,
      appBarForeground: AppColors.acWhite,
      cardColor: AppColors.acBlackLight,
      chipBackground: AppColors.acBlackLighter,
      chipSelected: AppColors.acYellowWarm,
      textOnSurface: AppColors.acWhite,
      brightness: Brightness.dark,
    );
  }

  static ThemeData _buildTheme({
    required ColorScheme colorScheme,
    required CtsColors ctsColors,
    required Color scaffoldBackground,
    required Color appBarBackground,
    required Color appBarForeground,
    required Color cardColor,
    required Color chipBackground,
    required Color chipSelected,
    required Color textOnSurface,
    required Brightness brightness,
  }) {
    final base = ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      brightness: brightness,
      visualDensity: VisualDensity.standard,
      extensions: [ctsColors],
    );

    final textTheme = GoogleFonts.interTextTheme(base.textTheme).apply(
      bodyColor: textOnSurface,
      displayColor: textOnSurface,
    ).copyWith(
      headlineSmall: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: textOnSurface,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: textOnSurface,
      ),
      bodyMedium: GoogleFonts.inter(fontSize: 14, color: textOnSurface),
    );

    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: colorScheme.outline),
    );

    final overlayStyle = brightness == Brightness.dark
        ? SystemUiOverlayStyle.light
        : const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
          );

    return base.copyWith(
      textTheme: textTheme,
      scaffoldBackgroundColor: scaffoldBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: appBarBackground,
        foregroundColor: appBarForeground,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: overlayStyle,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: appBarForeground,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: cardColor,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
      ),
      chipTheme: base.chipTheme.copyWith(
        labelStyle: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: textOnSurface,
        ),
        // Selected chips use yellow → black label (on-yellow rule)
        secondaryLabelStyle: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.acBlack,
        ),
        backgroundColor: chipBackground,
        selectedColor: chipSelected,
        checkmarkColor: AppColors.acBlack,
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: inputBorder,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 1,
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.secondary,
          minimumSize: const Size(48, 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.secondary,
          minimumSize: const Size(48, 48),
          side: BorderSide(color: colorScheme.secondary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: colorScheme.onSurface,
          minimumSize: const Size(48, 48),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onInverseSurface,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: colorScheme.onSurfaceVariant,
        textColor: colorScheme.onSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        circularTrackColor: colorScheme.primary.withValues(alpha: 0.2),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        showDragHandle: true,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      navigationDrawerTheme: NavigationDrawerThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primary.withValues(alpha: 0.25),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.acBlack;
            }
            return colorScheme.onSurface;
          }),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return colorScheme.primary;
            }
            return colorScheme.surface;
          }),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return ctsColors.success;
          }
          return colorScheme.error;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return ctsColors.success.withValues(alpha: 0.4);
          }
          return colorScheme.error.withValues(alpha: 0.3);
        }),
      ),
    );
  }
}
