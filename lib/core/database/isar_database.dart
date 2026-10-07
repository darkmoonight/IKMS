import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ikms/data/models/db.dart';

/// Opens the IKMS Isar database with all collection schemas.
Future<Isar> openIkmsIsar() async {
  return Isar.open(
    [
      SettingsSchema,
      UniversitySchema,
      GroupScheduleSchema,
      TeacherScheduleSchema,
      AudienceScheduleSchema,
      TodosSchema,
    ],
    compactOnLaunch: const CompactCondition(minRatio: 2),
    directory: (await getApplicationSupportDirectory()).path,
  );
}
