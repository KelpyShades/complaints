import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// Single source of truth for the app's theme configuration.
abstract final class AppTheme {
  /// Student-facing screens — clean light slate.
  static ShadThemeData get student => ShadThemeData(
        brightness: Brightness.light,
        colorScheme: const ShadSlateColorScheme.light(),
      );

  /// Admin-facing screens — professional light slate.
  static ShadThemeData get admin => ShadThemeData(
        brightness: Brightness.light,
        colorScheme: const ShadSlateColorScheme.light(),
      );

  /// Alias kept for backward compatibility during migration.
  static ShadThemeData get light => student;
}
