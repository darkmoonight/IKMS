import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_cdis/app/api/donstu/caching.dart';
import 'package:project_cdis/app/data/schema.dart';
import 'package:project_cdis/app/widgets/rasp_widget.dart';

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
    final t = await DonstuCaching.cacheGroupSchedule(widget.groupSchedule);
    if (t.schedules.isNotEmpty) {
      setState(() {
        raspData.value = t.schedules.toList();
        isLoaded = true;
      });
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
