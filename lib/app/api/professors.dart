import 'dart:convert';

ProfessorsData professorsFromJson(String str) =>
    ProfessorsData.fromJson(json.decode(str));

String professorsDataToJson(ProfessorsData data) => json.encode(data.toJson());

class ProfessorsData {
  ProfessorsData({required this.data, required this.state, required this.msg});

  final List<Professors> data;
  final int state;
  final String msg;

  factory ProfessorsData.fromJson(Map<String, dynamic> json) => ProfessorsData(
    data: List<Professors>.from(
      json['data'].map((x) => Professors.fromJson(x)),
    ),
    state: json['state'],
    msg: json['msg'],
  );

  Map<String, dynamic> toJson() => {
    'data': List<dynamic>.from(data.map((x) => x.toJson())),
    'state': state,
    'msg': msg,
  };
}

class Professors {
  Professors({
    required this.name,
    required this.kaf,
    required this.id,
    required this.idFromRasp,
  });

  final String name;
  final String kaf;
  final int id;
  final bool? idFromRasp;

  factory Professors.fromJson(Map<String, dynamic> json) => Professors(
    name: json['name'] ?? '',
    kaf: json['kaf'] ?? '',
    id: json['id'],
    idFromRasp: json['idFromRasp'],
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'kaf': kaf,
    'id': id,
    'idFromRasp': idFromRasp,
  };
}
