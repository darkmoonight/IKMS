import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

final ThemeData baseLigth = ThemeData.light();
final ThemeData baseDark = ThemeData.dark();

class IKMSTheme {
  static ThemeData get lightTheme {
    return baseLigth.copyWith(
      brightness: Brightness.light,
      iconTheme: baseLigth.iconTheme.copyWith(
        color: Colors.black,
        size: 20.sp,
      ),
      dividerColor: Colors.black,
      bottomAppBarColor: const Color.fromARGB(255, 245, 245, 245),
      backgroundColor: Colors.white,
      selectedRowColor: Colors.grey[850],
      primaryColor: const Color.fromARGB(255, 240, 240, 240),
      unselectedWidgetColor: Colors.grey[350],
      scaffoldBackgroundColor: const Color.fromARGB(255, 230, 230, 230),
      textTheme: baseLigth.textTheme.copyWith(
        headline1: TextStyle(
          color: Colors.black,
          fontSize: 22.sp,
          fontWeight: FontWeight.bold,
        ),
        headline2: TextStyle(
          color: Colors.black,
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
        ),
        headline3: TextStyle(color: Colors.black, fontSize: 18.sp),
        headline4: TextStyle(
          color: Colors.black,
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
        ),
        headline5: TextStyle(
          color: Colors.black,
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
        ),
        headline6: TextStyle(
          color: Colors.black,
          fontSize: 16.sp,
        ),
        subtitle1: TextStyle(
          color: Colors.grey[800],
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
        ),
        subtitle2: TextStyle(
          color: Colors.grey[800],
          fontSize: 12.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
      primaryTextTheme: baseLigth.primaryTextTheme.copyWith(
        subtitle1: TextStyle(
          color: Colors.grey[600],
          fontSize: 14.sp,
        ),
        subtitle2: TextStyle(
          color: Colors.grey[600],
          fontSize: 14.sp,
          fontWeight: FontWeight.bold,
        ),
        headline4: TextStyle(
          color: Colors.black,
          fontSize: 15.sp,
        ),
        headline5: TextStyle(
          color: Colors.black,
          fontSize: 17.sp,
        ),
        headline6: TextStyle(
          color: Colors.black,
          fontSize: 12.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return baseDark.copyWith(
      brightness: Brightness.dark,
      iconTheme: baseDark.iconTheme.copyWith(
        color: Colors.white,
        size: 20.sp,
      ),
      dividerColor: Colors.white,
      selectedRowColor: Colors.grey[200],
      primaryColor: const Color.fromARGB(255, 40, 40, 40),
      backgroundColor: Colors.black,
      bottomAppBarColor: const Color.fromARGB(255, 28, 28, 28),
      unselectedWidgetColor: Colors.grey[850],
      scaffoldBackgroundColor: const Color.fromARGB(255, 30, 30, 30),
      textTheme: baseDark.textTheme.copyWith(
        headline1: TextStyle(
          color: Colors.white,
          fontSize: 22.sp,
          fontWeight: FontWeight.bold,
        ),
        headline2: TextStyle(
          color: Colors.white,
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
        ),
        headline3: TextStyle(color: Colors.white, fontSize: 18.sp),
        headline4: TextStyle(
          color: Colors.white,
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
        ),
        headline5: TextStyle(
          color: Colors.white,
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
        ),
        headline6: TextStyle(
          color: Colors.white,
          fontSize: 16.sp,
        ),
        subtitle1: TextStyle(
          color: Colors.grey[300],
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
        ),
        subtitle2: TextStyle(
          color: Colors.grey[300],
          fontSize: 12.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
      primaryTextTheme: baseLigth.primaryTextTheme.copyWith(
        subtitle1: TextStyle(
          color: Colors.grey,
          fontSize: 14.sp,
        ),
        subtitle2: TextStyle(
          color: Colors.grey,
          fontSize: 14.sp,
          fontWeight: FontWeight.bold,
        ),
        headline4: TextStyle(
          color: Colors.white,
          fontSize: 15.sp,
        ),
        headline5: TextStyle(
          color: Colors.white,
          fontSize: 17.sp,
        ),
        headline6: TextStyle(
          color: Colors.white,
          fontSize: 12.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
