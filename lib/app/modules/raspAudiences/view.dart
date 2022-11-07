import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_cdis/app/api/donstu/caching.dart';
import 'package:project_cdis/app/data/schema.dart';
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
    final t =
        await DonstuCaching.cacheAudienceSchedule(widget.audienceSchedule);
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
        headerText: widget.audienceSchedule.name,
      ),
    );
  }
}
