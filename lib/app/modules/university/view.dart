import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';

class UniversityPage extends StatefulWidget {
  const UniversityPage({super.key});

  @override
  State<UniversityPage> createState() => _UniversityPageState();
}

class _UniversityPageState extends State<UniversityPage> {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 15.w, left: 10.w),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Get.back();
                    },
                    icon: const Icon(Icons.arrow_back),
                    iconSize: theme.iconTheme.size,
                    color: theme.iconTheme.color,
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                  ),
                  SizedBox(
                    width: 5.w,
                  ),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.universities,
                      style: theme.textTheme.headline2,
                      overflow: TextOverflow.fade,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.w),
              child: TextField(
                style: theme.textTheme.headline6,
                decoration: InputDecoration(
                  fillColor: theme.primaryColor,
                  filled: true,
                  prefixIcon: const Icon(
                    Icons.search_outlined,
                    color: Colors.grey,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    borderSide: BorderSide(
                      color: theme.primaryColor,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    borderSide: BorderSide(
                      color: theme.primaryColor,
                    ),
                  ),
                  hintText: AppLocalizations.of(context)!.universitiesName,
                  hintStyle: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 15.sp,
                  ),
                ),
                autofocus: false,
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
              child: ListView(
                children: [
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.w),
                    child: Container(
                      height: 40.w,
                      decoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(15)),
                          color: theme.primaryColor),
                      child: TextButton(
                        onPressed: () {
                          Get.back();
                        },
                        child: Center(
                          child: Text(
                            'ДГТУ',
                            style: theme.textTheme.headline6,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
