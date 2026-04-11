import 'package:flutter/widgets.dart';

/// Breakpoints used throughout the app.
abstract final class Breakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
}

/// Builds different layouts based on screen width.
///
/// Usage:
/// ```dart
/// ResponsiveBuilder(
///   mobile: (context) => MobileLayout(),
///   desktop: (context) => DesktopLayout(),
/// )
/// ```
class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({
    required this.mobile,
    this.tablet,
    required this.desktop,
    super.key,
  });

  final WidgetBuilder mobile;
  final WidgetBuilder? tablet;
  final WidgetBuilder desktop;

  /// Returns true if the current screen width is considered mobile.
  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < Breakpoints.mobile;

  /// Returns true if the current screen width is considered tablet.
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= Breakpoints.mobile && width < Breakpoints.desktop;
  }

  /// Returns true if the current screen width is considered desktop.
  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= Breakpoints.desktop;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    if (width >= Breakpoints.desktop) {
      return desktop(context);
    }
    if (width >= Breakpoints.mobile && tablet != null) {
      return tablet!(context);
    }
    return mobile(context);
  }
}
