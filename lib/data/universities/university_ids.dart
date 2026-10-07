/// Stable university catalog ids used as Isar [University.id] and API keys.
///
/// To add a university:
/// 1. Create `lib/data/universities/<slug>/` with a `UniversityAPI` impl + DTOs
/// 2. Add an id constant here
/// 3. Register in `UniversityRegistry.apis` and `UniversityRegistry.catalog`
abstract final class UniversityIds {
  static const int donstu = 1;
}
