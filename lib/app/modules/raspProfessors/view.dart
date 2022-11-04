import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_cdis/app/data/schema.dart';
import 'package:project_cdis/app/api/donstu.dart';
import 'package:project_cdis/app/widgets/rasp_widget.dart';

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
    final raspElements =
        await DonstuAPI().getRaspsProfElementData(widget.teacherSchedule.id);
    setState(
      () {
        raspData.value = raspElements;
        isLoaded = true;
      },
    );
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
