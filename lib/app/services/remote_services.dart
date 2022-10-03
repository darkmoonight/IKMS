import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:project_cdis/app/data/audiences.dart';
import 'package:project_cdis/app/data/groups.dart';
import 'package:project_cdis/app/data/professors.dart';
import 'package:project_cdis/app/data/shedule.dart';

class RomoteServise {
  final Dio dio = Dio()
    ..interceptors.add(
      DioCacheInterceptor(
        options: CacheOptions(
          store: HiveCacheStore(Directory.systemTemp.path),
          maxStale: const Duration(days: 14),
          policy: CachePolicy.forceCache,
          priority: CachePriority.low,
        ),
      ),
    );
  final baseUrl = 'https://edu.donstu.ru/api/';
  final box = GetStorage();

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

  Future<List<RaspElement>> getRaspsElementData() async {
    final group = box.read('isGroups');
    var url = 'Rasp?idGroup=$group';
    try {
      Response response = await dio.get(baseUrl + url);
      Rasp rasp = Rasp.fromJson(response.data);
      return rasp.data.rasp;
    } on DioError catch (e) {
      if (kDebugMode) {
        print(e);
      }
      rethrow;
    }
  }

  Future<List<RaspElement>> getRaspsAudElementData(int id) async {
    var url = 'Rasp?idAudLine=$id';
    try {
      Response response = await dio.get(baseUrl + url);
      Rasp rasp = Rasp.fromJson(response.data);
      return rasp.data.rasp;
    } on DioError catch (e) {
      if (kDebugMode) {
        print(e);
      }
      rethrow;
    }
  }

  Future<List<RaspElement>> getRaspsProfElementData(int id) async {
    var url = 'Rasp?idTeacher=$id';
    try {
      Response response = await dio.get(baseUrl + url);
      Rasp rasp = Rasp.fromJson(response.data);
      return rasp.data.rasp;
    } on DioError catch (e) {
      if (kDebugMode) {
        print(e);
      }
      rethrow;
    }
  }
}
