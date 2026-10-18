/// JSON DTO [ProfessorsData] used by the DonSTU API layer.
class ProfessorsData {
  ProfessorsData({required this.data, required this.state, required this.msg});

  final List<Professors> data;
  final int state;
  final String msg;

  factory ProfessorsData.fromJson(Map<String, dynamic> json) {
    final raw = json['data'];
    final entries = <Professors>[];
    if (raw is List) {
      for (final item in raw) {
        if (item is! Map) continue;
        final map = Map<String, dynamic>.from(item);
        if (map['id'] == null) continue;
        entries.add(Professors.fromJson(map));
      }
    }
    return ProfessorsData(
      data: entries,
      state: (json['state'] as num?)?.toInt() ?? 0,
      msg: json['msg']?.toString() ?? '',
    );
  }
}

/// JSON DTO [Professors] used by the DonSTU API layer.
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
    name: json['name']?.toString() ?? '',
    kaf: json['kaf']?.toString() ?? '',
    id: (json['id'] as num).toInt(),
    idFromRasp: json['idFromRasp'] as bool?,
  );
}
