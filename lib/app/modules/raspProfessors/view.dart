import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_cdis/app/data/schema.dart';
import 'package:project_cdis/app/api/donstu.dart';
import 'package:project_cdis/app/widgets/rasp_widget.dart';
import 'package:project_cdis/main.dart';

class RaspProfessorsPage extends StatefulWidget {
  final TeacherSchedule teacherSchedule;

  const RaspProfessorsPage({super.key, required this.teacherSchedule});

  @override
  State<RaspProfessorsPage> createState() => _RaspProfessorsPageState();
}

class _RaspProfessorsPageState extends State<RaspProfessorsPage> {
  var isLoaded = false;
  ValueNotifier<List<Schedule>> raspData = ValueNotifier(<Schedule>[]);

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    final t = widget.teacherSchedule;
    await isar.writeTxn(() async {
      await isar.teacherSchedules.put(t);
      await t.university.save();
    });
    final l = t.schedules.toList();
    if (l.isNotEmpty) {
      setState(
        () {
          raspData.value = l;
          isLoaded = true;
        },
      );
    }

    try {
      final l = await DonstuAPI().getRaspsProfElementData(t.id);

      await isar.writeTxn(() async {
        await isar.schedules
            .deleteAll(t.schedules.map((schedule) => schedule.id).toList());
        t.schedules.addAll(l);
        await isar.schedules.putAll(l);
        await t.schedules.save();
      });
      setState(() {
        raspData.value = l;
        isLoaded = true;
      });
    } catch (e) {
      Get.showSnackbar(GetSnackBar(
        message: 'no_internet'.tr,
        duration: const Duration(seconds: 3),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RaspWidget(
        isLoaded: isLoaded,
        raspElements: raspData,
        onBackPressed: () {
          Get.back();
        },
        headerText: widget.teacherSchedule.name,
      ),
    );
  }
}
