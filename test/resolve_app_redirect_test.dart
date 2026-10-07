import 'package:flutter_test/flutter_test.dart';
import 'package:ikms/core/navigation/app_routes.dart';
import 'package:ikms/core/navigation/app_router.dart';
import 'package:ikms/data/models/db.dart';

void main() {
  test('resolveAppRedirect sends incomplete setup to onboarding', () {
    final settings = Settings();
    expect(resolveAppRedirect(settings, AppRoutes.home), AppRoutes.onboarding);
  });

  test('resolveAppRedirect keeps completed setup on home', () {
    final settings = Settings()
      ..university.value = University(id: 1, name: 'Test')
      ..group.value = GroupSchedule(id: 1, name: 'A');
    expect(resolveAppRedirect(settings, AppRoutes.home), isNull);
    expect(resolveAppRedirect(settings, AppRoutes.onboarding), AppRoutes.home);
  });

  test(
    'resolveAppRedirect sends to onboarding when group cleared after migrate',
    () {
      final settings = Settings()
        ..university.value = University(id: 1, name: 'Test');
      expect(
        resolveAppRedirect(settings, AppRoutes.home),
        AppRoutes.onboarding,
      );
    },
  );
}
