import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_cdis/app/data/schema.dart';
import 'package:project_cdis/app/api/donstu.dart';
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
  ValueNotifier<List<Schedule>> raspData = ValueNotifier(<Schedule>[]);

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    final raspElements = await DonstuAPI().getRaspsProfElementData(widget.id);
    setState(
      () {
        raspData.value = raspElements;
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
