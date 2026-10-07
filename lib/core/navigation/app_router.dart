import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ikms/core/di/provider_refs.dart';
import 'package:ikms/core/di/settings_revision.dart';
import 'package:ikms/core/navigation/app_routes.dart';
import 'package:ikms/core/navigation/route_transitions.dart';
import 'package:ikms/data/models/db.dart';
import 'package:ikms/features/onboarding/presentation/onboarding_screen.dart';
import 'package:ikms/features/shell/presentation/home_screen.dart';

/// Notifier that triggers [appRouterProvider] redirect re-evaluation.
final _routerRefreshProvider = Provider<ValueNotifier<int>>((ref) {
  final notifier = ValueNotifier(0);
  ref.onDispose(notifier.dispose);
  // Settings is a mutable singleton; listen to revision, not object identity.
  ref.listen(settingsRevisionProvider, (_, _) => notifier.value++);
  return notifier;
});

/// App-wide [GoRouter] with onboarding guards.
final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = ref.watch(_routerRefreshProvider);

  return GoRouter(
    refreshListenable: refresh,
    initialLocation: AppRoutes.home,
    redirect: (context, state) {
      final container = ProviderScope.containerOf(context);
      final settings = container.read(settingsProvider);
      return resolveAppRedirect(settings, state.uri.path);
    },
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnBoardingScreen(),
      ),
    ],
  );
});

/// Returns a redirect when university/group setup is incomplete.
String? resolveAppRedirect(Settings settings, String path) {
  final needsSetup =
      settings.university.value == null || settings.group.value == null;
  if (needsSetup) {
    return path == AppRoutes.onboarding ? null : AppRoutes.onboarding;
  }
  if (path == AppRoutes.onboarding) {
    return AppRoutes.home;
  }
  return null;
}

/// Convenience navigation helpers using slide transitions on the root navigator.
extension GoRouterNavigation on BuildContext {
  /// Pushes [page] with a vertical slide transition.
  Future<T?> pushRouteUp<T>(Widget page) =>
      Navigator.of(this)
          .push<T>(slideRoute<T>(child: page, begin: const Offset(0, 1)));
}
