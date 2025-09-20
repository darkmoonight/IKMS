import 'dart:convert';

GroupsData groupsFromJson(String str) => GroupsData.fromJson(json.decode(str));

String groupsDataToJson(GroupsData data) => json.encode(data.toJson());

class GroupsData {
  GroupsData({required this.data, required this.state, required this.msg});

  final List<Groups> data;
  final int state;
  final String msg;

  factory GroupsData.fromJson(Map<String, dynamic> json) => GroupsData(
    data: List<Groups>.from(json['data'].map((x) => Groups.fromJson(x))),
    state: json['state'],
    msg: json['msg'],
  );

  Map<String, dynamic> toJson() => {
    'data': List<dynamic>.from(data.map((x) => x.toJson())),
    'state': state,
    'msg': msg,
  };
}

class Groups {
  Groups({
    required this.name,
    required this.id,
    required this.kurs,
    required this.facul,
    required this.yearName,
    required this.facultyId,
  });

  final String name;
  final int id;
  final int? kurs;
  final String facul;
  final String yearName;
  final int? facultyId;

  factory Groups.fromJson(Map<String, dynamic> json) => Groups(
    name: json['name'] ?? '',
    id: json['id'],
    kurs: json['kurs'],
    facul: json['facul'] ?? '',
    yearName: json['yearName'] ?? '',
    facultyId: json['facultyID'],
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'id': id,
    'kurs': kurs,
    'facul': facul,
    'yearName': yearName,
    'facultyID': facultyId,
  };
}
