import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SelectionList(
        headerText: AppLocalizations.of(context)!.universities,
        hintText: AppLocalizations.of(context)!.universitiesName,
        isLoaded: isLoaded,
        onEntrySelected: (SelectionData selectionData) {
          Get.back(result: selectionData);
        },
        selectionTextStyle: Theme.of(context).textTheme.headline6,
        onBackPressed: () {
          Get.back();
        },
        filteredData: data,
      ),
    );
  }
}
