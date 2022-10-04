import 'package:objectbox/objectbox.dart';

@Entity()
class Settings {
  int id;
  bool? theme;
  String? locale;

  final university = ToOne<University>();
  final group = ToOne<Group>();

  Settings({this.id = 0, this.theme, this.locale});
}

@Entity()
class University {
  int id;
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

  University(
      {this.id = 0,
      this.name,
      this.groupsUpdateDate,
      this.professorsUpdateDate,
      this.audiencesUpdateDate});
}

@Entity()
class Group {
  @Id(assignable: true)
  int id;
  String? name;
  String? faculty;
  @Property(type: PropertyType.date)
  DateTime? updateDate;

  final university = ToOne<University>();
  @Backlink('group')
  final pairs = ToMany<Pair>();

  Group({this.id = 0, this.name, this.faculty, this.updateDate});
}

@Entity()
class Professor {
  @Id(assignable: true)
  int id;
  String? name;
  String? department;
  @Property(type: PropertyType.date)
  DateTime? updateDate;

  final university = ToOne<University>();
  @Backlink('professor')
  final pairs = ToMany<Pair>();

  Professor({this.id = 0, this.name, this.department, this.updateDate});
}

@Entity()
class Audience {
  @Id(assignable: true)
  int id;
  String? name;
  @Property(type: PropertyType.date)
  DateTime? updateDate;

  final university = ToOne<University>();
  @Backlink('audience')
  final pairs = ToMany<Pair>();

  Audience({this.id = 0, this.name, this.updateDate});
}

@Entity()
class Pair {
  int id;
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

  Pair(
      {this.id = 0,
      this.date,
      this.begin,
      this.end,
      this.subject,
      this.audiences,
      this.professors,
      this.groups,
      this.pair});
}
