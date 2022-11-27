import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:ikms/app/api/donstu/caching.dart';
import 'package:ikms/app/data/schema.dart';
import 'package:ikms/app/modules/raspGroups/view.dart';
import 'package:ikms/app/widgets/selection_list.dart';
import 'package:ikms/main.dart';

class GroupsPage extends StatefulWidget {
  final bool isSettings;

  const GroupsPage({super.key, required this.isSettings});

  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  List<GroupSchedule> groups = List.empty();
  String filter = '';
  final isDialog = Get.isDialogOpen ?? false;
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

  Future<List<GroupSchedule>> get getData async {
    return await isDeviceConnectedNotifier.value &&
            await DonstuCaching.cacheGroups()
        ? await donstu.groups.filter().sortByLastUpdateDesc().findAll()
        : donstu.groups.where((e) => e.schedules.isNotEmpty).toList();
  }

  applyFilter(String value) async {
    filter = value.toLowerCase();
    final data = (await getData).where((element) {
      var groupsTitle = element.name.toLowerCase();
      return groupsTitle.isNotEmpty && groupsTitle.contains(filter);
    }).toList();
    setState(
      () {
        groups = data;
        isLoaded = true;
      },
    );
  }

  reApplyFilter() {
    applyFilter(filter);
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
          data: groups,
          onEntrySelected: (GroupSchedule selectionData) async {
            if (widget.isSettings || isDialog) {
              Get.back(result: selectionData);
            } else {
              await Get.to(() => RaspGroupsPage(groupSchedule: selectionData),
                  transition: Transition.downToUp);
              reApplyFilter();
            }
          }),
    );
  }
}
