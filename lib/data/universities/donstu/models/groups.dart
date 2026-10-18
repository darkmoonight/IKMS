/// JSON DTO [GroupsData] used by the DonSTU API layer.
class GroupsData {
  GroupsData({required this.data, required this.state, required this.msg});

  final List<Groups> data;
  final int state;
  final String msg;

  factory GroupsData.fromJson(Map<String, dynamic> json) {
    final raw = json['data'];
    final entries = <Groups>[];
    if (raw is List) {
      for (final item in raw) {
        if (item is! Map) continue;
        final map = Map<String, dynamic>.from(item);
        if (map['id'] == null) continue;
        entries.add(Groups.fromJson(map));
      }
    }
    return GroupsData(
      data: entries,
      state: (json['state'] as num?)?.toInt() ?? 0,
      msg: json['msg']?.toString() ?? '',
    );
  }
}

/// JSON DTO [Groups] used by the DonSTU API layer.
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
    name: json['name']?.toString() ?? '',
    id: (json['id'] as num).toInt(),
    kurs: (json['kurs'] as num?)?.toInt(),
    facul: json['facul']?.toString() ?? '',
    yearName: json['yearName']?.toString() ?? '',
    facultyId: (json['facultyID'] as num?)?.toInt(),
  );
}
