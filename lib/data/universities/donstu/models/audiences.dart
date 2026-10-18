/// JSON DTO [AudiencesData] used by the DonSTU API layer.
class AudiencesData {
  AudiencesData({required this.data, required this.state, required this.msg});

  final List<Audiences> data;
  final int state;
  final String msg;

  factory AudiencesData.fromJson(Map<String, dynamic> json) {
    final raw = json['data'];
    final entries = <Audiences>[];
    if (raw is List) {
      for (final item in raw) {
        if (item is! Map) continue;
        final map = Map<String, dynamic>.from(item);
        if (map['id'] == null) continue;
        entries.add(Audiences.fromJson(map));
      }
    }
    return AudiencesData(
      data: entries,
      state: (json['state'] as num?)?.toInt() ?? 0,
      msg: json['msg']?.toString() ?? '',
    );
  }
}

/// JSON DTO [Audiences] used by the DonSTU API layer.
class Audiences {
  Audiences({required this.name, required this.id});

  final String name;
  final int id;

  factory Audiences.fromJson(Map<String, dynamic> json) => Audiences(
    name: json['name']?.toString() ?? '',
    id: (json['id'] as num).toInt(),
  );
}
