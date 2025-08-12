import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart' as tr;
import 'package:intl/intl.dart';
import 'package:ikms/app/api/donstu/audiences.dart';
import 'package:ikms/app/api/donstu/groups.dart';
import 'package:ikms/app/api/donstu/professors.dart';
import 'package:ikms/app/data/db.dart';
import 'package:ikms/app/api/donstu/shedule.dart';
import 'package:ikms/main.dart';

class DonstuAPI {
  final Dio dio = Dio()
    ..options.baseUrl = 'https://edu.donstu.ru/api/'
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

  Future<List<AudienceSchedule>> getAudiencesData() async {
    var url = 'raspAudlist';
    try {
      Response response = await dio.get(url);
      AudiencesData audiencesData = AudiencesData.fromJson(response.data);
      if (audiencesData.data.isEmpty) {
        EasyLoading.showInfo('no_rasp'.tr);
        return [];
      }
      return audiencesData.data
          .map(
            (Audiences audiences) =>
                AudienceSchedule(id: audiences.id, name: audiences.name)
                  ..university.value = donstu,
          )
          .toList();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        EasyLoading.showError('no_internet'.tr);
      } else {
        EasyLoading.showError('error'.tr);
      }
      rethrow;
    }
  }

  Future<List<TeacherSchedule>> getProfessorsData() async {
    var url = 'raspTeacherlist';
    try {
      Response response = await dio.get(url);
      ProfessorsData professorsData = ProfessorsData.fromJson(response.data);
      if (professorsData.data.isEmpty) {
        EasyLoading.showInfo('no_rasp'.tr);
        return [];
      }
      return professorsData.data
          .map(
            (Professors professors) =>
                TeacherSchedule(id: professors.id, name: professors.name)
                  ..university.value = donstu,
          )
          .toList();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        EasyLoading.showError('no_internet'.tr);
      } else {
        EasyLoading.showError('error'.tr);
      }
      rethrow;
    }
  }

  Future<List<GroupSchedule>> getGroupsData() async {
    var url = 'raspGrouplist';
    try {
      Response response = await dio.get(url);
      GroupsData groupsData = GroupsData.fromJson(response.data);
      if (groupsData.data.isEmpty) {
        EasyLoading.showInfo('no_rasp'.tr);
        return [];
      }
      return groupsData.data
          .map(
            (Groups groups) =>
                GroupSchedule(id: groups.id, name: groups.name)
                  ..university.value = donstu,
          )
          .toList();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        EasyLoading.showError('no_internet'.tr);
      } else {
        EasyLoading.showError('error'.tr);
      }
      rethrow;
    }
  }

  Future<List<Schedule>> getRaspsGroupElementData(int? id) async {
    var url = 'Rasp?idGroup=$id';
    try {
      Response response = await dio.get(url);
      Rasp rasp = Rasp.fromJson(response.data);
      if (rasp.data.rasp.isEmpty) {
        EasyLoading.showInfo('no_rasp'.tr);
        return [];
      }
      return rasp.data.rasp
          .map(
            (RaspElement element) => Schedule(
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
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        EasyLoading.showError('no_internet'.tr);
      } else {
        EasyLoading.showError('error'.tr);
      }
      rethrow;
    }
  }

  Future<List<Schedule>> getRaspsAudElementData(int? id) async {
    var url = 'Rasp?idAudLine=$id';
    try {
      Response response = await dio.get(url);
      Rasp rasp = Rasp.fromJson(response.data);
      if (rasp.data.rasp.isEmpty) {
        EasyLoading.showInfo('no_rasp'.tr);
        return [];
      }
      return rasp.data.rasp
          .map(
            (RaspElement element) => Schedule(
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
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        EasyLoading.showError('no_internet'.tr);
      } else {
        EasyLoading.showError('error'.tr);
      }
      rethrow;
    }
  }

  Future<List<Schedule>> getRaspsProfElementData(int? id) async {
    var url = 'Rasp?idTeacher=$id';
    try {
      Response response = await dio.get(url);
      Rasp rasp = Rasp.fromJson(response.data);
      if (rasp.data.rasp.isEmpty) {
        EasyLoading.showInfo('no_rasp'.tr);
        return [];
      }
      return rasp.data.rasp
          .map(
            (RaspElement element) => Schedule(
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
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        EasyLoading.showError('no_internet'.tr);
      } else {
        EasyLoading.showError('error'.tr);
      }
      rethrow;
    }
  }
}
