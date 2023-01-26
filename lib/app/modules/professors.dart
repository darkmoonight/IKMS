import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:ikms/app/api/donstu/caching.dart';
import 'package:ikms/app/data/schema.dart';
import 'package:ikms/app/modules/rasp_professors.dart';
import 'package:ikms/app/widgets/selection_list.dart';
import 'package:ikms/main.dart';

class ProfessorsPage extends StatefulWidget {
  const ProfessorsPage({super.key});

  @override
  State<ProfessorsPage> createState() => _ProfessorsPageState();
}

class _ProfessorsPageState extends State<ProfessorsPage> {
  List<TeacherSchedule> teachers = List.empty();
  String filter = '';
  var isLoaded = false;

  @override
  void initState() {
    super.initState();
    isDeviceConnectedNotifier.addListener(reApplyFilter);
    applyFilter('');
  }

  @override
  void dispose() {
    isDeviceConnectedNotifier.removeListener(reApplyFilter);
    super.dispose();
  }

  Future<List<TeacherSchedule>> get getData async {
    return await isDeviceConnectedNotifier.value &&
            await DonstuCaching.cacheTeachers()
        ? await donstu.teachers.filter().sortByLastUpdateDesc().findAll()
        : donstu.teachers.where((e) => e.schedules.isNotEmpty).toList();
  }

  applyFilter(String value) async {
    filter = value.toLowerCase();
    final data = (await getData).where((element) {
      var professorsTitle = element.name.toLowerCase();
      return professorsTitle.isNotEmpty && professorsTitle.contains(filter);
    }).toList();
    setState(
      () {
        teachers = data;
        isLoaded = true;
      },
    );
  }

  reApplyFilter() {
    applyFilter(filter);
  }

  @override
  Widget build(BuildContext context) {
    return SelectionList(
      headerText: 'professors'.tr,
      hintText: 'fio'.tr,
      onTextChanged: applyFilter,
      isLoaded: isLoaded,
      selectionTextStyle: context.theme.textTheme.bodyMedium,
      data: teachers,
      onEntrySelected: (TeacherSchedule selectionData) async {
        await Get.to(() => RaspProfessorsPage(teacherSchedule: selectionData),
            transition: Transition.downToUp);
        applyFilter(filter);
      },
    );
  }
}
