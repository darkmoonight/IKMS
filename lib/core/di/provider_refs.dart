import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:ikms/core/bootstrap/app_bootstrap.dart';
import 'package:ikms/core/di/settings_revision.dart';
import 'package:ikms/data/models/db.dart';
import 'package:ikms/data/repositories/schedule_repository.dart';
import 'package:ikms/data/repositories/settings_repository.dart';
import 'package:ikms/data/repositories/todos_repository.dart';

/// Riverpod providers for bootstrap state, services, and repositories.

/// Provides the app bootstrap container; must be overridden at startup.
final bootstrapProvider = Provider<AppBootstrap>((ref) {
  throw UnimplementedError('bootstrapProvider must be overridden');
});

/// Provides the shared [Isar] database from [bootstrapProvider].
final isarProvider = Provider<Isar>((ref) => ref.watch(bootstrapProvider).isar);

/// Provides persisted [Settings], refreshing when [settingsRevisionProvider] changes.
final settingsProvider = Provider<Settings>((ref) {
  ref.watch(settingsRevisionProvider);
  return ref.watch(bootstrapProvider).settings;
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

/// Settings persistence with revision bump on save.
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(
    ref.watch(isarProvider),
    onSaved: () => notifySettingsChanged(ref),
  );
});

/// Schedule cache repository.
final scheduleRepositoryProvider = Provider<ScheduleRepository>((ref) {
  return ScheduleRepository(
    ref.watch(isarProvider),
    onSelectedGroupCleared: () async {
      await ref
          .read(settingsRepositoryProvider)
          .clearGroup(ref.read(bootstrapProvider).settings);
    },
  );
});

/// Todos persistence repository.
final todosRepositoryProvider = Provider<TodosRepository>((ref) {
  return TodosRepository(ref.watch(isarProvider));
});
