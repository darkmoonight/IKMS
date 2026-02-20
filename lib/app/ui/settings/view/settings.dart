import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:ikms/app/controller/ads_controller.dart';
import 'package:ikms/app/data/db.dart';
import 'package:ikms/app/ui/selection_list/view/selection_pages.dart';
import 'package:ikms/app/ui/settings/widgets/selection_dialog.dart';
import 'package:ikms/app/ui/settings/widgets/settings_section.dart';
import 'package:ikms/app/ui/settings/widgets/settings_tile.dart';
import 'package:ikms/app/ui/widgets/confirmation_dialog.dart';
import 'package:ikms/app/utils/navigation_helper.dart';
import 'package:ikms/app/utils/responsive_utils.dart';
import 'package:ikms/app/utils/show_snack_bar.dart';
import 'package:ikms/main.dart';
import 'package:ikms/theme/theme_controller.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final themeController = Get.put(ThemeController());
  final adsController = Get.put(AdsController());
  String? appVersion;

  @override
  void initState() {
    super.initState();
    _infoVersion();
  }

  Future<void> _infoVersion() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() => appVersion = packageInfo.version);
  }

  Future<void> _updateLanguage(Locale locale) async {
    settings.language = '$locale';
    await isar.writeTxn(() async => await isar.settings.put(settings));
    Get.updateLocale(locale);
    setState(() {});
  }

  Future<void> _urlLauncher(String uri) async {
    final Uri url = Uri.parse(uri);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtils.isMobile(context);
    final padding = ResponsiveUtils.getResponsivePadding(context);

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

  // ==================== SECTIONS ====================

  Widget _buildAppearanceSection(BuildContext context) {
    return SettingsSection(
      title: 'appearance',
      icon: IconsaxPlusBold.brush_1,
      children: [
        SettingsTile(
          leading: const Icon(IconsaxPlusLinear.moon),
          title: 'theme',
          value: settings.theme?.tr ?? 'system'.tr,
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
                await themeController.saveOledTheme(value);
                if (!mounted) return;
                MyApp.updateAppState(this.context, newAmoledTheme: value);
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
                await themeController.saveMaterialTheme(value);
                if (!mounted) return;
                MyApp.updateAppState(this.context, newMaterialColor: value);
                setState(() {});
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleSection(BuildContext context) {
    return SettingsSection(
      title: 'scheduleSettings',
      icon: IconsaxPlusBold.buildings,
      children: [
        SettingsTile(
          leading: const Icon(IconsaxPlusLinear.buildings),
          title: 'university',
          value: settings.university.value?.name ?? 'no_select'.tr,
          onTap: () async {
            University? selectionData =
                await NavigationHelper.slideUp<University>(
                  const UniversityPage(),
                );
            if (selectionData != null) {
              settings.university.value = selectionData;
              await isar.writeTxn(() async {
                await isar.settings.put(settings);
                await settings.university.save();
              });
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
                  GroupSchedule? selectionData =
                      await NavigationHelper.slideUp<GroupSchedule>(
                        const GroupsPage(isSettings: true),
                      );
                  if (selectionData != null) {
                    selectionData.university.value = settings.university.value;
                    settings.group.value = selectionData;
                    await isar.writeTxn(() async {
                      await isar.groupSchedules.put(selectionData);
                      await selectionData.university.save();
                      await isar.settings.put(settings);
                      await settings.group.save();
                    });
                    setState(() {});
                  }
                }
              : () => showSnackBar('no_university'.tr, isInfo: true),
        ),
      ],
    );
  }

  Widget _buildAppPreferencesSection(BuildContext context) {
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
              value: adsController.ads.value,
              onChanged: (value) async {
                if (value) {
                  await showConfirmationDialog(
                    context: context,
                    title: 'adsDisableTitle',
                    message: 'adsDisable',
                    confirmText: 'disable',
                    isDestructive: true,
                    onConfirm: () async {
                      await adsController.toggleAds(value);
                    },
                  );
                } else {
                  await adsController.toggleAds(value);
                }
                setState(() {});
              },
            ),
          ),
        ),
        SettingsTile(
          leading: const Icon(IconsaxPlusLinear.language_square),
          title: 'language',
          value:
              appLanguages.firstWhere(
                    (element) => (element['locale'] == locale),
                    orElse: () => {'name': ''},
                  )['name']
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
    return SettingsSection(
      title: 'aboutApp',
      icon: IconsaxPlusBold.info_circle,
      children: [
        SettingsTile(
          leading: const Icon(IconsaxPlusLinear.document),
          title: 'license',
          onTap: () {
            NavigationHelper.slideUp(
              LicensePage(
                applicationIcon: Container(
                  width: 100,
                  height: 100,
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  child: const Image(
                    image: AssetImage('assets/icons/icon.png'),
                  ),
                ),
                applicationName: 'IKMS',
                applicationVersion: appVersion,
              ),
            );
          },
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

  // ==================== DIALOGS ====================

  void _showThemeDialog(BuildContext context) {
    showSelectionDialog<String>(
      context: context,
      title: 'theme'.tr,
      icon: IconsaxPlusBold.moon,
      items: ['system', 'dark', 'light'],
      currentValue: settings.theme ?? 'system',
      itemBuilder: (theme) => theme.tr,
      onSelected: (value) async {
        ThemeMode mode = value == 'system'
            ? ThemeMode.system
            : value == 'dark'
            ? ThemeMode.dark
            : ThemeMode.light;
        await themeController.saveTheme(value);
        themeController.changeThemeMode(mode);
        setState(() {});
      },
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showSelectionDialog<Map<String, dynamic>>(
      context: context,
      title: 'language'.tr,
      icon: IconsaxPlusBold.language_square,
      items: appLanguages,
      currentValue: appLanguages.firstWhere(
        (element) =>
            (element['locale'] as Locale).languageCode == locale.languageCode,
        orElse: () => <String, dynamic>{
          'name': 'English',
          'locale': const Locale('en', 'US'),
        },
      ),
      itemBuilder: (lang) => lang['name'] as String,
      onSelected: (value) {
        MyApp.updateAppState(context, newLocale: value['locale']);
        _updateLanguage(value['locale']);
      },
      enableSearch: true,
    );
  }
}
