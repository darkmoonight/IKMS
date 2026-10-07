import 'package:ikms/i18n/strings.g.dart';

export 'strings.g.dart';

/// Looks up a translation by legacy camelCase or snake_case [key].
String trDynamic(String key) {
  final slangKey = _toSlangKey(key);
  final translations = LocaleSettings.instance.currentTranslations;
  final value = translations[slangKey] ?? translations[key];
  return value?.toString() ?? key;
}

/// Adds `.tr` for dynamic string-key lookups outside generated getters.
extension Tr on String {
  /// Resolves this string as a dynamic translation key.
  String get tr => trDynamic(this);
}

/// Normalizes legacy keys to snake_case slang map keys.
String _toSlangKey(String key) {
  if (key.contains('_') || !RegExp(r'[A-Z]').hasMatch(key)) return key;
  return key
      .replaceAllMapped(
        RegExp(r'[A-Z]'),
        (match) => '_${match.group(0)!.toLowerCase()}',
      )
      .replaceFirst(RegExp(r'^_'), '');
}
