import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:ikms/app/api/donstu/caching.dart';
import 'package:ikms/app/data/db.dart';
import 'package:ikms/app/ui/selection_list/view/groups.dart';
import 'package:ikms/app/ui/home.dart';
import 'package:ikms/app/ui/selection_list/view/university.dart';
import 'package:ikms/app/ui/widgets/button.dart';
import 'package:ikms/main.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Column(
          children: [
            Flexible(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/onboard.png',
                    scale: 5,
                  ),
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
                buttonName: 'get_started'.tr,
                onPressed: () async {
                  University? university;
                  GroupSchedule? group;
                  do {
                    university = await Get.dialog(
                      const UniversityPage(),
                      useSafeArea: false,
                    );
                  } while (university == null);

                  if (university.id == donstu.id) {
                    Get.dialog(
                      const Center(child: CircularProgressIndicator()),
                      useSafeArea: false,
                    );
                    if (!await DonstuCaching.cacheGroups()) return;
                  }

                  do {
                    group = await Get.dialog(
                      const GroupsPage(isSettings: false),
                      useSafeArea: false,
                    );
                  } while (group == null);

                  settings.university.value = university;
                  settings.group.value = group;

                  isar.writeTxnSync(() {
                    isar.groupSchedules.putSync(group!);
                    group.university.saveSync();
                    isar.settings.putSync(settings);
                    settings.group.saveSync();
                    settings.university.saveSync();
                  });

                  Get.offAll(() => const HomePage());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
