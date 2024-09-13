import 'package:get/get.dart';
import 'package:ikms/app/data/db.dart';
import 'package:ikms/main.dart';

class AdsController extends GetxController {
  var ads = false.obs;

  @override
  void onInit() {
    super.onInit();
    settings.ads != null ? ads.value = settings.ads! : ads.value = false;
  }

  void toggleAds(value) {
    ads.value = value;
    settings.ads = value;
    isar.writeTxnSync(() => isar.settings.putSync(settings));
  }
}
