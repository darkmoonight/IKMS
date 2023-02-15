import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:ikms/app/api/donstu/caching.dart';
import 'package:ikms/app/data/schema.dart';
import 'package:ikms/app/widgets/rasp_widget.dart';

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
    } else {
      EasyLoading.showInfo('no_internet'.tr);
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
          headerText: widget.groupSchedule.name,
        ),
      ),
    );
  }
}
