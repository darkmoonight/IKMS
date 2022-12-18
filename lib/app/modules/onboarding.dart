import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ikms/app/api/donstu/caching.dart';
import 'package:ikms/app/data/schema.dart';
import 'package:ikms/app/modules/groups.dart';
import 'package:ikms/app/modules/home.dart';
import 'package:ikms/app/modules/university.dart';
import 'package:ikms/app/widgets/button.dart';
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
      body: Column(
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
                  style: context.theme.textTheme.headline1,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Text(
                    'sched_hint'.tr,
                    style: context.theme.primaryTextTheme.headline4,
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
              onTap: () async {
                University? university;
                GroupSchedule? group;
                do {
                  university = await Get.dialog(
                    const UniversityPage(),
                  );
                } while (university == null);

                if (university.id == donstu.id) {
                  Get.dialog(
                    const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                  if (!await DonstuCaching.cacheGroups()) return;
                }

                do {
                  group = await Get.dialog(
                    const GroupsPage(
                      isSettings: false,
                    ),
                  );
                } while (group == null);

                settings.university.value = university;
                settings.group.value = group;

                await isar.writeTxn(() async {
                  await isar.groupSchedules.put(group!);
                  await group.university.save();
                  await isar.settings.put(settings);
                  await settings.group.save();
                  await settings.university.save();
                });

                Get.offAll(() => const HomePage());
              },
              bgColor: context.theme.primaryColor,
              textColor: context.theme.dividerColor,
            ),
          ),
        ],
      ),
    );
  }
}
