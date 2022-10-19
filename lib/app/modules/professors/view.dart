import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:project_cdis/app/data/schema.dart';
import 'package:project_cdis/app/modules/raspProfessors/view.dart';
import 'package:project_cdis/app/api/donstu.dart';
import 'package:project_cdis/app/widgets/selection_list.dart';

class ProfessorsPage extends StatefulWidget {
  const ProfessorsPage({super.key});

  @override
  State<ProfessorsPage> createState() => _ProfessorsPageState();
}

class _ProfessorsPageState extends State<ProfessorsPage> {
  List<TeacherSchedule>? teachers;
  List<TeacherSchedule>? teachersFiltered;
  var isLoaded = false;

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    teachers = (await DonstuAPI().getProfessorsData());
    applyFilter('');
    if (teachersFiltered != null) {
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
        teachersFiltered = teachers?.where((element) {
          var professorsTitle = element.name.toLowerCase();
          return professorsTitle.isNotEmpty && professorsTitle.contains(value);
        }).toList();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SelectionList(
      headerText: AppLocalizations.of(context)!.professors,
      hintText: AppLocalizations.of(context)!.fio,
      onTextChanged: applyFilter,
      isLoaded: isLoaded,
      selectionTextStyle: Theme.of(context).primaryTextTheme.headline4,
      filteredData: teachersFiltered,
      onEntrySelected: (SelectionData selectionData) {
        Get.to(
            () => RaspProfessorsPage(
                id: selectionData.id, name: selectionData.name),
            transition: Transition.downToUp);
      },
    );
  }
}
