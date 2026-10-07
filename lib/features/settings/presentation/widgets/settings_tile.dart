import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:ikms/core/constants/app_constants.dart';
import 'package:ikms/core/utils/responsive_utils.dart';
import 'package:ikms/i18n/tr.dart';
import 'package:material_ui/material_ui.dart';

/// Single tappable settings row with optional value or custom trailing.
class SettingsTile extends StatelessWidget {
  /// Creates a settings list tile.
  const SettingsTile({
    super.key,
    required this.leading,
    this.title,
    this.titleText,
    this.value,
    this.trailing,
    this.onTap,
    this.titleColor,
    this.iconColor,
  }) : assert(
         title != null || titleText != null,
         'SettingsTile needs title or titleText',
       );

  /// Leading icon or widget.
  final Widget leading;

  /// Localization key for the title (ignored when [titleText] is set).
  final String? title;

  /// Pre-localized title when the text must not go through `.tr`.
  final String? titleText;

  /// Optional already-resolved trailing value text.
  final String? value;

  /// Optional custom trailing widget (e.g. switch).
  final Widget? trailing;

  /// Tap callback; when null the tile is non-interactive.
  final VoidCallback? onTap;

  /// Optional override for title color.
  final Color? titleColor;

  /// Optional override for leading icon color.
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingL,
        vertical: AppConstants.spacingXS,
      ),
      leading: IconTheme(
        data: IconThemeData(
          color: iconColor ?? titleColor ?? colorScheme.onSurfaceVariant,
          size: 24,
        ),
        child: leading,
      ),
      title: Text(
        titleText ?? title!.tr,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
          color: titleColor ?? colorScheme.onSurface,
          fontSize: ResponsiveUtils.getResponsiveFontSize(context, 15),
        ),
      ),
      trailing: trailing ?? _buildDefaultTrailing(context, colorScheme),
    );
  }

  Widget? _buildDefaultTrailing(BuildContext context, ColorScheme colorScheme) {
    if (value != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
            ),
          ),
          const SizedBox(width: AppConstants.spacingS),
          Icon(
            IconsaxPlusLinear.arrow_right_3,
            size: 20,
            color: colorScheme.onSurfaceVariant,
          ),
        ],
      );
    }

    if (onTap != null) {
      return Icon(
        IconsaxPlusLinear.arrow_right_3,
        size: 20,
        color: colorScheme.onSurfaceVariant,
      );
    }

    return null;
  }
}
