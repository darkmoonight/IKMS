import 'package:get/get.dart';
import 'package:ikms/app/data/db.dart';
import 'package:ikms/main.dart';

class AdsController extends GetxController {
  final RxBool ads = false.obs;

  @override
  void onInit() {
    super.onInit();
    ads.value = settings.ads ?? false;
  }

  void toggleAds(bool value) {
    ads.value = value;
    settings.ads = value;
    try {
      isar.writeTxnSync(() => isar.settings.putSync(settings));
    } catch (e) {
      Get.snackbar('Error', 'Failed to save settings: $e');
    }
  }
}
