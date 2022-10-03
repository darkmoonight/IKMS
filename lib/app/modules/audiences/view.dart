import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:project_cdis/app/data/audiences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:project_cdis/app/modules/raspAudiences/view.dart';
import '../../services/remote_services.dart';

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
    var theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 15.w),
              child: Text(
                AppLocalizations.of(context)!.audiences,
                style: theme.textTheme.headline2,
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.w),
              child: TextField(
                onChanged: applyFilter,
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
                  hintText: AppLocalizations.of(context)!.number,
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
              child: Visibility(
                visible: isLoaded,
                replacement: const Center(
                  child: CircularProgressIndicator(),
                ),
                child: ListView.builder(
                  itemCount: audiencesFiltered?.length,
                  itemBuilder: (BuildContext context, int index) {
                    final audiencePage = audiencesFiltered![index];
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
                          onPressed: () {
                            Get.to(
                                () => RaspAudiencesPage(
                                    id: audiencePage.id,
                                    name: audiencePage.name),
                                transition: Transition.downToUp);
                          },
                          child: Center(
                            child: Text(
                              audiencePage.name,
                              style: theme.primaryTextTheme.headline4,
                              textAlign: TextAlign.center,
                            ),
                          ),
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
