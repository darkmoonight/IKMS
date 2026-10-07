import 'package:material_ui/material_ui.dart';

/// Breakpoints and sizing helpers for phone / tablet / desktop layouts.
class ResponsiveUtils {
  /// Width below which the layout is treated as mobile.
  static const double mobileBreakpoint = 600;

  /// Width below which the layout is treated as tablet (at or above mobile).
  static const double tabletBreakpoint = 1024;

  /// Whether the current viewport is mobile-sized.
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileBreakpoint;

  /// Whether the current viewport is tablet-sized.
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobileBreakpoint &&
      MediaQuery.of(context).size.width < tabletBreakpoint;

  /// Standard page padding for the current breakpoint.
  static double getResponsivePadding(BuildContext context) {
    if (isMobile(context)) return 10;
    if (isTablet(context)) return 16;
    return 24;
  }

  /// Scales [baseFontSize] up on larger screens.
  static double getResponsiveFontSize(
    BuildContext context,
    double baseFontSize,
  ) {
    if (isMobile(context)) return baseFontSize;
    if (isTablet(context)) return baseFontSize * 1.1;
    return baseFontSize * 1.2;
  }
}
