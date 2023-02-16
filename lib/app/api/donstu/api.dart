import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:ikms/app/api/donstu/audiences.dart';
import 'package:ikms/app/api/donstu/groups.dart';
import 'package:ikms/app/api/donstu/professors.dart';
import 'package:ikms/app/data/schema.dart';
import 'package:ikms/app/api/donstu/shedule.dart';
import 'package:ikms/main.dart';

class DonstuAPI {
  final Dio dio = Dio()
    ..options.baseUrl = 'https://edu.donstu.ru/api/'
    ..options.connectTimeout = const Duration(seconds: 60)
    ..options.receiveTimeout = const Duration(seconds: 60)
    ..interceptors.add(RetryInterceptor(
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
    ));

  Future<List<AudienceSchedule>> getAudiencesData() async {
    var url = 'raspAudlist';
    try {
      Response response = await dio.get(url);
      AudiencesData audiencesData = AudiencesData.fromJson(response.data);
      return audiencesData.data
          .map((Audiences audiences) =>
              AudienceSchedule(id: audiences.id, name: audiences.name)
                ..university.value = donstu)
          .toList();
    } on DioError catch (e) {
      if (kDebugMode) {
        var statusCode = e.response?.statusCode;
        print(statusCode);
      }
      rethrow;
    }
  }

  Future<List<TeacherSchedule>> getProfessorsData() async {
    var url = 'raspTeacherlist';
    try {
      Response response = await dio.get(url);
      ProfessorsData professorsData = ProfessorsData.fromJson(response.data);
      return professorsData.data
          .map((Professors professors) =>
              TeacherSchedule(id: professors.id, name: professors.name)
                ..university.value = donstu)
          .toList();
    } on DioError catch (e) {
      if (kDebugMode) {
        var statusCode = e.response?.statusCode;
        print(statusCode);
      }
      rethrow;
    }
  }

  Future<List<GroupSchedule>> getGroupsData() async {
    var url = 'raspGrouplist';
    try {
      Response response = await dio.get(url);
      GroupsData groupsData = GroupsData.fromJson(response.data);
      return groupsData.data
          .map((Groups groups) =>
              GroupSchedule(id: groups.id, name: groups.name)
                ..university.value = donstu)
          .toList();
    } on DioError catch (e) {
      if (kDebugMode) {
        var statusCode = e.response?.statusCode;
        print(statusCode);
      }
      rethrow;
    }
  }

  Future<List<Schedule>> getRaspsGroupElementData(int? id) async {
    var url = 'Rasp?idGroup=$id';
    try {
      Response response = await dio.get(url);
      Rasp rasp = Rasp.fromJson(response.data);
      return rasp.data.rasp
          .map((RaspElement element) => Schedule(
              discipline: element.discipline,
              teacher: element.teacher,
              audience: element.audience,
              group: element.group,
              pair: element.numberOfJobs,
              dateTime:
                  DateFormat("yyyy-MM-ddThh:mm:ss").parseUTC(element.date),
              begin: element.beginning,
              end: element.end))
          .toList();
    } on DioError catch (e) {
      if (kDebugMode) {
        var statusCode = e.response?.statusCode;
        print(statusCode);
      }
      rethrow;
    }
  }

  Future<List<Schedule>> getRaspsAudElementData(int? id) async {
    var url = 'Rasp?idAudLine=$id';
    try {
      Response response = await dio.get(url);
      Rasp rasp = Rasp.fromJson(response.data);
      return rasp.data.rasp
          .map((RaspElement element) => Schedule(
              discipline: element.discipline,
              teacher: element.teacher,
              audience: element.audience,
              group: element.group,
              pair: element.numberOfJobs,
              dateTime:
                  DateFormat("yyyy-MM-ddThh:mm:ss").parseUTC(element.date),
              begin: element.beginning,
              end: element.end))
          .toList();
    } on DioError catch (e) {
      if (kDebugMode) {
        var statusCode = e.response?.statusCode;
        print(statusCode);
      }
      rethrow;
    }
  }

  Future<List<Schedule>> getRaspsProfElementData(int? id) async {
    var url = 'Rasp?idTeacher=$id';
    try {
      Response response = await dio.get(url);
      Rasp rasp = Rasp.fromJson(response.data);
      return rasp.data.rasp
          .map((RaspElement element) => Schedule(
              discipline: element.discipline,
              teacher: element.teacher,
              audience: element.audience,
              group: element.group,
              pair: element.numberOfJobs,
              dateTime:
                  DateFormat("yyyy-MM-ddThh:mm:ss").parseUTC(element.date),
              begin: element.beginning,
              end: element.end))
          .toList();
    } on DioError catch (e) {
      if (kDebugMode) {
        var statusCode = e.response?.statusCode;
        print(statusCode);
      }
      rethrow;
    }
  }
}
