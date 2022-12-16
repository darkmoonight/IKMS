import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ikms/app/modules/audiences/view.dart';
import 'package:ikms/app/modules/groups/view.dart';
import 'package:ikms/app/modules/professors/view.dart';

class SearchBar extends StatelessWidget {
  const SearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: SafeArea(
        child: Column(
          children: [
            TabBar(
              splashFactory: NoSplash.splashFactory,
              overlayColor: MaterialStateProperty.resolveWith<Color?>(
                (Set<MaterialState> states) {
                  return Colors.transparent;
                },
              ),
              indicatorColor: Colors.blueAccent,
              tabs: [
                Tab(
                    text: 'professors'.tr,
                    icon: const Icon(Iconsax.user_search)),
                Tab(text: 'groups'.tr, icon: const Icon(Iconsax.people)),
                Tab(text: 'audiences'.tr, icon: const Icon(Iconsax.buliding)),
              ],
              labelStyle: context.theme.textTheme.headline6,
              labelColor: context.theme.textTheme.headline6?.color,
              unselectedLabelColor:
                  context.theme.primaryTextTheme.subtitle1?.color,
            ),
            const Expanded(
              child: TabBarView(
                children: [
                  ProfessorsPage(),
                  GroupsPage(
                    isSettings: false,
                  ),
                  AudiencesPage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
