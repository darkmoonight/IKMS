import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:project_cdis/app/data/professors.dart';
import 'package:project_cdis/app/data/schema.dart';
import 'package:project_cdis/app/modules/raspProfessors/view.dart';
import 'package:project_cdis/app/widgets/selection_list.dart';
import '../../services/remote_services.dart';

class ProfessorsPage extends StatefulWidget {
  const ProfessorsPage({super.key});

  @override
  State<ProfessorsPage> createState() => _ProfessorsPageState();
}

class _ProfessorsPageState extends State<ProfessorsPage> {
  List<Professors>? professors;
  List<Professors>? professorsFiltered;
  var isLoaded = false;

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    professors = await RomoteServise().getProfessorsData();
    applyFilter('');
    if (professorsFiltered != null) {
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
        professorsFiltered = professors?.where((element) {
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
      filteredData: professorsFiltered
          ?.map((Professors professor) =>
              SelectionData(id: professor.id, name: professor.name))
          .toList(),
      onEntrySelected: (SelectionData selectionData) {
        Get.to(
            () => RaspProfessorsPage(
                id: selectionData.id, name: selectionData.name),
            transition: Transition.downToUp);
      },
    );
  }
}
