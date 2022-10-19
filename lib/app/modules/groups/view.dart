import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:project_cdis/app/data/schema.dart';
import 'package:project_cdis/app/modules/raspGroups/view.dart';
import 'package:project_cdis/app/api/donstu.dart';
import 'package:project_cdis/app/widgets/selection_list.dart';

class GroupsPage extends StatefulWidget {
  final bool isSettings;

  const GroupsPage({super.key, required this.isSettings});

  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  List<GroupSchedule>? groups;
  List<GroupSchedule>? groupsFiltered;
  var isLoaded = false;

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    groups = (await DonstuAPI().getGroupsData());
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
        selectionTextStyle: widget.isSettings
            ? Theme.of(context).textTheme.headline6
            : Theme.of(context).primaryTextTheme.headline4,
        onBackPressed: widget.isSettings ? Get.back : null,
        filteredData: groupsFiltered,
        onEntrySelected: widget.isSettings
            ? (GroupSchedule selectionData) {
                Get.back(result: selectionData);
              }
            : (GroupSchedule selectionData) {
                Get.to(() => RaspGroupsPage(groupSchedule: selectionData),
                    transition: Transition.downToUp);
              },
      ),
    );
  }
}
