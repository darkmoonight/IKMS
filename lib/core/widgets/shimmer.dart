import 'package:ikms/core/constants/app_constants.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shimmer/shimmer.dart';

/// Theme-aware shimmer placeholder card.
class MyShimmer extends StatelessWidget {
  /// Creates a shimmer block of [height] and optional [width].
  const MyShimmer({super.key, required this.height, this.width, this.margin});

  /// Placeholder height.
  final double height;

  /// Optional placeholder width.
  final double? width;

  /// Optional outer margin around the card.
  final EdgeInsets? margin;

  /// Skeleton tone slightly above [cardColor] / scaffold for the current theme.
  static Color _surfaceTone(
    BuildContext context, {
    required double onSurfaceAlpha,
    double primaryAlpha = 0,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final background = Theme.of(context).cardColor;
    var tone = Color.alphaBlend(
      scheme.onSurface.withValues(alpha: onSurfaceAlpha),
      background,
    );
    if (primaryAlpha > 0) {
      tone = Color.alphaBlend(
        scheme.primary.withValues(alpha: primaryAlpha),
        tone,
      );
    }
    return tone;
  }

  /// Shimmer gradient tuned to scaffold/card colors with a subtle primary sweep.
  static (Color base, Color highlight) shimmerGradientColors(
    BuildContext context,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      return (
        _surfaceTone(context, onSurfaceAlpha: 0.05),
        _surfaceTone(context, onSurfaceAlpha: 0.10, primaryAlpha: 0.06),
      );
    }
    return (
      _surfaceTone(context, onSurfaceAlpha: 0.04),
      _surfaceTone(context, onSurfaceAlpha: 0.08, primaryAlpha: 0.05),
    );
  }

  /// Wraps [child] with the app shimmer colors.
  static Widget wrap(BuildContext context, Widget child) {
    final (base, highlight) = shimmerGradientColors(context);
    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) => wrap(
    context,
    Card(
      margin: margin,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusXLarge),
      ),
      child: SizedBox(height: height, width: width),
    ),
  );
}
