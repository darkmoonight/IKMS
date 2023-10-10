import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:ficonsax/ficonsax.dart';
import 'package:ikms/app/controller/ads_controller.dart';
import 'package:ikms/app/data/schema.dart';
import 'package:ikms/app/modules/selection_list/view/groups.dart';
import 'package:ikms/app/modules/selection_list/view/university.dart';
import 'package:ikms/app/modules/settings/widgets/setting_card.dart';
import 'package:ikms/main.dart';
import 'package:ikms/theme/theme_controller.dart';
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

  Future<void> infoVersion() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      appVersion = packageInfo.version;
    });
  }

  updateLanguage(Locale locale) {
    settings.language = '$locale';
    isar.writeTxnSync(() => isar.settings.putSync(settings));
    Get.updateLocale(locale);
    Get.back();
  }

  @override
  void initState() {
    infoVersion();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'settings'.tr,
          style: context.theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SettingCard(
              icon: const Icon(IconsaxOutline.brush_1),
              text: 'appearance'.tr,
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return StatefulBuilder(
                      builder: (BuildContext context, setState) {
                        return SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 15),
                                child: Text(
                                  'appearance'.tr,
                                  style: context.textTheme.titleLarge?.copyWith(
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              SettingCard(
                                elevation: 4,
                                icon: const Icon(IconsaxOutline.moon),
                                text: 'theme'.tr,
                                dropdown: true,
                                dropdownName: settings.theme?.tr,
                                dropdownList: <String>[
                                  'system'.tr,
                                  'dark'.tr,
                                  'light'.tr
                                ],
                                dropdownCange: (String? newValue) {
                                  ThemeMode themeMode =
                                      newValue?.tr == 'system'.tr
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
                                  setState(() {});
                                },
                              ),
                              SettingCard(
                                elevation: 4,
                                icon: const Icon(IconsaxOutline.mobile),
                                text: 'amoledTheme'.tr,
                                switcher: true,
                                value: settings.amoledTheme,
                                onChange: (value) {
                                  themeController.saveOledTheme(value);
                                  MyApp.updateAppState(context,
                                      newAmoledTheme: value);
                                },
                              ),
                              SettingCard(
                                elevation: 4,
                                icon: const Icon(IconsaxOutline.colorfilter),
                                text: 'materialColor'.tr,
                                switcher: true,
                                value: settings.materialColor,
                                onChange: (value) {
                                  themeController.saveMaterialTheme(value);
                                  MyApp.updateAppState(context,
                                      newMaterialColor: value);
                                },
                              ),
                              const SizedBox(height: 10),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
            SettingCard(
              icon: const Icon(IconsaxOutline.code),
              text: 'functions'.tr,
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return StatefulBuilder(
                      builder: (BuildContext context, setState) {
                        return SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 15),
                                child: Text(
                                  'functions'.tr,
                                  style: context.textTheme.titleLarge?.copyWith(
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              SettingCard(
                                elevation: 4,
                                icon: const Icon(IconsaxOutline.dollar_square),
                                text: 'ads'.tr,
                                switcher: true,
                                value: adsController.ads.value,
                                onChange: (value) async {
                                  if (value) {
                                    await showAdaptiveDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog.adaptive(
                                          title: Text(
                                            'adsDisaleTitle'.tr,
                                            style: context.textTheme.titleLarge,
                                          ),
                                          content: Text('adsDisable'.tr,
                                              style: context
                                                  .textTheme.titleMedium),
                                          actions: [
                                            TextButton(
                                                onPressed: () =>
                                                    Get.back(result: false),
                                                child: Text('cancel'.tr,
                                                    style: context.theme
                                                        .textTheme.titleMedium
                                                        ?.copyWith(
                                                            color: Colors
                                                                .blueAccent))),
                                            TextButton(
                                                onPressed: () {
                                                  adsController
                                                      .toggleAds(value);
                                                  Get.back(result: true);
                                                },
                                                child: Text('disable'.tr,
                                                    style: context.theme
                                                        .textTheme.titleMedium
                                                        ?.copyWith(
                                                            color:
                                                                Colors.red))),
                                          ],
                                        );
                                      },
                                    );
                                  } else {
                                    adsController.toggleAds(value);
                                  }
                                  setState(() {});
                                },
                              ),
                              const SizedBox(height: 10),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
            SettingCard(
              icon: const Icon(IconsaxOutline.buildings),
              text: 'university'.tr,
              info: true,
              infoSettings: true,
              textInfo: settings.university.value?.name ?? 'no_select'.tr,
              onPressed: () async {
                University? selectionData = await Get.to(
                    () => const UniversityPage(),
                    transition: Transition.downToUp);
                if (selectionData != null) {
                  settings.university.value = selectionData;
                  isar.writeTxnSync(() {
                    isar.settings.putSync(settings);
                    settings.university.saveSync();
                  });
                  setState(() {});
                }
              },
            ),
            SettingCard(
              icon: const Icon(IconsaxOutline.people),
              text: 'group'.tr,
              info: true,
              infoSettings: true,
              textInfo: settings.group.value?.name ?? 'no_select'.tr,
              onPressed: settings.university.value != null
                  ? () async {
                      GroupSchedule? selectionData = await Get.to(
                          () => const GroupsPage(isSettings: true),
                          transition: Transition.downToUp);
                      if (selectionData != null) {
                        selectionData.university.value =
                            settings.university.value;
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
            ),
            SettingCard(
              icon: const Icon(IconsaxOutline.language_square),
              text: 'language'.tr,
              info: true,
              infoSettings: true,
              textInfo: appLanguages.firstWhere(
                  (element) => (element['locale'] == locale),
                  orElse: () => appLanguages.first)['name'],
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return StatefulBuilder(
                      builder: (BuildContext context, setState) {
                        return ListView(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 15),
                              child: Text(
                                'language'.tr,
                                style: context.textTheme.titleLarge?.copyWith(
                                  fontSize: 20,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const BouncingScrollPhysics(),
                              itemCount: appLanguages.length,
                              itemBuilder: (context, index) {
                                return Card(
                                  elevation: 4,
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 5),
                                  child: ListTile(
                                    title: Text(
                                      appLanguages[index]['name'],
                                      style: context.textTheme.labelLarge,
                                      textAlign: TextAlign.center,
                                    ),
                                    onTap: () {
                                      MyApp.updateAppState(context,
                                          newLocale: appLanguages[index]
                                              ['locale']);
                                      updateLanguage(
                                          appLanguages[index]['locale']);
                                    },
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 10),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            ),
            SettingCard(
              icon: const Icon(IconsaxOutline.hierarchy_square_2),
              text: 'version'.tr,
              info: true,
              textInfo: '$appVersion',
            ),
            SettingCard(
              icon: const Icon(IconsaxOutline.document),
              text: 'license'.tr,
              onPressed: () => Get.to(
                LicensePage(
                  applicationIcon: Container(
                    width: 100,
                    height: 100,
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        image: DecorationImage(
                            image: AssetImage('assets/icons/icon.png'))),
                  ),
                  applicationName: 'IKMS',
                  applicationVersion: appVersion,
                ),
                transition: Transition.downToUp,
              ),
            ),
            SettingCard(
              icon: Image.asset(
                'assets/images/github.png',
                scale: 20,
              ),
              text: '${'project'.tr} GitHub',
              onPressed: () async {
                final Uri url =
                    Uri.parse('https://github.com/DarkMooNight/IKMS');
                if (!await launchUrl(url,
                    mode: LaunchMode.externalApplication)) {
                  throw Exception('Could not launch $url');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
