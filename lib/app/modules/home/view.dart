import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
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
  DateTime now = DateTime.now();
  DatePickerController datePickerController = DatePickerController();
  // ignore: prefer_typing_uninitialized_variables
  DateTime? selectedDay;
  Rasp? raspElement;
  var isLoaded = false;
  String? dateNow;

  @override
  void initState() {
    super.initState();
    selectedDay = DateTime(now.year, now.month, now.day);
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
    final squareWidth = Get.width;
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
                  selectedTextColor: theme.dividerColor,
                  normalTextColor: theme.disabledColor,
                  startDate: DateTime(2022, 09, 01),
                  endDate: DateTime(2100, 09, 01),
                  selectedDate: selectedDay!,
                  widgetWidth: MediaQuery.of(context).size.width,
                  datePickerController: datePickerController,
                  onValueSelected: (date) {
                    selectedDay = date;
                  },
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
                  itemCount: raspElement?.data.rasp.length,
                  itemBuilder: (BuildContext context, int index) {
                    final raspElementPage = raspElement?.data.rasp[index];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                            '${raspElementPage!.beginning}-${raspElementPage.end}'),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.w, vertical: 5.w),
                          child: Container(
                            height: 100.w,
                            width: squareWidth,
                            decoration: BoxDecoration(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(15)),
                                color: theme.primaryColor),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 2.w),
                                  child: Text(raspElementPage.discipline,
                                      style: theme.textTheme.headline6),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 2.w),
                                  child: Text(raspElementPage.teacher,
                                      style: theme.textTheme.subtitle1),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 2.w),
                                  child: Text(raspElementPage.audience,
                                      style: theme.textTheme.subtitle1),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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
