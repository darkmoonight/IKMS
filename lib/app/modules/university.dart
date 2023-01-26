import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:ikms/app/data/schema.dart';
import 'package:ikms/app/widgets/selection_list.dart';
import 'package:ikms/main.dart';

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
        selectionTextStyle: context.theme.textTheme.bodyMedium,
        onBackPressed: isDialog ? null : Get.back,
        data: data,
      ),
    );
  }
}
