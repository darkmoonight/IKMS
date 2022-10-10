import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_cdis/app/data/audiences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:project_cdis/app/modules/raspAudiences/view.dart';
import 'package:project_cdis/app/services/remote_services.dart';
import 'package:project_cdis/app/widgets/selection_list.dart';

class AudiencesPage extends StatefulWidget {
  const AudiencesPage({super.key});

  @override
  State<AudiencesPage> createState() => _AudiencesPageState();
}

class _AudiencesPageState extends State<AudiencesPage> {
  List<Audiences>? audiences;
  List<Audiences>? audiencesFiltered;
  var isLoaded = false;

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    audiences = await RomoteServise().getAudiencesData();
    applyFilter('');
    if (audiencesFiltered != null) {
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
        audiencesFiltered = audiences?.where((element) {
          var audiencesTitle = element.name.toLowerCase();
          return audiencesTitle.isNotEmpty && audiencesTitle.contains(value);
        }).toList();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SelectionList(
      headerText: AppLocalizations.of(context)!.audiences,
      hintText: AppLocalizations.of(context)!.number,
      onTextChanged: applyFilter,
      isLoaded: isLoaded,
      selectionTextStyle: Theme.of(context).primaryTextTheme.headline4,
      filteredData: audiencesFiltered
          ?.map((Audiences audience) =>
              SelectionData(id: audience.id, name: audience.name))
          .toList(),
      onEntrySelected: (SelectionData selectionData) {
        Get.to(
            () => RaspAudiencesPage(
                id: selectionData.id, name: selectionData.name),
            transition: Transition.downToUp);
      },
    );
  }
}
