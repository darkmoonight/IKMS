/// JSON DTO [Rasp] used by the DonSTU API layer.
class Rasp {
  Rasp({required this.data, required this.state, required this.msg});

  final DataRasp data;
  final int state;
  final String msg;

  factory Rasp.fromJson(Map<String, dynamic> json) {
    final dataRaw = json['data'];
    return Rasp(
      data: DataRasp.fromJson(
        dataRaw is Map
            ? Map<String, dynamic>.from(dataRaw)
            : const <String, dynamic>{},
      ),
      state: (json['state'] as num?)?.toInt() ?? 0,
      msg: json['msg']?.toString() ?? '',
    );
  }
}

/// JSON DTO [DataRasp] used by the DonSTU API layer.
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
}

/// JSON DTO [Info] used by the DonSTU API layer.
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
}

/// JSON DTO [Aud] used by the DonSTU API layer.
class Aud {
  Aud({required this.name});

  final String name;

  factory Aud.fromJson(Map<String, dynamic> json) =>
      Aud(name: json['name'] ?? '');
}

/// JSON DTO [Group] used by the DonSTU API layer.
class Group {
  Group({required this.name, required this.groupId});

  final String name;
  final int? groupId;

  factory Group.fromJson(Map<String, dynamic> json) =>
      Group(name: json['name'] ?? '', groupId: json['groupID']);
}

/// JSON DTO [TypesWeek] used by the DonSTU API layer.
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
}

/// JSON DTO [RaspElement] used by the DonSTU API layer.
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
    numberOfJobs: (json['номерЗанятия'] as num?)?.toInt() ?? -1,
    link: json['ссылка'],
    creatingWebinar: json['созданиеВебинара'] as bool?,
    codVebinara: json['кодВебинара'],
    webIsRestarted: json['вебинарЗапущен'] as bool?,
    codeStroke: [
      for (final x in (json['кодыСтрок'] as List? ?? const []))
        if (x is num) x.toInt(),
    ],
  );
}
