import 'package:get/get.dart';
import 'package:ikms/translation/en_us.dart';
import 'package:ikms/translation/ru_ru.dart';

class Translation extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'ru_RU': RuRu().messages,
        'en_US': EnUs().messages,
      };
}
