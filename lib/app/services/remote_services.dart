import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:project_cdis/app/data/audiences.dart';
import 'package:project_cdis/app/data/groups.dart';
import 'package:project_cdis/app/data/professors.dart';
import 'package:project_cdis/app/data/shedule.dart';

class RomoteServise {
  final Dio dio = Dio();
  final baseUrl = 'https://edu.donstu.ru/api/';

  Future<List<Audiences>> getAudiencesData() async {
    var url = 'raspAudlist';
    try {
      Response response = await dio.get(baseUrl + url);
      AudiencesData audiencesData = AudiencesData.fromJson(response.data);
      return audiencesData.data;
    } on DioError catch (e) {
      if (kDebugMode) {
        print(e);
      }
      rethrow;
    }
  }

  Future<List<Professors>> getProfessorsData() async {
    var url = 'raspTeacherlist';
    try {
      Response response = await dio.get(baseUrl + url);
      ProfessorsData professorsData = ProfessorsData.fromJson(response.data);
      return professorsData.data;
    } on DioError catch (e) {
      if (kDebugMode) {
        print(e);
      }
      rethrow;
    }
  }

  Future<List<Groups>> getGroupsData() async {
    var url = 'raspGrouplist';
    try {
      Response response = await dio.get(baseUrl + url);
      GroupsData groupsData = GroupsData.fromJson(response.data);
      return groupsData.data;
    } on DioError catch (e) {
      if (kDebugMode) {
        print(e);
      }
      rethrow;
    }
  }

  Future<Rasp> getRaspElementData() async {
    var url = 'Rasp?idGroup=${44424}';
    try {
      Response response = await dio.get(baseUrl + url);
      Rasp raspData = Rasp.fromJson(response.data);
      return raspData;
    } on DioError catch (e) {
      if (kDebugMode) {
        print(e);
      }
      rethrow;
    }
  }
}
