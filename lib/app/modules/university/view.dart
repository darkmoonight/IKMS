import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:project_cdis/app/data/schema.dart';
import 'package:project_cdis/app/widgets/selection_list.dart';
import 'package:project_cdis/main.dart';

class UniversityPage extends StatefulWidget {
  const UniversityPage({super.key});

  @override
  State<UniversityPage> createState() => _UniversityPageState();
}

class _UniversityPageState extends State<UniversityPage> {
  var isLoaded = true;
  final data = isar.universitys.where().findAllSync();
  final isDialog = Get.isDialogOpen ?? false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      body: SelectionList(
        headerText: 'universities'.tr,
        hintText: 'universitiesName'.tr,
        isLoaded: isLoaded,
        onEntrySelected: (University selectionData) =>
            Get.back(result: selectionData),
        selectionTextStyle: context.theme.textTheme.headline6,
        onBackPressed: isDialog ? null : Get.back,
        filteredData: data,
      ),
    );
  }
}
