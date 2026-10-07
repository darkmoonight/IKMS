import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:ikms/app.dart';
import 'package:ikms/core/bootstrap/app_initializer.dart';
import 'package:ikms/core/di/provider_refs.dart';
import 'package:ikms/core/services/connectivity_service.dart';

/// Entry point: bootstraps dependencies and runs [IkmsApp].
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ConnectivityService.setup();
  final bootstrap = await AppInitializer.initialize();
  runApp(
    ProviderScope(
      overrides: [bootstrapProvider.overrideWithValue(bootstrap)],
      child: const IkmsApp(),
    ),
  );
}
