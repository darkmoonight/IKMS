import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:isar_community/isar.dart';
import 'package:ikms/data/models/db.dart';

/// Immutable startup context created during app initialization.
class AppBootstrap {
  const AppBootstrap({
    required this.isar,
    required this.settings,
    required this.notificationsPlugin,
  });

  /// Local database opened before the first frame.
  final Isar isar;

  /// Persisted user settings loaded at startup.
  final Settings settings;

  /// Shared local notifications plugin instance.
  final FlutterLocalNotificationsPlugin notificationsPlugin;
}
