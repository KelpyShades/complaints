import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// Single source of truth for the app's theme configuration.
abstract final class AppTheme {
  static const Color surfaceColor = Color(0xFFf8fafc);
  static const Color backgroundColor = Color(0xFFe2e9f0);
  static const Color accentColor = Color(0xFF303030);

  static const Color primaryColor = Color(0xFF121212);

  /// S
  static ShadThemeData get student => ShadThemeData(
    brightness: Brightness.light,
    textTheme: ShadTextTheme.fromGoogleFont(GoogleFonts.poppins),
    colorScheme: const ShadSlateColorScheme.light(
      background: backgroundColor,
      foreground: primaryColor,
      card: surfaceColor,
      cardForeground: primaryColor,
      popover: surfaceColor,
      popoverForeground: primaryColor,
      primary: primaryColor,
      primaryForeground: surfaceColor,
      accent: accentColor,
      accentForeground: surfaceColor,
    ),
  );

  /// Admin-facing screens — professional light slate (same token discipline).
  static ShadThemeData get admin => ShadThemeData(
    brightness: Brightness.light,
    textTheme: ShadTextTheme.fromGoogleFont(GoogleFonts.poppins),
    colorScheme: const ShadSlateColorScheme.light(
      background: backgroundColor,
      foreground: primaryColor,
      card: surfaceColor,
      accent: accentColor,
      accentForeground: surfaceColor,
      cardForeground: primaryColor,
      popover: surfaceColor,
      popoverForeground: primaryColor,
      primary: primaryColor,
      primaryForeground: surfaceColor,
    ),
  );

  /// Alias kept for backward compatibility during migration.
  static ShadThemeData get light => student;
}
