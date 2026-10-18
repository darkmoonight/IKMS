import 'package:ikms/data/models/db.dart';
import 'package:ikms/data/universities/donstu/models/audiences.dart';
import 'package:ikms/data/universities/donstu/models/groups.dart';
import 'package:ikms/data/universities/donstu/models/professors.dart';
import 'package:ikms/data/universities/donstu/models/schedule.dart';
import 'package:ikms/data/universities/university_api.dart';
import 'package:ikms/data/universities/university_entity_id.dart';
import 'package:ikms/data/universities/university_ids.dart';
import 'package:intl/intl.dart';

/// DonSTU (`edu.donstu.ru`) implementation of [UniversityAPI].
class DonstuAPI extends UniversityAPI {
  /// Creates the DonSTU API client.
  DonstuAPI() : super(UniversityIds.donstu, 'https://edu.donstu.ru/api/');

  int _encode(int remoteId) =>
      UniversityEntityId.encode(universityId, remoteId);

  @override
  Future<List<AudienceSchedule>> getAudiencesData() async {
    const url = 'raspAudlist';
    final response = await dio.get(url);
    final audiencesData = AudiencesData.fromJson(response.data);
    return audiencesData.data
        .map(
          (audiences) =>
              AudienceSchedule(id: _encode(audiences.id), name: audiences.name),
        )
        .toList();
  }

  @override
  Future<List<TeacherSchedule>> getProfessorsData() async {
    const url = 'raspTeacherlist';
    final response = await dio.get(url);
    final professorsData = ProfessorsData.fromJson(response.data);
    return professorsData.data
        .map(
          (professors) => TeacherSchedule(
            id: _encode(professors.id),
            name: professors.name,
          ),
        )
        .toList();
  }

  @override
  Future<List<GroupSchedule>> getGroupsData() async {
    const url = 'raspGrouplist';
    final response = await dio.get(url);
    final groupsData = GroupsData.fromJson(response.data);
    return groupsData.data
        .map(
          (groups) => GroupSchedule(id: _encode(groups.id), name: groups.name),
        )
        .toList();
  }

  @override
  Future<List<Schedule>> getRaspsGroupElementData(int? remoteId) async {
    final url = 'Rasp?idGroup=$remoteId';
    return _getRasps(url);
  }

  @override
  Future<List<Schedule>> getRaspsAudElementData(int? remoteId) async {
    final url = 'Rasp?idAudLine=$remoteId';
    return _getRasps(url);
  }

  @override
  Future<List<Schedule>> getRaspsProfElementData(int? remoteId) async {
    final url = 'Rasp?idTeacher=$remoteId';
    return _getRasps(url);
  }

  Future<List<Schedule>> _getRasps(String url) async {
    final response = await dio.get(url);
    final rasp = Rasp.fromJson(response.data);
    return rasp.data.rasp
        .map(
          (element) => Schedule(
            discipline: element.discipline,
            teacher: element.teacher,
            audience: element.audience,
            group: element.group,
            pair: element.numberOfJobs,
            dateTime: DateFormat('yyyy-MM-ddTHH:mm:ss').parseUTC(element.date),
            begin: element.beginning,
            end: element.end,
          ),
        )
        .toList();
  }
}
