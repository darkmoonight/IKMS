import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:ikms/app.dart';
import 'package:ikms/core/di/providers.dart';
import 'package:ikms/core/utils/navigation_helper.dart';
import 'package:ikms/core/utils/responsive_utils.dart';
import 'package:ikms/core/utils/show_snack_bar.dart';
import 'package:ikms/core/widgets/confirmation_dialog.dart';
import 'package:ikms/data/models/db.dart';
import 'package:ikms/features/selection/presentation/view/selection_pages.dart';
import 'package:ikms/features/settings/presentation/view/app_license_page.dart';
import 'package:ikms/features/settings/presentation/widgets/selection_dialog.dart';
import 'package:ikms/features/settings/presentation/widgets/settings_section.dart';
import 'package:ikms/features/settings/presentation/widgets/settings_tile.dart';
import 'package:ikms/i18n/locale_utils.dart';
import 'package:ikms/i18n/tr.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

/// App settings screen for appearance, schedule, preferences, and about.
class SettingsPage extends ConsumerStatefulWidget {
  /// Creates the settings page.
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  Future<void> _updateLanguage(Locale locale) async {
    final settings = ref.read(settingsProvider);
    settings.language = languageCodeFromAppLocale(
      appLocaleFromFlutterLocale(locale),
    );
    await ref.read(settingsRepositoryProvider).save(settings);
    IkmsApp.updateAppState(ref, newLocale: locale);
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _urlLauncher(String uri) async {
    final url = Uri.parse(uri);
    try {
      final launched = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        showSnackBar('errorOccurred'.tr, isError: true);
      }
    } catch (_) {
      showSnackBar('errorOccurred'.tr, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtils.isMobile(context);
    final padding = ResponsiveUtils.getResponsivePadding(context);
    ref.watch(adsNotifierProvider);
    ref.watch(themeModeProvider);
    ref.watch(appSettingsProvider);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? padding : padding * 2,
                vertical: padding,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildAppearanceSection(context),
                  SizedBox(height: padding * 1.5),
                  _buildScheduleSection(context),
                  SizedBox(height: padding * 1.5),
                  _buildAppPreferencesSection(context),
                  SizedBox(height: padding * 1.5),
                  _buildCommunitySection(context),
                  SizedBox(height: padding * 1.5),
                  _buildAboutSection(context),
                  SizedBox(height: padding * 2),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppearanceSection(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    return SettingsSection(
      title: 'appearance',
      icon: IconsaxPlusBold.brush_1,
      children: [
        SettingsTile(
          leading: const Icon(IconsaxPlusLinear.moon),
          title: 'theme',
          value: themePreferenceLabel(settings.theme),
          onTap: () => _showThemeDialog(context),
        ),
        SettingsTile(
          leading: const Icon(IconsaxPlusLinear.mobile),
          title: 'amoledTheme',
          trailing: Transform.scale(
            scale: 0.8,
            child: Switch(
              value: settings.amoledTheme,
              onChanged: (value) async {
                await ref.read(themeModeProvider.notifier).saveOledTheme(value);
                IkmsApp.updateAppState(ref, newAmoledTheme: value);
                if (!mounted) return;
                setState(() {});
              },
            ),
          ),
        ),
        SettingsTile(
          leading: const Icon(IconsaxPlusLinear.colorfilter),
          title: 'materialColor',
          trailing: Transform.scale(
            scale: 0.8,
            child: Switch(
              value: settings.materialColor,
              onChanged: (value) async {
                await ref
                    .read(themeModeProvider.notifier)
                    .saveMaterialTheme(value);
                IkmsApp.updateAppState(ref, newMaterialColor: value);
                if (!mounted) return;
                setState(() {});
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleSection(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final settingsRepo = ref.read(settingsRepositoryProvider);

    return SettingsSection(
      title: 'scheduleSettings',
      icon: IconsaxPlusBold.buildings,
      children: [
        SettingsTile(
          leading: const Icon(IconsaxPlusLinear.buildings),
          title: 'university',
          value: settings.university.value?.name ?? 'no_select'.tr,
          onTap: () async {
            final selectionData = await NavigationHelper.slideUp<University>(
              context,
              const UniversityPage(),
            );
            if (selectionData != null) {
              await settingsRepo.setUniversity(settings, selectionData);
              if (!mounted) return;
              setState(() {});
            }
          },
        ),
        SettingsTile(
          leading: const Icon(IconsaxPlusLinear.people),
          title: 'group',
          value: settings.group.value?.name ?? 'no_select'.tr,
          onTap: settings.university.value != null
              ? () async {
                  final selectionData =
                      await NavigationHelper.slideUp<GroupSchedule>(
                        context,
                        const GroupsPage(isSettings: true),
                      );
                  if (selectionData != null) {
                    selectionData.university.value = settings.university.value;
                    await settingsRepo.setGroup(settings, selectionData);
                    if (!mounted) return;
                    setState(() {});
                  }
                }
              : () => showSnackBar('no_university'.tr, isInfo: true),
        ),
      ],
    );
  }

  Widget _buildAppPreferencesSection(BuildContext context) {
    final adsDisabled = ref.watch(adsNotifierProvider);
    final locale = ref.watch(appSettingsProvider).locale;

    return SettingsSection(
      title: 'appPreferences',
      icon: IconsaxPlusBold.mobile,
      children: [
        SettingsTile(
          leading: const Icon(IconsaxPlusLinear.dollar_square),
          title: 'ads',
          trailing: Transform.scale(
            scale: 0.8,
            child: Switch(
              value: adsDisabled,
              onChanged: (value) async {
                if (value) {
                  await showConfirmationDialog(
                    context: context,
                    title: 'adsDisableTitle',
                    message: 'adsDisable',
                    confirmText: 'disable',
                    isDestructive: true,
                    onConfirm: () async {
                      await ref
                          .read(adsNotifierProvider.notifier)
                          .toggleAds(value);
                    },
                  );
                } else {
                  await ref.read(adsNotifierProvider.notifier).toggleAds(value);
                }
                if (!mounted) return;
                setState(() {});
              },
            ),
          ),
        ),
        SettingsTile(
          leading: const Icon(IconsaxPlusLinear.language_square),
          title: 'language',
          value:
              appLanguages.firstWhere((element) {
                    final itemLocale = element['locale'] as Locale;
                    return itemLocale.languageCode == locale.languageCode &&
                        (itemLocale.countryCode ?? '') ==
                            (locale.countryCode ?? '');
                  }, orElse: () => {'name': ''})['name']
                  as String,
          onTap: () => _showLanguageDialog(context),
        ),
      ],
    );
  }

  Widget _buildCommunitySection(BuildContext context) {
    return SettingsSection(
      title: 'ourGroups',
      icon: IconsaxPlusBold.people,
      children: [
        SettingsTile(
          leading: const Icon(LineAwesomeIcons.discord),
          title: 'Discord',
          onTap: () => _urlLauncher('https://discord.gg/JMMa9aHh8f'),
        ),
        SettingsTile(
          leading: const Icon(LineAwesomeIcons.telegram),
          title: 'Telegram',
          onTap: () => _urlLauncher('https://t.me/darkmoonightX'),
        ),
      ],
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    final appVersion = ref.watch(appVersionProvider).asData?.value;

    return SettingsSection(
      title: 'aboutApp',
      icon: IconsaxPlusBold.info_circle,
      children: [
        SettingsTile(
          leading: const Icon(IconsaxPlusLinear.document),
          title: 'license',
          onTap: () =>
              NavigationHelper.slideUp(context, const AppLicensePage()),
        ),
        SettingsTile(
          leading: const Icon(LineAwesomeIcons.github),
          title: '${'project'.tr} GitHub',
          onTap: () => _urlLauncher('https://github.com/darkmoonight/IKMS'),
        ),
        SettingsTile(
          leading: const Icon(IconsaxPlusLinear.code_circle),
          title: 'version',
          value: appVersion ?? '...',
        ),
      ],
    );
  }

  void _showThemeDialog(BuildContext context) {
    final settings = ref.read(settingsProvider);

    showSelectionDialog<String>(
      context: context,
      title: 'theme'.tr,
      icon: IconsaxPlusBold.moon,
      items: ['system', 'dark', 'light'],
      currentValue: settings.theme ?? 'system',
      itemBuilder: (theme) => theme.tr,
      onSelected: (value) async {
        await ref.read(themeModeProvider.notifier).saveTheme(value);
        if (!mounted) return;
        setState(() {});
      },
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final locale = ref.read(appSettingsProvider).locale;

    showSelectionDialog<Map<String, dynamic>>(
      context: context,
      title: 'language'.tr,
      icon: IconsaxPlusBold.language_square,
      items: appLanguages,
      currentValue: appLanguages.firstWhere(
        (element) {
          final itemLocale = element['locale'] as Locale;
          return itemLocale.languageCode == locale.languageCode &&
              (itemLocale.countryCode ?? '') == (locale.countryCode ?? '');
        },
        orElse: () => <String, dynamic>{
          'name': 'English',
          'locale': const Locale('en', 'US'),
        },
      ),
      itemBuilder: (lang) => lang['name'] as String,
      onSelected: (value) {
        final newLocale = value['locale'] as Locale;
        IkmsApp.updateAppState(ref, newLocale: newLocale);
        _updateLanguage(newLocale);
      },
      enableSearch: true,
    );
  }
}
