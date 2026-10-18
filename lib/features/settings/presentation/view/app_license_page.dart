import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:ikms/core/constants/app_constants.dart';
import 'package:ikms/core/di/providers.dart';
import 'package:ikms/core/utils/navigation_helper.dart';
import 'package:ikms/core/utils/responsive_utils.dart';
import 'package:ikms/core/widgets/defer_until_route_transition.dart';
import 'package:ikms/features/settings/application/package_licenses.dart';
import 'package:ikms/features/settings/presentation/widgets/app_license_page_shimmer.dart';
import 'package:ikms/features/settings/presentation/widgets/settings_section.dart';
import 'package:ikms/features/settings/presentation/widgets/settings_tile.dart';
import 'package:ikms/i18n/tr.dart';
import 'package:material_ui/material_ui.dart';

/// Open-source licenses in the same visual language as [SettingsPage].
class AppLicensePage extends ConsumerWidget {
  const AppLicensePage({super.key});

  void _showLicenseDetail(BuildContext context, PackageLicenseInfo license) {
    NavigationHelper.showAppDialog<void>(
      context: context,
      child: _LicenseDetailDialog(license: license),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final licensesAsync = ref.watch(packageLicensesProvider);
    final appVersion = ref
        .watch(appVersionProvider)
        .maybeWhen(data: (version) => version, orElse: () => null);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        titleSpacing: 0,
        leading: IconButton(
          onPressed: () => NavigationHelper.back(context),
          icon: const Icon(IconsaxPlusLinear.arrow_left_3, size: 20),
        ),
        title: Text('license'.tr),
      ),
      body: licensesAsync.when(
        loading: () => const AppLicensePageShimmer(),
        error: (_, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spacingXXL),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 60,
                  color: Theme.of(context).colorScheme.error,
                ),
                const Gap(AppConstants.spacingL),
                Text(
                  'error_loading_data'.tr,
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const Gap(AppConstants.spacingS),
                ElevatedButton(
                  onPressed: () => ref.invalidate(packageLicensesProvider),
                  child: Text('try_again'.tr),
                ),
              ],
            ),
          ),
        ),
        data: (licenses) => DeferUntilRouteTransition(
          placeholder: const AppLicensePageShimmer(),
          child: _LicensePackageList(
            licenses: licenses,
            appVersion: appVersion,
            onLicenseTap: (license) => _showLicenseDetail(context, license),
          ),
        ),
      ),
    );
  }
}

/// Scrollable package list below the app summary header.
class _LicensePackageList extends StatelessWidget {
  const _LicensePackageList({
    required this.licenses,
    required this.appVersion,
    required this.onLicenseTap,
  });

  final List<PackageLicenseInfo> licenses;
  final String? appVersion;
  final ValueChanged<PackageLicenseInfo> onLicenseTap;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingL,
        vertical: AppConstants.spacingM,
      ),
      children: [
        _LicenseAppHeader(
          appVersion: appVersion,
          packageCount: licenses.length,
        ),
        SettingsSection(
          title: 'licenseDependencies',
          icon: IconsaxPlusBold.document_text,
          children: [
            for (final license in licenses)
              SettingsTile(
                leading: const Icon(IconsaxPlusLinear.document),
                titleText: license.packageName,
                value: license.paragraphCount == 1
                    ? '1'
                    : '${license.paragraphCount}',
                onTap: () => onLicenseTap(license),
              ),
          ],
        ),
      ],
    );
  }
}

/// Dialog that loads one package's license text on demand.
class _LicenseDetailDialog extends StatelessWidget {
  const _LicenseDetailDialog({required this.license});

  final PackageLicenseInfo license;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isMobile = ResponsiveUtils.isMobile(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isMobile ? double.infinity : AppConstants.maxDialogWidth,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Card(
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppConstants.borderRadiusXXLarge,
            ),
            side: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.3),
              width: AppConstants.borderWidthThin,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppConstants.spacingXXL),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppConstants.spacingM),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer.withValues(
                          alpha: 0.5,
                        ),
                        borderRadius: BorderRadius.circular(
                          AppConstants.borderRadiusMedium,
                        ),
                      ),
                      child: Icon(
                        IconsaxPlusLinear.document_text,
                        size: AppConstants.iconSizeLarge,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacingL),
                    Expanded(
                      child: Text(
                        license.packageName,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                          fontSize: ResponsiveUtils.getResponsiveFontSize(
                            context,
                            20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: FutureBuilder<String>(
                  future: loadPackageLicenseText(license.packageName),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Padding(
                        padding: EdgeInsets.all(AppConstants.spacingXXL),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final text = snapshot.data;
                    if (text == null || text.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(AppConstants.spacingXXL),
                        child: Text(
                          'errorOccurred'.tr,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                      );
                    }

                    return SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                        AppConstants.spacingXXL,
                        0,
                        AppConstants.spacingXXL,
                        AppConstants.spacingL,
                      ),
                      child: SelectableText(
                        text,
                        style: _licenseBodyStyle(context, colorScheme),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppConstants.spacingXXL,
                  AppConstants.spacingS,
                  AppConstants.spacingXXL,
                  AppConstants.spacingXXL,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FilledButton.tonal(
                      onPressed: () => NavigationHelper.back(context),
                      style: FilledButton.styleFrom(
                        backgroundColor: colorScheme.primaryContainer,
                        foregroundColor: colorScheme.onPrimaryContainer,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.spacingXL,
                          vertical: AppConstants.spacingM,
                        ),
                      ),
                      child: Text(
                        'close'.tr,
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getResponsiveFontSize(
                            context,
                            14,
                          ),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shared body style for license detail text.
TextStyle _licenseBodyStyle(BuildContext context, ColorScheme colorScheme) =>
    Theme.of(context).textTheme.bodyMedium!.copyWith(
      color: colorScheme.onSurfaceVariant,
      fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
      height: 1.5,
    );

/// App icon, version, and package count above the dependency list.
class _LicenseAppHeader extends ConsumerWidget {
  const _LicenseAppHeader({
    required this.appVersion,
    required this.packageCount,
  });

  final String? appVersion;
  final int packageCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final amoledTheme = ref.watch(appSettingsProvider).amoledTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingL),
      child: Card(
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
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingXL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(
                      AppConstants.borderRadiusLarge,
                    ),
                    child: Image.asset(
                      'assets/icons/icon.png',
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const Gap(AppConstants.spacingL),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'IKMS',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                                fontSize: ResponsiveUtils.getResponsiveFontSize(
                                  context,
                                  20,
                                ),
                                height: 1.2,
                              ),
                        ),
                        if (appVersion != null) ...[
                          const Gap(AppConstants.spacingS),
                          _AppVersionChip(version: appVersion!),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const Gap(AppConstants.spacingL),
              Text(
                'licenseAppSummary'.tr,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                  height: 1.4,
                ),
              ),
              const Gap(AppConstants.spacingS),
              Row(
                children: [
                  Icon(
                    IconsaxPlusLinear.box,
                    size: AppConstants.iconSizeSmall,
                    color: colorScheme.primary,
                  ),
                  const Gap(AppConstants.spacingXS),
                  Text(
                    '$packageCount ${'licensePackages'.tr}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: ResponsiveUtils.getResponsiveFontSize(
                        context,
                        13,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact version label shown under the app name.
class _AppVersionChip extends StatelessWidget {
  const _AppVersionChip({required this.version});

  final String version;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingM,
            vertical: AppConstants.spacingXS,
          ),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
          ),
          child: Text(
            'v$version',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
              height: 1.0,
            ),
            textHeightBehavior: const TextHeightBehavior(
              applyHeightToFirstAscent: false,
              applyHeightToLastDescent: false,
            ),
          ),
        ),
      ],
    );
  }
}
