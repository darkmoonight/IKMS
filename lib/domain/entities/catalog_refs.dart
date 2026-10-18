/// Shared id/name surface for catalog rows in selection UI.
abstract interface class NamedRef {
  int get id;
  String get name;
}

/// Lightweight university identity for UI and preferences.
class UniversityRef implements NamedRef {
  const UniversityRef({required this.id, required this.name});

  @override
  final int id;
  @override
  final String name;
}

/// Lightweight group identity linked to a university.
class GroupRef implements NamedRef {
  const GroupRef({
    required this.id,
    required this.name,
    required this.universityId,
  });

  @override
  final int id;
  @override
  final String name;
  final int universityId;
}

/// Lightweight teacher identity.
class TeacherRef implements NamedRef {
  const TeacherRef({
    required this.id,
    required this.name,
    required this.universityId,
  });

  @override
  final int id;
  @override
  final String name;
  final int universityId;
}

/// Lightweight audience/room identity.
class AudienceRef implements NamedRef {
  const AudienceRef({
    required this.id,
    required this.name,
    required this.universityId,
  });

  @override
  final int id;
  @override
  final String name;
  final int universityId;
}

/// Opens a schedule detail page for a catalog entity.
enum ScheduleTargetKind { group, teacher, audience }

/// Target for [RaspDetailPage] without Isar types.
class ScheduleTarget {
  const ScheduleTarget({
    required this.kind,
    required this.id,
    required this.name,
    required this.universityId,
  });

  final ScheduleTargetKind kind;
  final int id;
  final String name;
  final int universityId;
}
