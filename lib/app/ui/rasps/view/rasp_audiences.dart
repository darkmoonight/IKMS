import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ikms/app/api/donstu/caching.dart';
import 'package:ikms/app/data/db.dart';
import 'package:ikms/app/ui/rasps/widgets/rasp_widget.dart';

class RaspAudiencesPage extends StatefulWidget {
  const RaspAudiencesPage({
    super.key,
    required this.audienceSchedule,
  });
  final AudienceSchedule audienceSchedule;

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
      body: RefreshIndicator(
        onRefresh: () async {
          await getData();
        },
        child: RaspWidget(
          isLoaded: isLoaded,
          raspElements: raspData,
          onBackPressed: () {
            Get.back();
          },
          headerText: widget.audienceSchedule.name,
        ),
      ),
    );
  }
}
