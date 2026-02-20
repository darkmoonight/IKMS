import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ikms/app/api/caching.dart';
import 'package:ikms/app/data/db.dart';
import 'package:ikms/app/ui/home.dart';
import 'package:ikms/app/ui/selection_list/view/selection_pages.dart';
import 'package:ikms/app/ui/widgets/button.dart';
import 'package:ikms/app/utils/navigation_helper.dart';
import 'package:ikms/app/utils/responsive_utils.dart';
import 'package:ikms/app/utils/show_snack_bar.dart';
import 'package:ikms/main.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtils.isMobile(context);
    final padding = ResponsiveUtils.getResponsivePadding(context);

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? padding : padding * 2,
          ),
          child: Column(
            children: [
              Flexible(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/images/onboard.png',
                          scale: isMobile ? 5 : 4,
                        ),
                        SizedBox(height: padding * 1.5),
                        Text(
                          'timetable'.tr,
                          style: context.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: ResponsiveUtils.getResponsiveFontSize(
                              context,
                              24,
                            ),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: padding),
                        Text(
                          'sched_hint'.tr,
                          style: context.textTheme.bodyMedium?.copyWith(
                            fontSize: ResponsiveUtils.getResponsiveFontSize(
                              context,
                              15,
                            ),
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Padding(
                  padding: EdgeInsets.all(padding),
                  child: MyTextButton(
                    text: 'get_started'.tr,
                    onPressed: () async => await _handleGetStarted(context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleGetStarted(BuildContext context) async {
    University? university;
    GroupSchedule? group;

    do {
      university = await NavigationHelper.showAppDialog<University>(
        context: context,
        child: const UniversityPage(),
        barrierDismissible: false,
      );
    } while (university == null);

    settings.university.value = university;
    await isar.writeTxn(() async {
      await isar.settings.put(settings);
      await settings.university.save();
    });

    if (!context.mounted) return;
    _showLoadingDialog(context);

    if (!await UniversityCaching.cacheGroups(university)) {
      NavigationHelper.back();
      showSnackBar('failed_to_load_groups'.tr, isError: true);
      return;
    }
    NavigationHelper.back();

    if (!context.mounted) return;
    do {
      group = await NavigationHelper.showAppDialog<GroupSchedule>(
        context: context,
        child: const GroupsPage(isSettings: false),
        barrierDismissible: false,
      );
    } while (group == null);

    if (!context.mounted) return;
    _showLoadingDialog(context);

    group = await UniversityCaching.cacheGroupSchedule(university, group);
    NavigationHelper.back();

    await _saveSettingsAndNavigate(group, university);
  }

  void _showLoadingDialog(BuildContext context) {
    NavigationHelper.showAppDialog(
      context: context,
      child: const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );
  }

  Future<void> _saveSettingsAndNavigate(
    GroupSchedule? group,
    University? university,
  ) async {
    settings.group.value = group;
    await isar.writeTxn(() async {
      await isar.groupSchedules.put(group!);
      await group.university.save();
      await isar.settings.put(settings);
      await settings.group.save();
    });
    Get.offAll(() => const HomePage());
  }
}
