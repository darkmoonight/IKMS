import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_cdis/app/data/schema.dart';
import 'package:project_cdis/app/api/donstu.dart';
import 'package:project_cdis/app/widgets/rasp_widget.dart';
import 'package:project_cdis/main.dart';

class RaspAudiencesPage extends StatefulWidget {
  final AudienceSchedule audienceSchedule;

  const RaspAudiencesPage({super.key, required this.audienceSchedule});

  @override
  State<RaspAudiencesPage> createState() => _RaspAudiencesPageState();
}

class _RaspAudiencesPageState extends State<RaspAudiencesPage> {
  var isLoaded = false;
  ValueNotifier<List<Schedule>> raspData = ValueNotifier(<Schedule>[]);

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    final t = widget.audienceSchedule;
    await isar.writeTxn(() async {
      await isar.audienceSchedules.put(t);
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
      final l = await DonstuAPI().getRaspsAudElementData(t.id);

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
        headerText: widget.audienceSchedule.name,
      ),
    );
  }
}
