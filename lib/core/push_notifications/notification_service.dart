import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:toastification/toastification.dart';

/// Adaptive notification service.
///
/// Shows [Flushbar] on small screens (< 600px) and
/// [toastification] on larger screens (web / desktop).
abstract final class NotificationService {
  static const _mobileBreakpoint = 600.0;

  static bool _isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < _mobileBreakpoint;

  // ── Success ──────────────────────────────────────────────────────────

  static void showSuccess(BuildContext context, String message) {
    if (_isMobile(context)) {
      _showFlushbar(context, message, _FlushbarType.success);
    } else {
      _showToast(context, message, ToastificationType.success);
    }
  }

  // ── Error ────────────────────────────────────────────────────────────

  static void showError(BuildContext context, String message) {
    if (_isMobile(context)) {
      _showFlushbar(context, message, _FlushbarType.error);
    } else {
      _showToast(context, message, ToastificationType.error);
    }
  }

  // ── Info ─────────────────────────────────────────────────────────────

  static void showInfo(BuildContext context, String message) {
    if (_isMobile(context)) {
      _showFlushbar(context, message, _FlushbarType.info);
    } else {
      _showToast(context, message, ToastificationType.info);
    }
  }

  // ── Warning ──────────────────────────────────────────────────────────

  static void showWarning(BuildContext context, String message) {
    if (_isMobile(context)) {
      _showFlushbar(context, message, _FlushbarType.warning);
    } else {
      _showToast(context, message, ToastificationType.warning);
    }
  }

  // ── Private helpers ──────────────────────────────────────────────────

  static void _showFlushbar(
    BuildContext context,
    String message,
    _FlushbarType type,
  ) {
    final theme = ShadTheme.of(context);

    final Color backgroundColor;
    final IconData icon;

    switch (type) {
      case _FlushbarType.success:
        backgroundColor = theme.colorScheme.primary;
        icon = LucideIcons.circleCheck;
      case _FlushbarType.error:
        backgroundColor = theme.colorScheme.destructive;
        icon = LucideIcons.circleX;
      case _FlushbarType.info:
        backgroundColor = theme.colorScheme.secondary;
        icon = LucideIcons.info;
      case _FlushbarType.warning:
        backgroundColor = theme.colorScheme.primary;
        icon = LucideIcons.triangleAlert;
    }

    Flushbar(
      message: message,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(8),
      backgroundColor: backgroundColor,
      icon: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: Icon(icon, color: theme.colorScheme.primaryForeground),
      ),
      flushbarPosition: FlushbarPosition.TOP,
    ).show(context);
  }

  static void _showToast(
    BuildContext context,
    String message,
    ToastificationType type,
  ) {
    toastification.show(
      context: context,
      title: Text(message),
      type: type,
      autoCloseDuration: const Duration(seconds: 4),
      alignment: Alignment.topRight,
      style: ToastificationStyle.flatColored,
    );
  }
}

enum _FlushbarType { success, error, info, warning }
