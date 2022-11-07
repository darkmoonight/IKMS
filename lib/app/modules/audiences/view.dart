import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:project_cdis/app/api/donstu/caching.dart';
import 'package:project_cdis/app/data/schema.dart';
import 'package:project_cdis/app/modules/raspAudiences/view.dart';
import 'package:project_cdis/app/widgets/selection_list.dart';
import 'package:project_cdis/main.dart';

class AudiencesPage extends StatefulWidget {
  const AudiencesPage({super.key});

  @override
  State<AudiencesPage> createState() => _AudiencesPageState();
}

class _AudiencesPageState extends State<AudiencesPage> {
  late List<AudienceSchedule> audiences;
  List<AudienceSchedule>? audiencesFiltered;
  var isLoaded = false;

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    audiences = await DonstuCaching.cacheAudiences()
        ? await donstu.audiences.filter().sortByLastUpdateDesc().findAll()
        : donstu.audiences.where((e) => e.schedules.isNotEmpty).toList();
    applyFilter('');
    setState(() {
      isLoaded = true;
    });
  }

  applyFilter(String value) {
    value = value.toLowerCase();
    setState(
      () {
        audiencesFiltered = audiences.where((element) {
          var audiencesTitle = element.name.toLowerCase();
          return audiencesTitle.isNotEmpty && audiencesTitle.contains(value);
        }).toList();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SelectionList(
      headerText: 'audiences'.tr,
      hintText: 'number'.tr,
      onTextChanged: applyFilter,
      isLoaded: isLoaded,
      selectionTextStyle: context.theme.primaryTextTheme.headline4,
      filteredData: audiencesFiltered,
      onEntrySelected: (AudienceSchedule selectionData) {
        Get.to(() => RaspAudiencesPage(audienceSchedule: selectionData),
            transition: Transition.downToUp);
      },
    );
  }
}
