import 'package:isar_community/isar.dart';
import 'package:ikms/data/models/db.dart';

/// Reads and writes app [Settings] in Isar.
class SettingsRepository {
  SettingsRepository(this._isar, {this.onSaved});

  final Isar _isar;
  final void Function()? onSaved;

  /// Persists settings and invokes [onSaved] when provided.
  Future<void> save(Settings settings) async {
    await _isar.writeTxn(() => _isar.settings.put(settings));
    onSaved?.call();
  }

  /// Links [university] on [settings], clears group, and persists both.
  Future<void> setUniversity(Settings settings, University university) async {
    settings.university.value = university;
    settings.group.value = null;
    await _isar.writeTxn(() async {
      await _isar.settings.put(settings);
      await settings.university.save();
      await settings.group.save();
    });
    onSaved?.call();
  }

  /// Links [group] (and its university) on [settings] and persists them.
  Future<void> setGroup(Settings settings, GroupSchedule group) async {
    settings.group.value = group;
    await _isar.writeTxn(() async {
      await _isar.groupSchedules.put(group);
      await group.university.save();
      await _isar.settings.put(settings);
      await settings.group.save();
    });
    onSaved?.call();
  }
}
