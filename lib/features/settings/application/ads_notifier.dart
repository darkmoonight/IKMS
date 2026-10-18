import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ikms/core/di/provider_refs.dart';
import 'package:ikms/core/settings/settings_controller.dart';

/// Whether ads are disabled (`true` = ads off).
final adsNotifierProvider = NotifierProvider<AdsNotifier, bool>(
  AdsNotifier.new,
);

/// Exposes ads-disabled flag; writes go through [SettingsController].
class AdsNotifier extends Notifier<bool> {
  @override
  bool build() => ref.watch(preferencesProvider).adsDisabled;

  /// Toggles ads and persists via [SettingsController].
  Future<void> toggleAds(bool value) async {
    try {
      await ref.read(settingsControllerProvider).toggleAds(value);
    } catch (_) {
      // Controller already rolled back persistence and showed a snackbar.
    }
  }
}
