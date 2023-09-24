import 'package:get/get.dart';
import 'package:ikms/app/data/schema.dart';
import 'package:ikms/main.dart';

class AdsController extends GetxController {
  var ads = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (settings.ads != null) {
      ads.value = settings.ads!;
    } else {
      ads.value = false;
    }
  }

  void toggleAds(value) {
    settings.ads = value;
    isar.writeTxnSync(() => isar.settings.putSync(settings));
    ads.value = value;
  }
}
