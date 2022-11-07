import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:project_cdis/app/api/donstu/audiences.dart';
import 'package:project_cdis/app/api/donstu/groups.dart';
import 'package:project_cdis/app/api/donstu/professors.dart';
import 'package:project_cdis/app/data/schema.dart';
import 'package:project_cdis/app/api/donstu/shedule.dart';
import 'package:project_cdis/main.dart';

class DonstuAPI {
  final Dio dio = Dio();
  final baseUrl = 'https://edu.donstu.ru/api/';

  Future<List<AudienceSchedule>> getAudiencesData() async {
    var url = 'raspAudlist';
    try {
      Response response = await dio.get(baseUrl + url);
      AudiencesData audiencesData = AudiencesData.fromJson(response.data);
      return audiencesData.data
          .map((Audiences audiences) =>
              AudienceSchedule(id: audiences.id, name: audiences.name)
                ..university.value = donstu)
          .toList();
    } on DioError catch (e) {
      if (kDebugMode) {
        print(e);
      }
      rethrow;
    }
  }

  Future<List<TeacherSchedule>> getProfessorsData() async {
    var url = 'raspTeacherlist';
    try {
      Response response = await dio.get(baseUrl + url);
      ProfessorsData professorsData = ProfessorsData.fromJson(response.data);
      return professorsData.data
          .map((Professors professors) =>
              TeacherSchedule(id: professors.id, name: professors.name)
                ..university.value = donstu)
          .toList();
    } on DioError catch (e) {
      if (kDebugMode) {
        print(e);
      }
      rethrow;
    }
  }

  Future<List<GroupSchedule>> getGroupsData() async {
    var url = 'raspGrouplist';
    try {
      Response response = await dio.get(baseUrl + url);
      GroupsData groupsData = GroupsData.fromJson(response.data);
      return groupsData.data
          .map((Groups groups) =>
              GroupSchedule(id: groups.id, name: groups.name)
                ..university.value = donstu)
          .toList();
    } on DioError catch (e) {
      if (kDebugMode) {
        print(e);
      }
      rethrow;
    }
  }

  Future<List<Schedule>> getRaspsGroupElementData(int? id) async {
    var url = 'Rasp?idGroup=$id';
    try {
      Response response = await dio.get(baseUrl + url);
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
        print(e);
      }
      rethrow;
    }
  }

  Future<List<Schedule>> getRaspsAudElementData(int? id) async {
    var url = 'Rasp?idAudLine=$id';
    try {
      Response response = await dio.get(baseUrl + url);
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
        print(e);
      }
      rethrow;
    }
  }

  Future<List<Schedule>> getRaspsProfElementData(int? id) async {
    var url = 'Rasp?idTeacher=$id';
    try {
      Response response = await dio.get(baseUrl + url);
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
        print(e);
      }
      rethrow;
    }
  }
}
