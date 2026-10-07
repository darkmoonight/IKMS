import 'package:ikms/core/utils/snackbar_overlay.dart';

/// Shows a global overlay snackbar with optional error/info styling.
void showSnackBar(String message, {bool isError = false, bool isInfo = false}) {
  SnackBarOverlay.instance.show(message, isError: isError, isInfo: isInfo);
}
