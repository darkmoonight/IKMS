class Groups {
  Groups({
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
    required this.kurs,
    required this.facul,
    required this.yearName,
    required this.facultyId,
  });

  final String name;
  final int id;
  final int kurs;
  final String facul;
  final String yearName;
  final int facultyId;
}
