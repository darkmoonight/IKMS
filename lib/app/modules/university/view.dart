import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:project_cdis/app/data/schema.dart';
import 'package:project_cdis/app/modules/groups/view.dart';
import 'package:project_cdis/app/widgets/selection_list.dart';
import 'package:project_cdis/main.dart';

class UniversityPage extends StatefulWidget {
  final bool isOnBoard;

  const UniversityPage({super.key, required this.isOnBoard});

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

  isSettings(University selectionData) {
    Get.back(result: selectionData);
  }

  isOnboard(University selectionData) async {
    settings.university.value = selectionData;
    await isar.writeTxn(() async {
      await isar.settings.put(settings);
      await settings.university.save();
    });
    setState(() {});
    Get.to(() => const GroupsPage(isSettings: false, isOnBoard: true),
        transition: Transition.downToUp);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SelectionList(
        headerText: AppLocalizations.of(context)!.universities,
        hintText: AppLocalizations.of(context)!.universitiesName,
        isLoaded: isLoaded,
        onEntrySelected: widget.isOnBoard ? isOnboard : isSettings,
        selectionTextStyle: Theme.of(context).textTheme.headline6,
        onBackPressed: widget.isOnBoard ? null : Get.back,
        filteredData: data,
      ),
    );
  }
}
