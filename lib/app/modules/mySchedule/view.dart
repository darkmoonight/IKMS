import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_cdis/app/data/schema.dart';
import 'package:project_cdis/app/api/donstu.dart';
import 'package:project_cdis/app/widgets/rasp_widget.dart';

class MySchedulePage extends StatefulWidget {
  final int? groupId;

  const MySchedulePage({super.key, required this.groupId});

  @override
  State<MySchedulePage> createState() => _MySchedulePageState();
}

class _MySchedulePageState extends State<MySchedulePage> {
  var isLoaded = false;
  ValueNotifier<List<Schedule>> raspData = ValueNotifier(<Schedule>[]);

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    raspData.value = await DonstuAPI().getRaspsElementData(widget.groupId);
    setState(() {
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
