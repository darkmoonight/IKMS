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
    if (settings.group.value != null) {
      final l = settings.group.value?.schedules.toList();
      if (l != null && l.isNotEmpty) {
        setState(() {
          raspData.value = l;
          isLoaded = true;
        });
      }
    }
    try {
      final l = await DonstuAPI().getRaspsElementData(settings.group.value?.id);

      await isar.writeTxn(() async {
        if (settings.group.value != null) {
          await isar.schedules.deleteAll(settings.group.value!.schedules
              .map((schedule) => schedule.id)
              .toList());
          settings.group.value!.schedules.addAll(l);
        }
        await isar.schedules.putAll(l);
        await settings.group.value?.schedules.save();
      });
      setState(() {
        raspData.value = l;
        isLoaded = true;
      });
    } catch (e) {
      Get.showSnackbar(const GetSnackBar(
        message: 'Нет интернета',
        duration: Duration(seconds: 3),
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
