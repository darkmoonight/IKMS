import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:project_cdis/app/modules/university/view.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/onboard.png',
              scale: 1,
            ),
            Flexible(
              child: SizedBox(
                height: 10.w,
              ),
            ),
            Text(
              'Расписание занятий',
              style: Theme.of(context).textTheme.headline1,
              textAlign: TextAlign.center,
            ),
            Flexible(
              child: SizedBox(
                height: 10.w,
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width - 20,
              child: Text(
                'В нашем приложении вы сможете посмотреть свое расписание, а также расписание преподавателей, аудиторий и других групп.',
                style: Theme.of(context).textTheme.headline3,
                textAlign: TextAlign.center,
              ),
            ),
            Flexible(
              child: SizedBox(
                height: 20.w,
              ),
            ),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all(Theme.of(context).primaryColor),
                minimumSize: MaterialStateProperty.all(const Size(130, 45)),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              onPressed: () async {
                Get.to(
                    () => const UniversityPage(
                          isOnBoard: true,
                        ),
                    transition: Transition.downToUp);
              },
              child: Text(
                'Начать',
                style: Theme.of(context).textTheme.headline5,
              ),
            )
          ],
        ),
      ),
    );
  }
}
