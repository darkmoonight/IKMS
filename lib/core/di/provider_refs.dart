import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:ikms/core/bootstrap/app_bootstrap.dart';
import 'package:ikms/core/di/settings_revision.dart';
import 'package:ikms/data/mappers/preferences_mapper.dart';
import 'package:ikms/data/repositories/isar_preferences_repository.dart';
import 'package:ikms/data/repositories/isar_schedule_cache_port.dart';
import 'package:ikms/data/repositories/schedule_repository.dart';
import 'package:ikms/data/repositories/settings_repository.dart';
import 'package:ikms/data/repositories/todos_repository.dart';
import 'package:ikms/domain/entities/app_preferences.dart';
import 'package:ikms/domain/repositories/preferences_repository.dart';
import 'package:ikms/domain/repositories/schedule_cache_port.dart';
import 'package:ikms/domain/repositories/todo_repository.dart';

/// Riverpod providers for bootstrap state, services, and repositories.

/// Provides the app bootstrap container; must be overridden at startup.
final bootstrapProvider = Provider<AppBootstrap>((ref) {
  throw UnimplementedError('bootstrapProvider must be overridden');
});

/// Provides the shared [Isar] database from [bootstrapProvider].
final isarProvider = Provider<Isar>((ref) => ref.watch(bootstrapProvider).isar);

/// Domain preferences snapshot; refreshes on [settingsRevisionProvider].
final preferencesProvider = Provider<AppPreferences>((ref) {
  ref.watch(settingsRevisionProvider);
  final settings = ref.watch(bootstrapProvider).settings;
  return preferencesFromSettings(settings);
});

/// Shared local notifications plugin.
final notificationsPluginProvider = Provider<FlutterLocalNotificationsPlugin>(
  (ref) => ref.watch(bootstrapProvider).notificationsPlugin,
);

/// Installed app version from the platform package info.
final appVersionProvider = FutureProvider<String>((ref) async {
  final packageInfo = await PackageInfo.fromPlatform();
  return packageInfo.version;
});

/// Low-level Settings persistence with revision bump on save.
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(
    ref.watch(isarProvider),
    onSaved: () => notifySettingsChanged(ref),
  );
});

/// Domain preferences port.
final preferencesRepositoryProvider = Provider<PreferencesRepository>((ref) {
  return IsarPreferencesRepository(
    settings: ref.watch(bootstrapProvider).settings,
    settingsRepository: ref.watch(settingsRepositoryProvider),
    isar: ref.watch(isarProvider),
  );
});

/// Low-level Isar schedule cache (tests / internal).
final scheduleRepositoryProvider = Provider<ScheduleRepository>((ref) {
  return ScheduleRepository(
    ref.watch(isarProvider),
    onSelectedGroupCleared: () async {
      await ref.read(preferencesRepositoryProvider).clearGroup();
    },
  );
});

/// Domain schedule cache port.
final scheduleCachePortProvider = Provider<ScheduleCachePort>((ref) {
  return IsarScheduleCachePort(
    ref.watch(isarProvider),
    ref.watch(scheduleRepositoryProvider),
    selectedGroupId: () => ref.read(preferencesProvider).group?.id,
    selectedUniversityId: () => ref.read(preferencesProvider).university?.id,
  );
});

/// Tasks persistence repository (Isar concrete; also bound as [TodoRepository]).
final todosRepositoryProvider = Provider<TodosRepository>((ref) {
  return TodosRepository(ref.watch(isarProvider));
});

/// Domain task port.
final todoRepositoryProvider = Provider<TodoRepository>(
  (ref) => ref.watch(todosRepositoryProvider),
);
