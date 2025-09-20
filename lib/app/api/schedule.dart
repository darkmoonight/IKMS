import 'dart:convert';

Rasp raspFromJson(String str) => Rasp.fromJson(json.decode(str));

String raspToJson(Rasp data) => json.encode(data.toJson());

class Rasp {
  Rasp({required this.data, required this.state, required this.msg});

  final DataRasp data;
  final int state;
  final String msg;

  factory Rasp.fromJson(Map<String, dynamic> json) => Rasp(
    data: DataRasp.fromJson(json['data']),
    state: json['state'],
    msg: json['msg'],
  );

  Map<String, dynamic> toJson() => {
    'data': data.toJson(),
    'state': state,
    'msg': msg,
  };
}

class DataRasp {
  DataRasp({
    required this.isCyclicalSchedule,
    required this.rasp,
    required this.info,
  });

  final bool? isCyclicalSchedule;
  final List<RaspElement> rasp;
  final Info info;

  factory DataRasp.fromJson(Map<String, dynamic> json) => DataRasp(
    isCyclicalSchedule: json['isCyclicalSchedule'],
    rasp: List<RaspElement>.from(
      json['rasp']?.map((x) => RaspElement.fromJson(x)) ?? [],
    ),
    info: Info.fromJson(json['info'] ?? {}),
  );

  Map<String, dynamic> toJson() => {
    'isCyclicalSchedule': isCyclicalSchedule,
    'rasp': List<dynamic>.from(rasp.map((x) => x.toJson())),
    'info': info.toJson(),
  };
}

class Info {
  Info({
    required this.group,
    required this.prepod,
    required this.aud,
    required this.year,
    required this.curWeekNumber,
    required this.curNumNed,
    required this.selectedNumNed,
    required this.curSem,
    required this.typesWeek,
    required this.fixedInCache,
    required this.date,
    required this.lastDate,
    required this.dateUploadingRasp,
  });

  final Group group;
  final Aud prepod;
  final Aud aud;
  final String year;
  final int? curWeekNumber;
  final int? curNumNed;
  final int? selectedNumNed;
  final int? curSem;
  final List<TypesWeek> typesWeek;
  final bool? fixedInCache;
  final String date;
  final String lastDate;
  final String dateUploadingRasp;

  factory Info.fromJson(Map<String, dynamic> json) => Info(
    group: Group.fromJson(json['group'] ?? {}),
    prepod: Aud.fromJson(json['prepod'] ?? {}),
    aud: Aud.fromJson(json['aud'] ?? {}),
    year: json['year'] ?? '',
    curWeekNumber: json['curWeekNumber'],
    curNumNed: json['curNumNed'],
    selectedNumNed: json['selectedNumNed'],
    curSem: json['curSem'],
    typesWeek: List<TypesWeek>.from(
      json['typesWeek']?.map((x) => TypesWeek.fromJson(x)) ?? [],
    ),
    fixedInCache: json['fixedInCache'],
    date: json['date'] ?? '',
    lastDate: json['lastDate'] ?? '',
    dateUploadingRasp: json['dateUploadingRasp'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'group': group.toJson(),
    'prepod': prepod.toJson(),
    'aud': aud.toJson(),
    'year': year,
    'curWeekNumber': curWeekNumber,
    'curNumNed': curNumNed,
    'selectedNumNed': selectedNumNed,
    'curSem': curSem,
    'typesWeek': List<dynamic>.from(typesWeek.map((x) => x.toJson())),
    'fixedInCache': fixedInCache,
    'date': date,
    'lastDate': lastDate,
    'dateUploadingRasp': dateUploadingRasp,
  };
}

class Aud {
  Aud({required this.name});

  final String name;

  factory Aud.fromJson(Map<String, dynamic> json) =>
      Aud(name: json['name'] ?? '');

  Map<String, dynamic> toJson() => {'name': name};
}

class Group {
  Group({required this.name, required this.groupId});

  final String name;
  final int? groupId;

  factory Group.fromJson(Map<String, dynamic> json) =>
      Group(name: json['name'] ?? '', groupId: json['groupID']);

  Map<String, dynamic> toJson() => {'name': name, 'groupID': groupId};
}

class TypesWeek {
  TypesWeek({
    required this.typeWeekId,
    required this.name,
    required this.shortName,
  });

  final int? typeWeekId;
  final String name;
  final String shortName;

  factory TypesWeek.fromJson(Map<String, dynamic> json) => TypesWeek(
    typeWeekId: json['typeWeekID'],
    name: json['name'] ?? '',
    shortName: json['shortName'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'typeWeekID': typeWeekId,
    'name': name,
    'shortName': shortName,
  };
}

class RaspElement {
  RaspElement({
    required this.code,
    required this.date,
    required this.beginning,
    required this.datanachala,
    required this.endDate,
    required this.end,
    required this.weekday,
    required this.weekDay,
    required this.mail,
    required this.day,
    required this.codeSemester,
    required this.typeWeeks,
    required this.numberGroups,
    required this.discipline,
    required this.teacher,
    required this.position,
    required this.audience,
    required this.academicYear,
    required this.group,
    required this.custom1,
    required this.clock,
    required this.nedelyanachala,
    required this.nedelyaokonchaniya,
    required this.replacement,
    required this.codePreducer,
    required this.codeGroup,
    required this.fiopreducer,
    required this.userCode,
    required this.writingElement,
    required this.topic,
    required this.numberOfJobs,
    required this.link,
    required this.creatingWebinar,
    required this.codVebinara,
    required this.webIsRestarted,
    required this.codeStroke,
  });

  final int? code;
  final String date;
  final String beginning;
  final String datanachala;
  final String endDate;
  final String end;
  final int? weekday;
  final String weekDay;
  final String mail;
  final String day;
  final int? codeSemester;
  final int? typeWeeks;
  final int? numberGroups;
  final String discipline;
  final String teacher;
  final String position;
  final String audience;
  final String academicYear;
  final String group;
  final String custom1;
  final String clock;
  final int? nedelyanachala;
  final int? nedelyaokonchaniya;
  final bool? replacement;
  final int? codePreducer;
  final int? codeGroup;
  final String fiopreducer;
  final int? userCode;
  final bool? writingElement;
  final String topic;
  final int numberOfJobs;
  final dynamic link;
  final bool? creatingWebinar;
  final dynamic codVebinara;
  final bool? webIsRestarted;
  final List<int> codeStroke;

  factory RaspElement.fromJson(Map<String, dynamic> json) => RaspElement(
    code: json['код'],
    date: json['дата'] ?? '',
    beginning: json['начало'] ?? '',
    datanachala: json['датаНачала'] ?? '',
    endDate: json['датаОкончания'] ?? '',
    end: json['конец'] ?? '',
    weekday: json['деньНедели'],
    weekDay: json['день_недели'] ?? '',
    mail: json['почта'] ?? '',
    day: json['день'] ?? '',
    codeSemester: json['код_Семестра'],
    typeWeeks: json['типНедели'],
    numberGroups: json['номерПодгруппы'],
    discipline: json['дисциплина'] ?? '',
    teacher: json['преподаватель'] ?? '',
    position: json['должность'] ?? '',
    audience: json['аудитория'] ?? '',
    academicYear: json['учебныйГод'] ?? '',
    group: json['группа'] ?? '',
    custom1: json['custom1'] ?? '',
    clock: json['часы'] ?? '',
    nedelyanachala: json['неделяНачала'],
    nedelyaokonchaniya: json['неделяОкончания'],
    replacement: json['замена'],
    codePreducer: json['кодПреподавателя'],
    codeGroup: json['кодГруппы'],
    fiopreducer: json['фиоПреподавателя'] ?? '',
    userCode: json['кодПользователя'],
    writingElement: json['элементЦиклРасписания'],
    topic: json['тема'] ?? '',
    numberOfJobs: json['номерЗанятия'],
    link: json['ссылка'],
    creatingWebinar: json['созданиеВебинара'],
    codVebinara: json['кодВебинара'],
    webIsRestarted: json['вебинарЗапущен'],
    codeStroke: List<int>.from(json['кодыСтрок'].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    'код': code,
    'дата': date,
    'начало': beginning,
    'датаНачала': datanachala,
    'датаОкончания': endDate,
    'конец': end,
    'деньНедели': weekday,
    'день_недели': weekDay,
    'почта': mail,
    'день': day,
    'код_Семестра': codeSemester,
    'типНедели': typeWeeks,
    'номерПодгруппы': numberGroups,
    'дисциплина': discipline,
    'преподаватель': teacher,
    'должность': position,
    'аудитория': audience,
    'учебныйГод': academicYear,
    'группа': group,
    'custom1': custom1,
    'часы': clock,
    'неделяНачала': nedelyanachala,
    'неделяОкончания': nedelyaokonchaniya,
    'замена': replacement,
    'кодПреподавателя': codePreducer,
    'кодГруппы': codeGroup,
    'фиоПреподавателя': fiopreducer,
    'кодПользователя': userCode,
    'элементЦиклРасписания': writingElement,
    'тема': topic,
    'номерЗанятия': numberOfJobs,
    'ссылка': link,
    'созданиеВебинара': creatingWebinar,
    'кодВебинара': codVebinara,
    'вебинарЗапущен': webIsRestarted,
    'кодыСтрок': List<dynamic>.from(codeStroke.map((x) => x)),
  };
}
