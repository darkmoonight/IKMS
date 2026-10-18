import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ikms/core/di/providers.dart';
import 'package:ikms/core/navigation/app_router.dart';
import 'package:ikms/core/theme/material_ui_dynamic_color_builder.dart';
import 'package:ikms/core/theme/theme.dart';
import 'package:ikms/core/utils/device_info.dart';
import 'package:ikms/core/utils/snackbar_overlay.dart';
import 'package:ikms/i18n/strings.g.dart';

/// Root widget: routing, theming, localization, and global overlays.
class IkmsApp extends ConsumerStatefulWidget {
  const IkmsApp({super.key});

  @override
  ConsumerState<IkmsApp> createState() => _IkmsAppState();
}

class _IkmsAppState extends ConsumerState<IkmsApp> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  /// Builds the themed, localized router app with global overlays.
  @override
  Widget build(BuildContext context) {
    final appSettings = ref.watch(appSettingsProvider);
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(appRouterProvider);
    final edgeToEdgeAvailable = DeviceFeature().isEdgeToEdgeAvailable();

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: MaterialUiDynamicColorBuilder(
        builder: (lightColorScheme, darkColorScheme) {
          final themes = resolveAppThemes(
            materialColor: appSettings.materialColor,
            amoledTheme: appSettings.amoledTheme,
            edgeToEdgeAvailable: edgeToEdgeAvailable,
            lightDynamic: lightColorScheme,
            darkDynamic: darkColorScheme,
          );

          return TranslationProvider(
            child: MaterialApp.router(
              routerConfig: router,
              themeMode: themeMode,
              theme: themes.light,
              darkTheme: themes.dark,
              locale: appSettings.locale,
              supportedLocales: AppLocaleUtils.supportedLocales,
              localizationsDelegates: GlobalMaterialLocalizations.delegates,
              debugShowCheckedModeBanner: false,
              title: 'IKMS',
              builder: (context, child) {
                final content = Stack(
                  children: [?child, const SnackBarOverlayWidget()],
                );
                // Required until google_fonts, shimmer, table_calendar
                // (and similar) migrate off package:flutter/material.dart.
                // ignore: deprecated_member_use
                return MaterialUiCompatibilityBridge(child: content);
              },
            ),
          );
        },
      ),
    );
  }
}
