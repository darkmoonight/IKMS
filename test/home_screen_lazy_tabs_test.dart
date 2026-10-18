import 'package:flutter_test/flutter_test.dart';
import 'package:ikms/features/shell/presentation/home_screen.dart';
import 'package:ikms/i18n/strings.g.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('cold start mounts only the first tab page', (tester) async {
    await LocaleSettings.setLocale(AppLocale.enUs);

    final built = <int>[];
    final key = GlobalKey<HomeScreenState>();

    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(
          key: key,
          pageBuilder: (index) {
            built.add(index);
            return Text('tab-$index', key: ValueKey('tab-$index'));
          },
        ),
      ),
    );

    expect(built, [0]);
    expect(key.currentState!.visited, {0});
    expect(find.byKey(const ValueKey('tab-0')), findsOneWidget);
    expect(find.byKey(const ValueKey('tab-1')), findsNothing);
  });

  testWidgets('visiting another tab keeps previous pages mounted', (
    tester,
  ) async {
    await LocaleSettings.setLocale(AppLocale.enUs);

    final built = <int>[];
    final key = GlobalKey<HomeScreenState>();

    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(
          key: key,
          pageBuilder: (index) {
            built.add(index);
            return Text('tab-$index', key: ValueKey('tab-$index'));
          },
        ),
      ),
    );

    key.currentState!.changeTabIndex(4);
    await tester.pump();

    expect(built, [0, 4]);
    expect(key.currentState!.visited, {0, 4});
    expect(
      find.byKey(const ValueKey('tab-0'), skipOffstage: false),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('tab-4'), skipOffstage: false),
      findsOneWidget,
    );
  });
}
