import 'package:get/get.dart';
import 'package:ikms/app/data/db.dart';
import 'package:ikms/app/utils/show_snack_bar.dart';
import 'package:ikms/main.dart';

class AdsController extends GetxController {
  final RxBool ads = false.obs;

  @override
  void onInit() {
    super.onInit();
    ads.value = settings.ads ?? false;
  }

  Future<void> toggleAds(bool value) async {
    ads.value = value;
    settings.ads = value;
    try {
      await isar.writeTxn(() async => await isar.settings.put(settings));
    } catch (e) {
      showSnackBar('Failed to save settings: $e', isError: true);
    }
  }
}
