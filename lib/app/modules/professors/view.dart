import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:project_cdis/app/api/donstu/caching.dart';
import 'package:project_cdis/app/data/schema.dart';
import 'package:project_cdis/app/modules/raspProfessors/view.dart';
import 'package:project_cdis/app/widgets/selection_list.dart';
import 'package:project_cdis/main.dart';

class ProfessorsPage extends StatefulWidget {
  const ProfessorsPage({super.key});

  @override
  State<ProfessorsPage> createState() => _ProfessorsPageState();
}

class _ProfessorsPageState extends State<ProfessorsPage> {
  late List<TeacherSchedule> teachers;
  List<TeacherSchedule>? teachersFiltered;
  var isLoaded = false;

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    teachers = await DonstuCaching.cacheTeachers()
        ? await donstu.teachers.filter().sortByLastUpdateDesc().findAll()
        : donstu.teachers.where((e) => e.schedules.isNotEmpty).toList();
    applyFilter('');
    setState(() {
      isLoaded = true;
    });
  }

  applyFilter(String value) {
    value = value.toLowerCase();
    setState(
      () {
        teachersFiltered = teachers.where((element) {
          var professorsTitle = element.name.toLowerCase();
          return professorsTitle.isNotEmpty && professorsTitle.contains(value);
        }).toList();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SelectionList(
      headerText: 'professors'.tr,
      hintText: 'fio'.tr,
      onTextChanged: applyFilter,
      isLoaded: isLoaded,
      selectionTextStyle: context.theme.primaryTextTheme.headline4,
      filteredData: teachersFiltered,
      onEntrySelected: (TeacherSchedule selectionData) {
        Get.to(() => RaspProfessorsPage(teacherSchedule: selectionData),
            transition: Transition.downToUp);
      },
    );
  }
}
