import 'package:material_ui/material_ui.dart';
import 'package:ikms/core/utils/responsive_utils.dart';

/// Full-width filled action button used across the app.
class MyTextButton extends StatelessWidget {
  /// Creates a primary action button.
  const MyTextButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.height,
    this.icon,
  });

  /// Button label.
  final String text;

  /// Tap callback; when null the button is disabled.
  final VoidCallback? onPressed;

  /// Optional fixed height (defaults to 52).
  final double? height;

  /// Optional leading icon.
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final buttonHeight = height ?? 52.0;
    final colorScheme = Theme.of(context).colorScheme;
    final padding = ResponsiveUtils.getResponsivePadding(context);

    return SizedBox(
      height: buttonHeight,
      width: double.infinity,
      child: FilledButton(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.disabled)) {
              return colorScheme.onSurface.withValues(alpha: 0.12);
            }
            if (states.contains(WidgetState.pressed)) {
              return colorScheme.primary;
            }
            if (states.contains(WidgetState.hovered)) {
              return colorScheme.primaryContainer;
            }
            return colorScheme.primaryContainer;
          }),
          foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.disabled)) {
              return colorScheme.onSurface.withValues(alpha: 0.38);
            }
            if (states.contains(WidgetState.pressed)) {
              return colorScheme.onPrimary;
            }
            return colorScheme.onPrimaryContainer;
          }),
          elevation: WidgetStateProperty.resolveWith<double>((states) {
            if (states.contains(WidgetState.disabled)) return 0;
            if (states.contains(WidgetState.pressed)) return 0;
            if (states.contains(WidgetState.hovered)) return 1;
            return 0;
          }),
          shadowColor: WidgetStatePropertyAll(
            colorScheme.shadow.withValues(alpha: 0.2),
          ),
          overlayColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.pressed)) {
              return colorScheme.onPrimaryContainer.withValues(alpha: 0.12);
            }
            if (states.contains(WidgetState.hovered)) {
              return colorScheme.onPrimaryContainer.withValues(alpha: 0.08);
            }
            return Colors.transparent;
          }),
          padding: WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: padding * 2),
          ),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
        onPressed: onPressed,
        child: _buildButtonContent(context),
      ),
    );
  }

  Widget _buildButtonContent(BuildContext context) {
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    return Text(
      text,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
      ),
      overflow: TextOverflow.ellipsis,
    );
  }
}
