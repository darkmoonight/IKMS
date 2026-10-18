import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ikms/core/di/provider_refs.dart';
import 'package:ikms/core/utils/show_snack_bar.dart';
import 'package:ikms/i18n/tr.dart';

/// Whether ads are disabled (`true` = ads off).
final adsNotifierProvider = NotifierProvider<AdsNotifier, bool>(
  AdsNotifier.new,
);

/// Persists the ads-disabled preference.
class AdsNotifier extends Notifier<bool> {
  @override
  bool build() => ref.watch(settingsProvider).ads ?? false;

  /// Toggles ads and persists the setting (save-first, then update state).
  Future<void> toggleAds(bool value) async {
    final previous = state;
    final settings = ref.read(settingsProvider);
    settings.ads = value;
    try {
      await ref.read(settingsRepositoryProvider).save(settings);
      state = value;
    } catch (_) {
      settings.ads = previous;
      state = previous;
      showSnackBar('errorOccurred'.tr, isError: true);
    }
  }
}
