import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_cdis/app/data/schema.dart';
import 'package:project_cdis/app/api/donstu.dart';
import 'package:project_cdis/app/widgets/rasp_widget.dart';
import 'package:project_cdis/main.dart';

class MySchedulePage extends StatefulWidget {
  const MySchedulePage({super.key});

  @override
  State<MySchedulePage> createState() => _MySchedulePageState();
}

class _MySchedulePageState extends State<MySchedulePage> {
  var isLoaded = false;
  ValueNotifier<List<Schedule>> raspData = ValueNotifier(<Schedule>[]);
  GroupSchedule? oldValue;

  @override
  void initState() {
    super.initState();
    oldValue = settings.group.value;
    isar.settings.watchLazy().listen((_) {
      if (oldValue != settings.group.value) {
        oldValue = settings.group.value;
        getData();
      }
    });
    getData();
  }

  getData() async {
    final t = settings.group.value;
    if (t != null) {
      final l = t.schedules.toList();
      if (l.isNotEmpty) {
        setState(() {
          raspData.value = l;
          isLoaded = true;
        });
      }
    }
    try {
      final l = await DonstuAPI().getRaspsGroupElementData(t?.id);

      await isar.writeTxn(() async {
        if (t != null) {
          await isar.schedules
              .deleteAll(t.schedules.map((schedule) => schedule.id).toList());
          t.schedules.addAll(l);
        }
        await isar.schedules.putAll(l);
        await t?.schedules.save();
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
    return RaspWidget(
      isLoaded: isLoaded,
      raspElements: raspData,
    );
  }
}
