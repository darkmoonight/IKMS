import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:material_ui/material_ui.dart';

/// Tracks online status for schedule refresh and cache decisions.
class ConnectivityService {
  ConnectivityService._();

  /// Shared notifier of a [Future] that resolves to the current online flag.
  static final ValueNotifier<Future<bool>> isOnline = ValueNotifier(
    InternetConnection().hasInternetAccess,
  );

  /// Starts listening to platform connectivity changes.
  static void setup() {
    Connectivity().onConnectivityChanged.listen((result) {
      if (result.contains(ConnectivityResult.none)) {
        isOnline.value = Future.value(false);
      } else {
        isOnline.value = InternetConnection().hasInternetAccess;
      }
    });
  }
}
