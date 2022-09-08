import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var selectedDay = DateTime.now();
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: ListView(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 15.w, bottom: 5.w),
              child: Text(
                'Расписание',
                style: theme.textTheme.headline2,
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 5.w, horizontal: 10.w),
              decoration: BoxDecoration(
                color: theme.primaryColor,
                borderRadius: BorderRadius.all(Radius.circular(15.w)),
              ),
              child: DatePicker(
                selectedDay,
                width: 60,
                height: 85,
                selectionColor: Colors.blue,
                selectedTextColor: Colors.white,
                dayTextStyle: TextStyle(
                    color: theme.textTheme.headline4?.color, fontSize: 12),
                dateTextStyle: TextStyle(
                    color: theme.textTheme.headline4?.color, fontSize: 16),
                monthTextStyle: TextStyle(
                    color: theme.textTheme.headline4?.color, fontSize: 12),
                initialSelectedDate: DateTime.now(),
                locale: "ru_RU",
                onDateChange: (date) {
                  setState(
                    () {},
                  );
                },
              ),
            ),
            Divider(
              color: theme.dividerColor,
              height: 20.w,
              thickness: 2,
              indent: 10.w,
              endIndent: 10.w,
            ),
          ],
        ),
      ),
    );
  }
}
