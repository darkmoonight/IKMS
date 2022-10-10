import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:project_cdis/app/data/shedule.dart';
import 'package:project_cdis/app/services/remote_services.dart';
import 'package:project_cdis/app/widgets/rasp_widget.dart';

class MySchedulePage extends StatefulWidget {
  final int? groupId;

  const MySchedulePage({super.key, required this.groupId});

  @override
  State<MySchedulePage> createState() => _MySchedulePageState();
}

class _MySchedulePageState extends State<MySchedulePage> {
  var isLoaded = false;
  ValueNotifier<List<RaspData>> raspData = ValueNotifier(<RaspData>[]);

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    final raspElements =
        await RomoteServise().getRaspsElementData(widget.groupId);
    setState(() {
      raspData.value = raspElements
          .map((RaspElement element) => RaspData(
              discipline: element.discipline,
              teacher: element.teacher,
              audience: element.audience,
              date: DateFormat("yyyy-MM-ddThh:mm:ss").parseUTC(element.date),
              beginning: element.beginning,
              end: element.end))
          .toList();
      isLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final squareWidth = Get.width;
    return RaspWidget(
      squareWidth: squareWidth,
      isLoaded: isLoaded,
      raspElements: raspData,
    );
  }
}
