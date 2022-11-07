import 'package:flutter/material.dart';
import 'package:project_cdis/app/api/donstu/caching.dart';
import 'package:project_cdis/app/data/schema.dart';
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
    final g = settings.group.value;
    if (g != null) {
      final t = await DonstuCaching.cacheGroupSchedule(g);
      if (t.schedules.isNotEmpty) {
        setState(() {
          raspData.value = t.schedules.toList();
          isLoaded = true;
        });
      }
    } else {
      setState(() {
        isLoaded = true;
      });
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
