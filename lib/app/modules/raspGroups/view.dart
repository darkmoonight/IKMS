import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_cdis/app/data/schema.dart';
import 'package:project_cdis/app/api/donstu.dart';
import 'package:project_cdis/app/widgets/rasp_widget.dart';
import 'package:project_cdis/main.dart';

class RaspGroupsPage extends StatefulWidget {
  final GroupSchedule groupSchedule;

  const RaspGroupsPage({super.key, required this.groupSchedule});

  @override
  State<RaspGroupsPage> createState() => _RaspGroupsPageState();
}

class _RaspGroupsPageState extends State<RaspGroupsPage> {
  var isLoaded = false;
  ValueNotifier<List<Schedule>> raspData = ValueNotifier(<Schedule>[]);

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    final t = widget.groupSchedule;
    await isar.writeTxn(() async {
      await isar.groupSchedules.put(t);
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
      final l = await DonstuAPI().getRaspsGroupElementData(t.id);

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
        headerText: widget.groupSchedule.name,
      ),
    );
  }
}
