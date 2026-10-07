import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:ikms/core/di/provider_refs.dart';
import 'package:ikms/core/navigation/app_routes.dart';
import 'package:ikms/core/utils/navigation_helper.dart';
import 'package:ikms/core/utils/responsive_utils.dart';
import 'package:ikms/core/utils/show_snack_bar.dart';
import 'package:ikms/core/widgets/button.dart';
import 'package:ikms/data/models/db.dart';
import 'package:ikms/features/selection/presentation/view/selection_pages.dart';
import 'package:ikms/i18n/tr.dart';

/// First-run flow for picking a university and group.
class OnBoardingScreen extends ConsumerWidget {
  /// Creates the onboarding screen.
  const OnBoardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
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
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
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
                    onPressed: () async =>
                        await _handleGetStarted(context, ref),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleGetStarted(BuildContext context, WidgetRef ref) async {
    University? university;
    GroupSchedule? group;
    final settings = ref.read(settingsProvider);
    final settingsRepo = ref.read(settingsRepositoryProvider);
    final scheduleRepo = ref.read(scheduleRepositoryProvider);

    do {
      university = await NavigationHelper.showAppDialog<University>(
        context: context,
        child: const UniversityPage(),
        barrierDismissible: false,
      );
    } while (university == null);

    await settingsRepo.setUniversity(settings, university);

    if (!context.mounted) return;
    _showLoadingDialog(context);

    if (!await scheduleRepo.cacheGroups(university)) {
      if (context.mounted) NavigationHelper.back(context);
      showSnackBar('failed_to_load_groups'.tr, isError: true);
      return;
    }
    if (context.mounted) NavigationHelper.back(context);

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

    group = await scheduleRepo.cacheGroupSchedule(university, group);
    if (!context.mounted) return;
    NavigationHelper.back(context);

    group.university.value = university;
    await settingsRepo.setGroup(settings, group);
    if (context.mounted) {
      context.go(AppRoutes.home);
    }
  }

  void _showLoadingDialog(BuildContext context) {
    NavigationHelper.showAppDialog(
      context: context,
      child: const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );
  }
}
