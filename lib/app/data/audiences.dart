class Audiences {
  Audiences({
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
    required this.id,
  });

  final String name;
  final int id;
}
