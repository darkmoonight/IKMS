import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart' as tr;
import 'package:intl/intl.dart';
import 'package:ikms/app/api/audiences.dart';
import 'package:ikms/app/api/groups.dart';
import 'package:ikms/app/api/professors.dart';
import 'package:ikms/app/api/schedule.dart';
import 'package:ikms/app/data/db.dart';

abstract class UniversityAPI {
  final Dio dio;

  UniversityAPI(String baseUrl)
    : dio = Dio()
        ..options.baseUrl = baseUrl
        ..options.connectTimeout = const Duration(seconds: 60)
        ..options.receiveTimeout = const Duration(seconds: 60)
        ..interceptors.addAll([
          RetryInterceptor(
            dio: Dio(),
            logPrint: print,
            retries: 4,
            retryableExtraStatuses: {104},
            retryDelays: const [
              Duration(seconds: 1),
              Duration(seconds: 2),
              Duration(seconds: 3),
              Duration(seconds: 4),
            ],
          ),
          InterceptorsWrapper(
            onError: (error, handler) {
              handler.reject(error);
            },
          ),
        ]);

  Future<List<AudienceSchedule>> getAudiencesData();
  Future<List<TeacherSchedule>> getProfessorsData();
  Future<List<GroupSchedule>> getGroupsData();
  Future<List<Schedule>> getRaspsGroupElementData(int? id);
  Future<List<Schedule>> getRaspsAudElementData(int? id);
  Future<List<Schedule>> getRaspsProfElementData(int? id);
}

class DonstuAPI extends UniversityAPI {
  DonstuAPI() : super('https://edu.donstu.ru/api/');

  @override
  Future<List<AudienceSchedule>> getAudiencesData() async {
    const url = 'raspAudlist';
    try {
      final response = await dio.get(url);
      final audiencesData = AudiencesData.fromJson(response.data);
      if (audiencesData.data.isEmpty) {
        EasyLoading.showInfo('no_rasp'.tr);
        return [];
      }
      return audiencesData.data
          .map(
            (audiences) =>
                AudienceSchedule(id: audiences.id, name: audiences.name),
          )
          .toList();
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  @override
  Future<List<TeacherSchedule>> getProfessorsData() async {
    const url = 'raspTeacherlist';
    try {
      final response = await dio.get(url);
      final professorsData = ProfessorsData.fromJson(response.data);
      if (professorsData.data.isEmpty) {
        EasyLoading.showInfo('no_rasp'.tr);
        return [];
      }
      return professorsData.data
          .map(
            (professors) =>
                TeacherSchedule(id: professors.id, name: professors.name),
          )
          .toList();
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  @override
  Future<List<GroupSchedule>> getGroupsData() async {
    const url = 'raspGrouplist';
    try {
      final response = await dio.get(url);
      final groupsData = GroupsData.fromJson(response.data);
      if (groupsData.data.isEmpty) {
        EasyLoading.showInfo('no_rasp'.tr);
        return [];
      }
      return groupsData.data
          .map((groups) => GroupSchedule(id: groups.id, name: groups.name))
          .toList();
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  @override
  Future<List<Schedule>> getRaspsGroupElementData(int? id) async {
    final url = 'Rasp?idGroup=$id';
    return _getRasps(url);
  }

  @override
  Future<List<Schedule>> getRaspsAudElementData(int? id) async {
    final url = 'Rasp?idAudLine=$id';
    return _getRasps(url);
  }

  @override
  Future<List<Schedule>> getRaspsProfElementData(int? id) async {
    final url = 'Rasp?idTeacher=$id';
    return _getRasps(url);
  }

  Future<List<Schedule>> _getRasps(String url) async {
    try {
      final response = await dio.get(url);
      final rasp = Rasp.fromJson(response.data);
      if (rasp.data.rasp.isEmpty) {
        EasyLoading.showInfo('no_rasp'.tr);
        return [];
      }
      return rasp.data.rasp
          .map(
            (element) => Schedule(
              discipline: element.discipline,
              teacher: element.teacher,
              audience: element.audience,
              group: element.group,
              pair: element.numberOfJobs,
              dateTime: DateFormat(
                'yyyy-MM-ddThh:mm:ss',
              ).parseUTC(element.date),
              begin: element.beginning,
              end: element.end,
            ),
          )
          .toList();
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  void _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      EasyLoading.showError('no_internet'.tr);
    } else {
      EasyLoading.showError('error'.tr);
    }
  }
}

// To add a new university, create a new class like:
// class NewUniAPI extends UniversityAPI {
//   NewUniAPI() : super('https://newuni.api/');
//   // Override methods with new endpoints and models if needed
// }
