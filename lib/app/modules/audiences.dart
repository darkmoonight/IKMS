import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:ikms/app/api/donstu/caching.dart';
import 'package:ikms/app/data/schema.dart';
import 'package:ikms/app/modules/rasp_audiences.dart';
import 'package:ikms/app/widgets/selection_list.dart';
import 'package:ikms/main.dart';

class AudiencesPage extends StatefulWidget {
  const AudiencesPage({super.key});

  @override
  State<AudiencesPage> createState() => _AudiencesPageState();
}

class _AudiencesPageState extends State<AudiencesPage> {
  List<AudienceSchedule> audiences = List.empty();
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

  Future<List<AudienceSchedule>> get getData async {
    return await isDeviceConnectedNotifier.value &&
            await DonstuCaching.cacheAudiences()
        ? await donstu.audiences.filter().sortByLastUpdateDesc().findAll()
        : donstu.audiences.where((e) => e.schedules.isNotEmpty).toList();
  }

  applyFilter(String value) async {
    filter = value.toLowerCase();
    final data = (await getData).where((element) {
      var audiencesTitle = element.name.toLowerCase();
      return audiencesTitle.isNotEmpty && audiencesTitle.contains(filter);
    }).toList();
    setState(
      () {
        audiences = data;
        isLoaded = true;
      },
    );
  }

  reApplyFilter() {
    applyFilter(filter);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await applyFilter('');
      },
      child: SelectionList(
        headerText: 'audiences'.tr,
        hintText: 'number'.tr,
        onTextChanged: applyFilter,
        isLoaded: isLoaded,
        selectionTextStyle: context.textTheme.bodyMedium,
        data: audiences,
        onEntrySelected: (AudienceSchedule selectionData) async {
          await Get.to(() => RaspAudiencesPage(audienceSchedule: selectionData),
              transition: Transition.downToUp);
          reApplyFilter();
        },
      ),
    );
  }
}
