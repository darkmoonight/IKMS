import 'package:objectbox/objectbox.dart';

@Entity()
class University {
  int id = 0;
  String? name;
  @Property(type: PropertyType.date)
  DateTime? groupsUpdateDate;
  @Property(type: PropertyType.date)
  DateTime? professorsUpdateDate;
  @Property(type: PropertyType.date)
  DateTime? audiencesUpdateDate;

  @Backlink('university')
  final groups = ToMany<Group>();
  @Backlink('university')
  final professors = ToMany<Professor>();
  @Backlink('university')
  final audiences = ToMany<Audience>();
  @Backlink('university')
  final pairs = ToMany<Pair>();
}

@Entity()
class Group {
  @Id(assignable: true)
  int id = 0;
  String? name;
  String? faculty;
  @Property(type: PropertyType.date)
  DateTime? updateDate;

  final university = ToOne<University>();
  @Backlink('group')
  final pairs = ToMany<Pair>();
}

@Entity()
class Professor {
  @Id(assignable: true)
  int id = 0;
  String? name;
  String? department;
  @Property(type: PropertyType.date)
  DateTime? updateDate;

  final university = ToOne<University>();
  @Backlink('professor')
  final pairs = ToMany<Pair>();
}

@Entity()
class Audience {
  @Id(assignable: true)
  int id = 0;
  String? name;
  @Property(type: PropertyType.date)
  DateTime? updateDate;

  final university = ToOne<University>();
  @Backlink('audience')
  final pairs = ToMany<Pair>();
}

@Entity()
class Pair {
  int id = 0;
  @Property(type: PropertyType.date)
  DateTime? date;
  String? begin;
  String? end;
  String? subject;
  String? audiences;
  String? professors;
  String? groups;
  int? pair;

  final group = ToOne<Group>();
  final professor = ToOne<Professor>();
  final audience = ToOne<Audience>();
  final university = ToOne<University>();
}
