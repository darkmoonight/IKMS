// To parse required this JSON data, do
//
//     final rasp = raspFromJson(jsonString);

import 'dart:convert';

Rasp raspFromJson(String str) => Rasp.fromJson(json.decode(str));

String raspToJson(Rasp data) => json.encode(data.toJson());

class Rasp {
  Rasp({
    required this.data,
    required this.state,
    required this.msg,
  });

  final Data data;
  final int state;
  final String msg;

  factory Rasp.fromJson(Map<String, dynamic> json) => Rasp(
        data: Data.fromJson(json["data"]),
        state: json["state"],
        msg: json["msg"],
      );

  Map<String, dynamic> toJson() => {
        "data": data.toJson(),
        "state": state,
        "msg": msg,
      };
}

class Data {
  Data({
    required this.isCyclicalSchedule,
    required this.rasp,
    required this.info,
  });

  final bool isCyclicalSchedule;
  final List<RaspElement> rasp;
  final Info info;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        isCyclicalSchedule: json["isCyclicalSchedule"],
        rasp: List<RaspElement>.from(
            json["rasp"].map((x) => RaspElement.fromJson(x))),
        info: Info.fromJson(json["info"]),
      );

  Map<String, dynamic> toJson() => {
        "isCyclicalSchedule": isCyclicalSchedule,
        "rasp": List<dynamic>.from(rasp.map((x) => x.toJson())),
        "info": info.toJson(),
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
  final int curWeekNumber;
  final int curNumNed;
  final int selectedNumNed;
  final int curSem;
  final List<TypesWeek> typesWeek;
  final bool fixedInCache;
  final DateTime date;
  final DateTime lastDate;
  final DateTime dateUploadingRasp;

  factory Info.fromJson(Map<String, dynamic> json) => Info(
        group: Group.fromJson(json["group"]),
        prepod: Aud.fromJson(json["prepod"]),
        aud: Aud.fromJson(json["aud"]),
        year: json["year"],
        curWeekNumber: json["curWeekNumber"],
        curNumNed: json["curNumNed"],
        selectedNumNed: json["selectedNumNed"],
        curSem: json["curSem"],
        typesWeek: List<TypesWeek>.from(
            json["typesWeek"].map((x) => TypesWeek.fromJson(x))),
        fixedInCache: json["fixedInCache"],
        date: DateTime.parse(json["date"]),
        lastDate: DateTime.parse(json["lastDate"]),
        dateUploadingRasp: DateTime.parse(json["dateUploadingRasp"]),
      );

  Map<String, dynamic> toJson() => {
        "group": group.toJson(),
        "prepod": prepod.toJson(),
        "aud": aud.toJson(),
        "year": year,
        "curWeekNumber": curWeekNumber,
        "curNumNed": curNumNed,
        "selectedNumNed": selectedNumNed,
        "curSem": curSem,
        "typesWeek": List<dynamic>.from(typesWeek.map((x) => x.toJson())),
        "fixedInCache": fixedInCache,
        "date": date.toIso8601String(),
        "lastDate": lastDate.toIso8601String(),
        "dateUploadingRasp": dateUploadingRasp.toIso8601String(),
      };
}

class Aud {
  Aud({
    required this.name,
  });

  final String name;

  factory Aud.fromJson(Map<String, dynamic> json) => Aud(
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
      };
}

class Group {
  Group({
    required this.name,
    required this.groupId,
  });

  final String name;
  final int groupId;

  factory Group.fromJson(Map<String, dynamic> json) => Group(
        name: json["name"],
        groupId: json["groupID"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "groupID": groupId,
      };
}

class TypesWeek {
  TypesWeek({
    required this.typeWeekId,
    required this.name,
    required this.shortName,
  });

  final int typeWeekId;
  final String name;
  final String shortName;

  factory TypesWeek.fromJson(Map<String, dynamic> json) => TypesWeek(
        typeWeekId: json["typeWeekID"],
        name: json["name"],
        shortName: json["shortName"],
      );

  Map<String, dynamic> toJson() => {
        "typeWeekID": typeWeekId,
        "name": name,
        "shortName": shortName,
      };
}

class RaspElement {
  RaspElement({
    required this.frisky,
    required this.fluffy,
    required this.the6,
    required this.tentacled,
    required this.sticky,
    required this.the5,
    required this.hilarious,
    required this.indecent,
    required this.the11,
    required this.indigo,
    required this.mischievous,
    required this.the16,
    required this.the10,
    required this.ambitious,
    required this.the12,
    required this.cunning,
    required this.empty,
    required this.the17,
    required this.purple,
    required this.custom1,
    required this.the19,
    required this.the7,
    required this.the8,
    required this.magenta,
    required this.the3,
    required this.the1,
    required this.the18,
    required this.the2,
    required this.the20,
    required this.the15,
    required this.the9,
    required this.the14,
    required this.the13,
    required this.braggadocious,
    required this.rasp,
    required this.the4,
  });

  final int frisky;
  final DateTime fluffy;
  final String the6;
  final DateTime tentacled;
  final DateTime sticky;
  final String the5;
  final int hilarious;
  final String indecent;
  final String the11;
  final String indigo;
  final int mischievous;
  final int the16;
  final int the10;
  final String ambitious;
  final String the12;
  final String cunning;
  final String empty;
  final String the17;
  final String purple;
  final String custom1;
  final String the19;
  final int the7;
  final int the8;
  final dynamic magenta;
  final int the3;
  final int the1;
  final dynamic the18;
  final dynamic the2;
  final bool the20;
  final String the15;
  final int the9;
  final dynamic the14;
  final bool the13;
  final dynamic braggadocious;
  final bool rasp;
  final List<int> the4;

  factory RaspElement.fromJson(Map<String, dynamic> json) => RaspElement(
        frisky: json["код"],
        fluffy: DateTime.parse(json["дата"]),
        the6: json["начало"],
        tentacled: DateTime.parse(json["датаНачала"]),
        sticky: DateTime.parse(json["датаОкончания"]),
        the5: json["конец"],
        hilarious: json["деньНедели"],
        indecent: json["день_недели"],
        the11: json["почта"],
        indigo: json["день"],
        mischievous: json["код_Семестра"],
        the16: json["типНедели"],
        the10: json["номерПодгруппы"],
        ambitious: json["дисциплина"],
        the12: json["преподаватель"],
        cunning: json["должность"],
        empty: json["аудитория"],
        the17: json["учебныйГод"],
        purple: json["группа"],
        custom1: json["custom1"],
        the19: json["часы"],
        the7: json["неделяНачала"],
        the8: json["неделяОкончания"],
        magenta: json["замена"],
        the3: json["кодПреподавателя"],
        the1: json["кодГруппы"],
        the18: json["фиоПреподавателя"],
        the2: json["кодПользователя"],
        the20: json["элементЦиклРасписания"],
        the15: json["тема"],
        the9: json["номерЗанятия"],
        the14: json["ссылка"],
        the13: json["созданиеВебинара"],
        braggadocious: json["кодВебинара"],
        rasp: json["вебинарЗапущен"],
        the4: List<int>.from(json["кодыСтрок"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "код": frisky,
        "дата": fluffy.toIso8601String(),
        "начало": the6,
        "датаНачала": tentacled.toIso8601String(),
        "датаОкончания": sticky.toIso8601String(),
        "конец": the5,
        "деньНедели": hilarious,
        "день_недели": indecent,
        "почта": the11,
        "день": indigo,
        "код_Семестра": mischievous,
        "типНедели": the16,
        "номерПодгруппы": the10,
        "дисциплина": ambitious,
        "преподаватель": the12,
        "должность": cunning,
        "аудитория": empty,
        "учебныйГод": the17,
        "группа": purple,
        "custom1": custom1,
        "часы": the19,
        "неделяНачала": the7,
        "неделяОкончания": the8,
        "замена": magenta,
        "кодПреподавателя": the3,
        "кодГруппы": the1,
        "фиоПреподавателя": the18,
        "кодПользователя": the2,
        "элементЦиклРасписания": the20,
        "тема": the15,
        "номерЗанятия": the9,
        "ссылка": the14,
        "созданиеВебинара": the13,
        "кодВебинара": braggadocious,
        "вебинарЗапущен": rasp,
        "кодыСтрок": List<dynamic>.from(the4.map((x) => x)),
      };
}
