import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_cdis/app/data/schema.dart';
import 'package:project_cdis/app/api/donstu.dart';
import 'package:project_cdis/app/widgets/rasp_widget.dart';

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
    raspData.value =
        await DonstuAPI().getRaspsAudElementData(widget.audienceSchedule.id);
    setState(
      () {
        isLoaded = true;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final squareWidth = Get.width;
    return Scaffold(
      body: RaspWidget(
        squareWidth: squareWidth,
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
