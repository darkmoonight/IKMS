import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:project_cdis/app/data/groups.dart';

import '../../services/remote_services.dart';

class GroupsPage extends StatefulWidget {
  const GroupsPage({super.key});

  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
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
                  ),
                  SizedBox(
                    width: 5.w,
                  ),
                  Text(
                    AppLocalizations.of(context)!.groups,
                    style: theme.textTheme.headline2,
                    textAlign: TextAlign.center,
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
                  prefixIcon: InkWell(
                    onTap: () async {},
                    child: const Icon(
                      Icons.search_outlined,
                      color: Colors.grey,
                    ),
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
                  hintText: AppLocalizations.of(context)!.groupsName,
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
              child: FutureBuilder<List<Groups>>(
                future: RomoteServise().getGroupsData(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  } else {
                    return ListView.builder(
                      itemCount: snapshot.data?.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.w, vertical: 5.w),
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
                                snapshot.data![index].name,
                                style: theme.textTheme.headline6,
                              )),
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
