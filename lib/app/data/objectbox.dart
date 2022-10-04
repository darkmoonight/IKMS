import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:project_cdis/app/data/models.dart';
import 'package:project_cdis/objectbox.g.dart'; // created by `flutter pub run build_runner build`

class ObjectBox {
  /// The Store of this app.
  late final Store store;
  late final Settings settings;
  late final Box<Settings> settingsBox;
  late final Box<University> universityBox;
  late final Box<Group> groupBox;
  late final Box<Professor> professorBox;
  late final Box<Audience> audienceBox;
  late final Box<Pair> pairBox;

  ObjectBox._create(this.store) {
    // Add any additional setup code, e.g. build queries.
    settingsBox = store.box<Settings>();
    universityBox = store.box<University>();
    groupBox = store.box<Group>();
    professorBox = store.box<Professor>();
    audienceBox = store.box<Audience>();
    pairBox = store.box<Pair>();
    if (settingsBox.count() == 0) {
      final settingsInstance = Settings();
      settingsBox.put(settingsInstance);
    }
    settings = settingsBox.getAll().first;
  }

  /// Create an instance of ObjectBox to use throughout the app.
  static Future<ObjectBox> create() async {
    final docsDir = await getApplicationDocumentsDirectory();
    // Future<Store> openStore() {...} is defined in the generated objectbox.g.dart
    final store = await openStore(directory: p.join(docsDir.path, "database"));
    return ObjectBox._create(store);
  }

  void dispose() {
    store.close();
  }
}
