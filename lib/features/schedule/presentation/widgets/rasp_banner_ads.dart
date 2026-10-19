import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ikms/core/di/providers.dart';
import 'package:material_ui/material_ui.dart';
import 'package:yandex_mobileads/mobile_ads.dart';

/// Inline Yandex banner that follows [adsNotifierProvider].
class RaspBannerAds extends ConsumerStatefulWidget {
  /// Creates the schedule banner host.
  const RaspBannerAds({super.key});

  @override
  ConsumerState<RaspBannerAds> createState() => _RaspBannerAdsState();
}

class _RaspBannerAdsState extends ConsumerState<RaspBannerAds> {
  BannerAd? _bannerAd;
  bool _loading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    unawaited(_ensureBanner());
  }

  @override
  void dispose() {
    final ad = _bannerAd;
    _bannerAd = null;
    unawaited(_safeDestroy(ad));
    super.dispose();
  }

  Future<void> _ensureBanner() async {
    final adsDisabled = ref.read(adsNotifierProvider);
    if (adsDisabled) {
      _releaseBanner();
      return;
    }
    if (_bannerAd != null || _loading) return;

    _loading = true;
    final banner = BannerAd(
      adSize: BannerAdSize.inline(
        width: MediaQuery.sizeOf(context).width.round(),
        maxHeight: 50,
      ),
    );

    // [BannerAd.load] awaits SDK init, then assigns `_widget`. AdWidget must
    // rebuild after that, or the platform view never mounts.
    try {
      await banner.load(const AdRequest(adUnitId: 'R-M-2101511-1'));
    } catch (e) {
      _loading = false;
      if (kDebugMode) {
        debugPrint('BannerAd.load failed: $e');
      }
      await _safeDestroy(banner);
      return;
    }

    if (!mounted || ref.read(adsNotifierProvider)) {
      _loading = false;
      await _safeDestroy(banner);
      return;
    }

    _bannerAd = banner;
    _loading = false;
    setState(() {});
  }

  void _releaseBanner() {
    final ad = _bannerAd;
    if (ad == null) return;
    _bannerAd = null;
    unawaited(_safeDestroy(ad));
  }

  /// SDK [BannerAd.destroy] does not await `invokeMethod`, so failures escape
  /// try/catch unless handled in a zone.
  Future<void> _safeDestroy(BannerAd? ad) async {
    if (ad == null) return;
    await runZonedGuarded(
      () async {
        await ad.destroy();
        await Future<void>.delayed(Duration.zero);
      },
      (Object error, StackTrace stackTrace) {
        if (error is MissingPluginException) return;
        if (kDebugMode) {
          debugPrint('BannerAd.destroy: $error');
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(adsNotifierProvider, (previous, next) {
      if (next) {
        _releaseBanner();
        setState(() {});
      } else {
        unawaited(_ensureBanner());
      }
    });

    final adsDisabled = ref.watch(adsNotifierProvider);
    if (adsDisabled || _bannerAd == null) return const SizedBox.shrink();
    return AdWidget(bannerAd: _bannerAd!);
  }
}
