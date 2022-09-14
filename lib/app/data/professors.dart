class Professors {
  Professors({
    required this.data,
    required this.state,
    required this.msg,
  });

  final List<Datum> data;
  final int state;
  final String msg;
}

class Datum {
  Datum({
    required this.name,
    required this.kaf,
    required this.id,
    required this.idFromRasp,
  });

  final String name;
  final String kaf;
  final int id;
  final bool idFromRasp;
}
