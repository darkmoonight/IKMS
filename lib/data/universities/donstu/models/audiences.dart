/// JSON DTO [AudiencesData] used by the DonSTU API layer.
class AudiencesData {
  AudiencesData({required this.data, required this.state, required this.msg});

  final List<Audiences> data;
  final int state;
  final String msg;

  factory AudiencesData.fromJson(Map<String, dynamic> json) => AudiencesData(
    data: List<Audiences>.from(json['data'].map((x) => Audiences.fromJson(x))),
    state: json['state'],
    msg: json['msg'],
  );

  Map<String, dynamic> toJson() => {
    'data': List<dynamic>.from(data.map((x) => x.toJson())),
    'state': state,
    'msg': msg,
  };
}

/// JSON DTO [Audiences] used by the DonSTU API layer.
class Audiences {
  Audiences({required this.name, required this.id});

  final String name;
  final int id;

  factory Audiences.fromJson(Map<String, dynamic> json) =>
      Audiences(name: json['name'] ?? '', id: json['id']);

  Map<String, dynamic> toJson() => {'name': name, 'id': id};
}
