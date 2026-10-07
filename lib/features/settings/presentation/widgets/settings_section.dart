import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ikms/core/constants/app_constants.dart';
import 'package:ikms/core/di/providers.dart';
import 'package:ikms/core/utils/responsive_utils.dart';
import 'package:ikms/i18n/tr.dart';
import 'package:material_ui/material_ui.dart';

/// Grouped card of settings tiles with a titled icon header.
class SettingsSection extends ConsumerWidget {
  /// Creates a settings section.
  const SettingsSection({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
  });

  /// Localization key for the section title.
  final String title;

  /// Leading icon for the section header.
  final IconData icon;

  /// Settings tiles shown inside the card.
  final List<Widget> children;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final amoledTheme = ref.watch(appSettingsProvider).amoledTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: AppConstants.spacingL,
            bottom: AppConstants.spacingM,
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: colorScheme.primary),
              const SizedBox(width: AppConstants.spacingS),
              Text(
                title.tr,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        Card(
          margin: EdgeInsets.zero,
          shape: amoledTheme
              ? RoundedRectangleBorder(
                  side: BorderSide(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(20),
                )
              : null,
          child: Column(
            children: [
              for (int i = 0; i < children.length; i++) ...[
                children[i],
                if (i < children.length - 1)
                  Divider(
                    height: 1,
                    color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
