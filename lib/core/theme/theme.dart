import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_color_utilities/material_color_utilities.dart';

final ThemeData baseLight = ThemeData.light(useMaterial3: true);
final ThemeData baseDark = ThemeData.dark(useMaterial3: true);

/// Default light surface color.
const Color lightColor = Colors.white;

/// Default dark surface color.
const Color darkColor = Color.fromRGBO(30, 30, 30, 1);

/// Pure black surface for AMOLED devices.
const Color oledColor = Colors.black;

/// Seed-based light color scheme when dynamic color is off.
ColorScheme colorSchemeLight = ColorScheme.fromSeed(
  seedColor: Colors.indigo,
  brightness: Brightness.light,
);

/// Seed-based dark color scheme when dynamic color is off.
ColorScheme colorSchemeDark = ColorScheme.fromSeed(
  seedColor: Colors.indigo,
  brightness: Brightness.dark,
);

/// Resolved light/dark [ThemeData] pair for [MaterialApp].
class AppThemes {
  const AppThemes({required this.light, required this.dark});

  final ThemeData light;
  final ThemeData dark;
}

/// Builds light and dark themes from settings and optional dynamic schemes.
AppThemes resolveAppThemes({
  required bool materialColor,
  required bool amoledTheme,
  required bool edgeToEdgeAvailable,
  ColorScheme? lightDynamic,
  ColorScheme? darkDynamic,
}) {
  final lightMaterialTheme = lightTheme(
    lightDynamic?.surface,
    lightDynamic,
    edgeToEdgeAvailable,
  );
  final darkMaterialTheme = darkTheme(
    darkDynamic?.surface,
    darkDynamic,
    edgeToEdgeAvailable,
  );
  final darkMaterialThemeOled = darkTheme(
    oledColor,
    darkDynamic,
    edgeToEdgeAvailable,
  );

  final light = materialColor
      ? lightDynamic != null
            ? lightMaterialTheme
            : lightTheme(lightColor, colorSchemeLight, edgeToEdgeAvailable)
      : lightTheme(lightColor, colorSchemeLight, edgeToEdgeAvailable);

  final dark = amoledTheme
      ? materialColor
            ? darkDynamic != null
                  ? darkMaterialThemeOled
                  : darkTheme(oledColor, colorSchemeDark, edgeToEdgeAvailable)
            : darkTheme(oledColor, colorSchemeDark, edgeToEdgeAvailable)
      : materialColor
      ? darkDynamic != null
            ? darkMaterialTheme
            : darkTheme(darkColor, colorSchemeDark, edgeToEdgeAvailable)
      : darkTheme(darkColor, colorSchemeDark, edgeToEdgeAvailable);

  return AppThemes(light: light, dark: dark);
}

/// Builds the light app theme with optional accent and dynamic color scheme.
ThemeData lightTheme(
  Color? color,
  ColorScheme? colorScheme,
  bool edgeToEdgeAvailable,
) => _buildTheme(
  baseTheme: baseLight,
  brightness: Brightness.light,
  color: color,
  colorScheme: colorScheme,
  edgeToEdgeAvailable: edgeToEdgeAvailable,
);

/// Builds the dark app theme with optional accent and dynamic color scheme.
ThemeData darkTheme(
  Color? color,
  ColorScheme? colorScheme,
  bool edgeToEdgeAvailable,
) => _buildTheme(
  baseTheme: baseDark,
  brightness: Brightness.dark,
  color: color,
  colorScheme: colorScheme,
  edgeToEdgeAvailable: edgeToEdgeAvailable,
);

/// Harmonizes semantic colors toward [scheme.primary] (Material You).
ColorScheme _harmonizeColorScheme(ColorScheme scheme) {
  Color harmonize(Color color) =>
      Color(Blend.harmonize(color.toARGB32(), scheme.primary.toARGB32()));

  return scheme.copyWith(
    error: harmonize(scheme.error),
    onError: harmonize(scheme.onError),
    errorContainer: harmonize(scheme.errorContainer),
    onErrorContainer: harmonize(scheme.onErrorContainer),
  );
}

ThemeData _buildTheme({
  required ThemeData baseTheme,
  required Brightness brightness,
  required Color? color,
  required ColorScheme? colorScheme,
  required bool edgeToEdgeAvailable,
}) {
  final harmonizedColorScheme = colorScheme == null
      ? null
      : _harmonizeColorScheme(
          colorScheme.copyWith(
            brightness: brightness,
            surface: baseTheme.colorScheme.surface,
          ),
        );

  return baseTheme.copyWith(
    brightness: brightness,
    colorScheme: harmonizedColorScheme,
    textTheme: GoogleFonts.ubuntuTextTheme(baseTheme.textTheme),
    appBarTheme: _buildAppBarTheme(
      color,
      harmonizedColorScheme,
      edgeToEdgeAvailable,
      brightness,
    ),
    primaryColor: color,
    canvasColor: color,
    scaffoldBackgroundColor: color,
    chipTheme: _buildChipTheme(color, harmonizedColorScheme),
    cardTheme: _buildCardTheme(color, harmonizedColorScheme),
    bottomSheetTheme: _buildBottomSheetTheme(color, harmonizedColorScheme),
    navigationRailTheme: baseTheme.navigationRailTheme.copyWith(
      backgroundColor: color,
    ),
    navigationBarTheme: _buildNavigationBarTheme(color, harmonizedColorScheme),
    inputDecorationTheme: _buildInputDecorationTheme(baseTheme),
  );
}

AppBarTheme _buildAppBarTheme(
  Color? color,
  ColorScheme? colorScheme,
  bool edgeToEdgeAvailable,
  Brightness brightness,
) => AppBarTheme(
  backgroundColor: color,
  foregroundColor: colorScheme?.onSurface,
  shadowColor: Colors.transparent,
  surfaceTintColor: Colors.transparent,
  elevation: 0,
  systemOverlayStyle: SystemUiOverlayStyle(
    statusBarIconBrightness: brightness == Brightness.light
        ? Brightness.dark
        : Brightness.light,
    statusBarColor: Colors.transparent,
    systemStatusBarContrastEnforced: false,
    systemNavigationBarContrastEnforced: false,
    systemNavigationBarDividerColor: Colors.transparent,
    systemNavigationBarIconBrightness: brightness == Brightness.light
        ? Brightness.dark
        : Brightness.light,
    systemNavigationBarColor: edgeToEdgeAvailable
        ? Colors.transparent
        : colorScheme?.surface,
  ),
);

ChipThemeData _buildChipTheme(Color? color, ColorScheme? colorScheme) =>
    ChipThemeData(
      side: BorderSide.none,
      backgroundColor: Colors.transparent,
      surfaceTintColor: color == oledColor
          ? Colors.transparent
          : colorScheme?.surfaceTint,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      shadowColor: Colors.transparent,
    );

CardThemeData _buildCardTheme(Color? color, ColorScheme? colorScheme) =>
    CardThemeData(
      color: color,
      surfaceTintColor: color == oledColor
          ? Colors.transparent
          : colorScheme?.surfaceTint,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      shadowColor: Colors.transparent,
    );

BottomSheetThemeData _buildBottomSheetTheme(
  Color? color,
  ColorScheme? colorScheme,
) => BottomSheetThemeData(
  backgroundColor: color,
  surfaceTintColor: color == oledColor
      ? Colors.transparent
      : colorScheme?.surfaceTint,
);

NavigationBarThemeData _buildNavigationBarTheme(
  Color? color,
  ColorScheme? colorScheme,
) => NavigationBarThemeData(
  backgroundColor: color,
  surfaceTintColor: color == oledColor
      ? Colors.transparent
      : colorScheme?.surfaceTint,
  labelTextStyle: WidgetStateProperty.all(
    const TextStyle(overflow: TextOverflow.ellipsis, fontSize: 12),
  ),
);

InputDecorationTheme _buildInputDecorationTheme(ThemeData baseTheme) =>
    InputDecorationTheme(
      labelStyle: WidgetStateTextStyle.resolveWith(
        (Set<WidgetState> states) => const TextStyle(fontSize: 14),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: baseTheme.disabledColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: baseTheme.disabledColor),
      ),
    );
