import 'dart:convert';

AudiencesData audiencesFromJson(String str) =>
    AudiencesData.fromJson(json.decode(str));

String audiencesDataToJson(AudiencesData data) => json.encode(data.toJson());

class AudiencesData {
  AudiencesData({
    required this.data,
    required this.state,
    required this.msg,
  });

  List<Audiences> data;
  int state;
  String msg;

  factory AudiencesData.fromJson(Map<String, dynamic> json) => AudiencesData(
        data: List<Audiences>.from(
            json["data"].map((x) => Audiences.fromJson(x))),
        state: json["state"],
        msg: json["msg"],
      );

  Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "state": state,
        "msg": msg,
      };
}

class Audiences {
  Audiences({
    required this.name,
    required this.id,
  });

  String name;
  int? id;

  factory Audiences.fromJson(Map<String, dynamic> json) => Audiences(
        name: json["name"] ?? '',
        id: json["id"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "id": id,
      };
}
