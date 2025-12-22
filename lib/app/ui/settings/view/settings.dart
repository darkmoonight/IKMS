import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:ikms/app/controller/ads_controller.dart';
import 'package:ikms/app/data/db.dart';
import 'package:ikms/app/ui/selection_list/view/selection_pages.dart';
import 'package:ikms/app/ui/settings/widgets/setting_card.dart';
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
    infoVersion();
  }

  Future<void> infoVersion() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() => appVersion = packageInfo.version);
  }

  void urlLauncher(String uri) async {
    final Uri url = Uri.parse(uri);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  void updateLanguage(Locale locale) {
    settings.language = '$locale';
    isar.writeTxnSync(() => isar.settings.putSync(settings));
    Get.updateLocale(locale);
    Get.back();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      centerTitle: true,
      title: Text(
        'settings'.tr,
        style: context.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    body: SingleChildScrollView(
      child: Column(
        children: [
          _buildAppearanceCard(context),
          _buildScheduleCard(context),
          _buildAppPreferencesCard(context),
          _buildCommunityCard(context),
          _buildAboutAppCard(context),
        ],
      ),
    ),
  );

  Widget _buildAppearanceCard(BuildContext context) => SettingCard(
    icon: const Icon(IconsaxPlusLinear.brush_1),
    text: 'appearance'.tr,
    onPressed: () => _showAppearanceBottomSheet(context),
  );

  void _showAppearanceBottomSheet(BuildContext context) => showModalBottomSheet(
    context: context,
    builder: (BuildContext context) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      child: StatefulBuilder(
        builder: (BuildContext context, setState) => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 15,
                ),
                child: Text(
                  'appearance'.tr,
                  style: context.textTheme.titleLarge?.copyWith(fontSize: 20),
                ),
              ),
              _buildThemeSettingCard(context, setState),
              _buildAmoledThemeSettingCard(context, setState),
              _buildMaterialColorSettingCard(context, setState),
              const Gap(10),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _buildThemeSettingCard(BuildContext context, StateSetter setState) =>
      SettingCard(
        elevation: 4,
        icon: const Icon(IconsaxPlusLinear.moon),
        text: 'theme'.tr,
        dropdown: true,
        dropdownName: settings.theme?.tr,
        dropdownList: <String>['system'.tr, 'dark'.tr, 'light'.tr],
        dropdownChange: (String? newValue) =>
            _updateTheme(newValue, context, setState),
      );

  void _updateTheme(
    String? newValue,
    BuildContext context,
    StateSetter setState,
  ) {
    ThemeMode themeMode = newValue?.tr == 'system'.tr
        ? ThemeMode.system
        : newValue?.tr == 'dark'.tr
        ? ThemeMode.dark
        : ThemeMode.light;
    String theme = newValue?.tr == 'system'.tr
        ? 'system'
        : newValue?.tr == 'dark'.tr
        ? 'dark'
        : 'light';
    themeController.saveTheme(theme);
    themeController.changeThemeMode(themeMode);
  }

  Widget _buildAmoledThemeSettingCard(
    BuildContext context,
    StateSetter setState,
  ) => SettingCard(
    elevation: 4,
    icon: const Icon(IconsaxPlusLinear.mobile),
    text: 'amoledTheme'.tr,
    switcher: true,
    value: settings.amoledTheme,
    onChange: (value) {
      themeController.saveOledTheme(value);
      MyApp.updateAppState(context, newAmoledTheme: value);
    },
  );

  Widget _buildMaterialColorSettingCard(
    BuildContext context,
    StateSetter setState,
  ) => SettingCard(
    elevation: 4,
    icon: const Icon(IconsaxPlusLinear.colorfilter),
    text: 'materialColor'.tr,
    switcher: true,
    value: settings.materialColor,
    onChange: (value) {
      themeController.saveMaterialTheme(value);
      MyApp.updateAppState(context, newMaterialColor: value);
    },
  );

  Widget _buildScheduleCard(BuildContext context) => SettingCard(
    icon: const Icon(IconsaxPlusLinear.buildings),
    text: 'scheduleSettings'.tr,
    onPressed: () => _showScheduleBottomSheet(context),
  );

  void _showScheduleBottomSheet(BuildContext context) => showModalBottomSheet(
    context: context,
    builder: (BuildContext context) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      child: StatefulBuilder(
        builder: (BuildContext context, setState) => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
                child: Text(
                  'scheduleSettings'.tr,
                  style: context.textTheme.titleLarge?.copyWith(fontSize: 20),
                ),
              ),
              _buildUniversitySettingCard(context, setState),
              _buildGroupSettingCard(context, setState),
              const Gap(10),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _buildUniversitySettingCard(
    BuildContext context,
    StateSetter setState,
  ) => SettingCard(
    elevation: 4,
    icon: const Icon(IconsaxPlusLinear.buildings),
    text: 'university'.tr,
    info: true,
    infoSettings: true,
    textInfo: settings.university.value?.name ?? 'no_select'.tr,
    onPressed: () async {
      University? selectionData = await Get.to(
        () => const UniversityPage(),
        transition: Transition.downToUp,
      );
      if (selectionData != null) {
        settings.university.value = selectionData;
        isar.writeTxnSync(() {
          isar.settings.putSync(settings);
          settings.university.saveSync();
        });
        setState(() {});
      }
    },
  );

  Widget _buildGroupSettingCard(BuildContext context, StateSetter setState) =>
      SettingCard(
        elevation: 4,
        icon: const Icon(IconsaxPlusLinear.people),
        text: 'group'.tr,
        info: true,
        infoSettings: true,
        textInfo: settings.group.value?.name ?? 'no_select'.tr,
        onPressed: settings.university.value != null
            ? () async {
                GroupSchedule? selectionData = await Get.to(
                  () => const GroupsPage(isSettings: true),
                  transition: Transition.downToUp,
                );
                if (selectionData != null) {
                  selectionData.university.value = settings.university.value;
                  settings.group.value = selectionData;
                  isar.writeTxnSync(() {
                    isar.groupSchedules.putSync(selectionData);
                    selectionData.university.saveSync();
                    isar.settings.putSync(settings);
                    settings.group.saveSync();
                  });
                  setState(() {});
                }
              }
            : () => EasyLoading.showInfo('no_university'.tr),
      );

  Widget _buildAppPreferencesCard(BuildContext context) => SettingCard(
    icon: const Icon(IconsaxPlusLinear.mobile),
    text: 'appPreferences'.tr,
    onPressed: () => _showAppPreferencesBottomSheet(context),
  );

  void _showAppPreferencesBottomSheet(
    BuildContext context,
  ) => showModalBottomSheet(
    context: context,
    builder: (BuildContext context) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      child: StatefulBuilder(
        builder: (BuildContext context, setState) => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
                child: Text(
                  'appPreferences'.tr,
                  style: context.textTheme.titleLarge?.copyWith(fontSize: 20),
                ),
              ),
              _buildAdsSettingCard(context, setState),
              _buildLanguageSettingCard(context, setState),
              const Gap(10),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _buildAdsSettingCard(BuildContext context, StateSetter setState) =>
      SettingCard(
        elevation: 4,
        icon: const Icon(IconsaxPlusLinear.dollar_square),
        text: 'ads'.tr,
        switcher: true,
        value: adsController.ads.value,
        onChange: (value) async {
          if (value) {
            await showAdaptiveDialog(
              context: context,
              builder: (BuildContext context) => AlertDialog.adaptive(
                title: Text(
                  'adsDisableTitle'.tr,
                  style: context.textTheme.titleLarge,
                ),
                content: Text(
                  'adsDisable'.tr,
                  style: context.textTheme.titleMedium,
                ),
                actions: [
                  TextButton(
                    onPressed: () => Get.back(result: false),
                    child: Text(
                      'cancel'.tr,
                      style: context.theme.textTheme.titleMedium?.copyWith(
                        color: Colors.blueAccent,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      adsController.toggleAds(value);
                      Get.back(result: true);
                    },
                    child: Text(
                      'disable'.tr,
                      style: context.theme.textTheme.titleMedium?.copyWith(
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            adsController.toggleAds(value);
          }
          setState(() {});
        },
      );

  Widget _buildLanguageSettingCard(
    BuildContext context,
    StateSetter setState,
  ) => SettingCard(
    elevation: 4,
    icon: const Icon(IconsaxPlusLinear.language_square),
    text: 'language'.tr,
    dropdown: true,
    dropdownName: appLanguages.firstWhere(
      (element) => (element['locale'] == locale),
      orElse: () => {'name': ''},
    )['name'],
    dropdownList: appLanguages.map((lang) => lang['name'] as String).toList(),
    dropdownChange: (String? newValue) {
      if (newValue == null) return;
      final selectedLang = appLanguages.firstWhere(
        (lang) => lang['name'] == newValue,
      );
      MyApp.updateAppState(context, newLocale: selectedLang['locale']);
      updateLanguage(selectedLang['locale']);
      setState(() {});
    },
  );

  Widget _buildCommunityCard(BuildContext context) => SettingCard(
    icon: const Icon(IconsaxPlusLinear.link_square),
    text: 'ourGroups'.tr,
    onPressed: () => _showCommunityBottomSheet(context),
  );

  void _showCommunityBottomSheet(BuildContext context) => showModalBottomSheet(
    context: context,
    builder: (BuildContext context) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      child: StatefulBuilder(
        builder: (BuildContext context, setState) => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
                child: Text(
                  'ourGroups'.tr,
                  style: context.textTheme.titleLarge?.copyWith(fontSize: 20),
                ),
              ),
              SettingCard(
                elevation: 4,
                icon: const Icon(LineAwesomeIcons.discord),
                text: 'Discord',
                onPressed: () => urlLauncher('https://discord.gg/JMMa9aHh8f'),
              ),
              SettingCard(
                elevation: 4,
                icon: const Icon(LineAwesomeIcons.telegram),
                text: 'Telegram',
                onPressed: () => urlLauncher('https://t.me/darkmoonightX'),
              ),
              const Gap(10),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _buildAboutAppCard(BuildContext context) => SettingCard(
    icon: const Icon(IconsaxPlusLinear.info_circle),
    text: 'aboutApp'.tr,
    onPressed: () => _showAboutAppBottomSheet(context),
  );

  void _showAboutAppBottomSheet(BuildContext context) => showModalBottomSheet(
    context: context,
    builder: (BuildContext context) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      child: StatefulBuilder(
        builder: (BuildContext context, setState) => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
                child: Text(
                  'aboutApp'.tr,
                  style: context.textTheme.titleLarge?.copyWith(fontSize: 20),
                ),
              ),
              _buildLicenseSettingCard(context),
              _buildVersionSettingCard(context),
              _buildGitHubSettingCard(context),
              const Gap(10),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _buildLicenseSettingCard(BuildContext context) => SettingCard(
    elevation: 4,
    icon: const Icon(IconsaxPlusLinear.document),
    text: 'license'.tr,
    onPressed: () => Get.to(
      () => LicensePage(
        applicationIcon: Container(
          width: 100,
          height: 100,
          margin: const EdgeInsets.symmetric(vertical: 5),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            image: DecorationImage(image: AssetImage('assets/icons/icon.png')),
          ),
        ),
        applicationName: 'IKMS',
        applicationVersion: appVersion,
      ),
      transition: Transition.downToUp,
    ),
  );

  Widget _buildVersionSettingCard(BuildContext context) => SettingCard(
    elevation: 4,
    icon: const Icon(IconsaxPlusLinear.hierarchy_square_2),
    text: 'version'.tr,
    info: true,
    textInfo: '$appVersion',
  );

  Widget _buildGitHubSettingCard(BuildContext context) => SettingCard(
    elevation: 4,
    icon: const Icon(LineAwesomeIcons.github),
    text: '${'project'.tr} GitHub',
    onPressed: () => urlLauncher('https://github.com/darkmoonight/IKMS'),
  );
}
