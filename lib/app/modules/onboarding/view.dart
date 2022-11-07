import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:project_cdis/app/api/donstu/caching.dart';
import 'package:project_cdis/app/data/schema.dart';
import 'package:project_cdis/app/modules/groups/view.dart';
import 'package:project_cdis/app/modules/home/view.dart';
import 'package:project_cdis/app/modules/university/view.dart';
import 'package:project_cdis/main.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/onboard.png',
              scale: 1,
            ),
            Flexible(
              child: SizedBox(
                height: 10.w,
              ),
            ),
            Text(
              'timetable'.tr,
              style: context.theme.textTheme.headline1,
              textAlign: TextAlign.center,
            ),
            Flexible(
              child: SizedBox(
                height: 10.w,
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width - 20,
              child: Text(
                'sched_hint'.tr,
                style: context.theme.textTheme.headline3,
                textAlign: TextAlign.center,
              ),
            ),
            Flexible(
              child: SizedBox(
                height: 20.w,
              ),
            ),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all(context.theme.primaryColor),
                minimumSize: MaterialStateProperty.all(const Size(130, 45)),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              onPressed: () async {
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

                Get.off(() => const HomePage());
              },
              child: Text(
                'get_started'.tr,
                style: context.theme.textTheme.headline5,
              ),
            )
          ],
        ),
      ),
    );
  }
}
