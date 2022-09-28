import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:horizontal_center_date_picker/datepicker_controller.dart';
import 'package:horizontal_center_date_picker/horizontal_date_picker.dart';
import 'package:project_cdis/app/data/shedule.dart';

import '../../services/remote_services.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var selectedDay = DateTime.now();
  DatePickerController datePickerController = DatePickerController();

  List<RaspElement>? raspElement;
  var isLoaded = false;

  @override
  void initState() {
    super.initState();

    getData();
  }

  getData() async {
    raspElement = await RomoteServise().getRaspElementData();
    if (raspElement != null) {
      setState(() {
        isLoaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var tag = Localizations.maybeLocaleOf(context)?.toLanguageTag();
    var theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 15.w, bottom: 8.w),
              child: Text(
                AppLocalizations.of(context)!.schedule,
                style: theme.textTheme.headline2,
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 5.w, horizontal: 10.w),
              decoration: BoxDecoration(
                color: theme.primaryColor,
                borderRadius: const BorderRadius.all(Radius.circular(15)),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.w),
                child: HorizontalDatePickerWidget(
                  locale: '$tag',
                  selectedColor: Colors.blue,
                  normalColor: theme.primaryColor,
                  disabledColor: theme.primaryColor,
                  normalTextColor: theme.dividerColor,
                  startDate: DateTime(2022, 09, 01),
                  endDate: DateTime(2100, 09, 01),
                  selectedDate: selectedDay,
                  widgetWidth: MediaQuery.of(context).size.width,
                  datePickerController: datePickerController,
                  onValueSelected: (date) {},
                ),
              ),
            ),
            Divider(
              color: theme.dividerColor,
              height: 20.w,
              thickness: 2,
              indent: 10.w,
              endIndent: 10.w,
            ),
            Expanded(
              child: Visibility(
                visible: isLoaded,
                replacement: const Center(
                  child: CircularProgressIndicator(),
                ),
                child: ListView.builder(
                  itemCount: raspElement?.length,
                  itemBuilder: (BuildContext context, int index) {
                    final raspElementPage = raspElement![index];
                    return Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.w),
                      child: Container(
                        height: 40.w,
                        decoration: BoxDecoration(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(15)),
                            color: theme.primaryColor),
                        child: TextButton(
                          onPressed: () {},
                          child: Center(
                              child: Text(
                            raspElementPage.code.toString(),
                            style: theme.textTheme.headline6,
                          )),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
