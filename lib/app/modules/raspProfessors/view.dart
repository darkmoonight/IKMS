import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:project_cdis/app/data/shedule.dart';
import 'package:project_cdis/app/services/remote_services.dart';
import 'package:project_cdis/app/widgets/rasp_widget.dart';

class RaspProfessorsPage extends StatefulWidget {
  final int? id;
  final String? name;

  const RaspProfessorsPage({super.key, this.id, this.name});

  @override
  State<RaspProfessorsPage> createState() => _RaspProfessorsPageState();
}

class _RaspProfessorsPageState extends State<RaspProfessorsPage> {
  var isLoaded = false;
  ValueNotifier<List<RaspData>> raspData = ValueNotifier(<RaspData>[]);

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    final raspElements =
        await RomoteServise().getRaspsProfElementData(widget.id);
    setState(
      () {
        raspData.value = raspElements
            .map((RaspElement element) => RaspData(
                discipline: element.discipline,
                teacher: element.teacher,
                audience: element.audience,
                group: element.group,
                numberOfJobs: element.numberOfJobs,
                date: DateFormat("yyyy-MM-ddThh:mm:ss").parseUTC(element.date),
                beginning: element.beginning,
                end: element.end))
            .toList();
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
        headerText: widget.name,
      ),
    );
  }
}
