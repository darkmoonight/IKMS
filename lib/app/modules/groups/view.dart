import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:project_cdis/app/api/donstu/caching.dart';
import 'package:project_cdis/app/data/schema.dart';
import 'package:project_cdis/app/modules/raspGroups/view.dart';
import 'package:project_cdis/app/widgets/selection_list.dart';
import 'package:project_cdis/main.dart';

class GroupsPage extends StatefulWidget {
  final bool isSettings;

  const GroupsPage({super.key, required this.isSettings});

  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  late List<GroupSchedule> groups;
  List<GroupSchedule>? groupsFiltered;
  final isDialog = Get.isDialogOpen ?? false;
  var isLoaded = false;

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    groups = await DonstuCaching.cacheGroups()
        ? await donstu.groups.filter().sortByLastUpdateDesc().findAll()
        : donstu.groups.where((e) => e.schedules.isNotEmpty).toList();
    applyFilter('');
    setState(() {
      isLoaded = true;
    });
  }

  applyFilter(String value) {
    value = value.toLowerCase();
    setState(
      () {
        groupsFiltered = groups.where((element) {
          var groupsTitle = element.name.toLowerCase();
          return groupsTitle.isNotEmpty && groupsTitle.contains(value);
        }).toList();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      body: SelectionList(
        headerText: 'groups'.tr,
        hintText: 'groupsName'.tr,
        onTextChanged: applyFilter,
        isLoaded: isLoaded,
        selectionTextStyle: widget.isSettings
            ? context.theme.textTheme.headline6
            : context.theme.primaryTextTheme.headline4,
        onBackPressed: widget.isSettings ? Get.back : null,
        filteredData: groupsFiltered,
        onEntrySelected: (GroupSchedule selectionData) =>
            widget.isSettings || isDialog
                ? Get.back(result: selectionData)
                : Get.to(() => RaspGroupsPage(groupSchedule: selectionData),
                    transition: Transition.downToUp),
      ),
    );
  }
}
