import 'package:flutter_test/flutter_test.dart';
import 'package:ikms/core/navigation/app_routes.dart';
import 'package:ikms/core/navigation/app_router.dart';
import 'package:ikms/domain/entities/app_preferences.dart';
import 'package:ikms/domain/entities/catalog_refs.dart';

void main() {
  test('resolveAppRedirect sends incomplete setup to onboarding', () {
    const preferences = AppPreferences();
    expect(
      resolveAppRedirect(preferences, AppRoutes.home),
      AppRoutes.onboarding,
    );
  });

  test('resolveAppRedirect keeps completed setup on home', () {
    const preferences = AppPreferences(
      university: UniversityRef(id: 1, name: 'Test'),
      group: GroupRef(id: 1, name: 'A', universityId: 1),
    );
    expect(resolveAppRedirect(preferences, AppRoutes.home), isNull);
    expect(
      resolveAppRedirect(preferences, AppRoutes.onboarding),
      AppRoutes.home,
    );
  });

  test(
    'resolveAppRedirect sends to onboarding when group cleared after migrate',
    () {
      const preferences = AppPreferences(
        university: UniversityRef(id: 1, name: 'Test'),
      );
      expect(
        resolveAppRedirect(preferences, AppRoutes.home),
        AppRoutes.onboarding,
      );
    },
  );
}
