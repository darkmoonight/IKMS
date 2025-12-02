import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:ikms/app/api/caching.dart';
import 'package:ikms/app/data/db.dart';
import 'package:ikms/app/ui/home.dart';
import 'package:ikms/app/ui/selection_list/view/selection_pages.dart';
import 'package:ikms/app/ui/widgets/button.dart';
import 'package:ikms/main.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(),
    body: SafeArea(
      child: Column(
        children: [
          Flexible(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/onboard.png', scale: 5),
                Text(
                  'timetable'.tr,
                  style: context.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Gap(10),
                SizedBox(
                  width: 300,
                  child: Text(
                    'sched_hint'.tr,
                    style: context.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: MyTextButton(
              text: 'get_started'.tr,
              onPressed: () async => await _handleGetStarted(context),
            ),
          ),
        ],
      ),
    ),
  );

  Future<void> _handleGetStarted(BuildContext context) async {
    University? university;
    GroupSchedule? group;

    do {
      university = await Get.dialog(const UniversityPage(), useSafeArea: false);
    } while (university == null);

    settings.university.value = university;
    isar.writeTxnSync(() {
      isar.settings.putSync(settings);
      settings.university.saveSync();
    });

    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
      useSafeArea: false,
    );

    if (!await UniversityCaching.cacheGroups(university)) {
      Get.back();
      Get.snackbar('error'.tr, 'failed_to_load_groups'.tr);
      return;
    }
    Get.back();

    do {
      group = await Get.dialog(
        const GroupsPage(isSettings: false),
        useSafeArea: false,
      );
    } while (group == null);

    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
      useSafeArea: false,
    );

    group = await UniversityCaching.cacheGroupSchedule(university, group);
    Get.back();

    await _saveSettingsAndNavigate(group, university);
  }

  Future<void> _saveSettingsAndNavigate(
    GroupSchedule? group,
    University? university,
  ) async {
    settings.group.value = group;
    isar.writeTxnSync(() {
      isar.groupSchedules.putSync(group!);
      group.university.saveSync();
      isar.settings.putSync(settings);
      settings.group.saveSync();
    });
    Get.offAll(() => const HomePage());
  }
}
