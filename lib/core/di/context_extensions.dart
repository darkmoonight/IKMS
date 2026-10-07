import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:ikms/core/di/provider_refs.dart';
import 'package:ikms/core/services/connectivity_service.dart';
import 'package:ikms/data/models/db.dart';
import 'package:ikms/data/repositories/schedule_repository.dart';
import 'package:ikms/i18n/locale_utils.dart';

/// Convenient reads of Riverpod providers from a [BuildContext].
extension IkmsContextX on BuildContext {
  /// Persisted [Settings] instance from bootstrap.
  Settings get settings =>
      ProviderScope.containerOf(this).read(settingsProvider);

  /// Schedule cache repository.
  ScheduleRepository get scheduleRepository =>
      ProviderScope.containerOf(this).read(scheduleRepositoryProvider);

  /// Online-status notifier.
  ValueNotifier<Future<bool>> get isOnline => ConnectivityService.isOnline;

  /// Active UI locale derived from persisted language settings.
  Locale get appLocale =>
      flutterLocaleOf(appLocaleFromLanguageCode(settings.language));
}
