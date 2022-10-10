import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:project_cdis/app/data/groups.dart';
import 'package:project_cdis/app/services/remote_services.dart';
import 'package:project_cdis/app/widgets/selection_list.dart';

class GroupsPage extends StatefulWidget {
  const GroupsPage({super.key});

  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  List<Groups>? groups;
  List<Groups>? groupsFiltered;
  var isLoaded = false;

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    groups = await RomoteServise().getGroupsData();
    applyFilter('');
    if (groupsFiltered != null) {
      setState(
        () {
          isLoaded = true;
        },
      );
    }
  }

  applyFilter(String value) {
    value = value.toLowerCase();
    setState(
      () {
        groupsFiltered = groups?.where((element) {
          var groupsTitle = element.name.toLowerCase();
          return groupsTitle.isNotEmpty && groupsTitle.contains(value);
        }).toList();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SelectionList(
        headerText: AppLocalizations.of(context)!.groups,
        hintText: AppLocalizations.of(context)!.groupsName,
        onTextChanged: applyFilter,
        isLoaded: isLoaded,
        selectionTextStyle: Theme.of(context).textTheme.headline6,
        onBackPressed: Get.back,
        filteredData: groupsFiltered
            ?.map(
                (Groups group) => SelectionData(id: group.id, name: group.name))
            .toList(),
        onEntrySelected: (SelectionData selectionData) {
          Get.back(result: selectionData);
        },
      ),
    );
  }
}
