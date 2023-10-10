import 'package:flutter/foundation.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:ikms/app/api/donstu/api.dart';
import 'package:ikms/app/data/schema.dart';
import 'package:ikms/main.dart';

class DonstuCaching {
  static Future<bool> cacheAudiences() async {
    final dif = DateTime.now().difference(donstu.lastUpdateAudiences).inMinutes;
    if (donstu.audiences.isNotEmpty && dif < 90) {
      return true;
    }
    try {
      final t = await DonstuAPI().getAudiencesData();
      final v = donstu.audiences.toList();
      final it = t.map((e) => e.id).toList();
      final iv = v.map((e) => e.id).toList();
      final g = t.toList()..removeWhere((e) => iv.contains(e.id)); // new
      final c = t.toList()..removeWhere((e) => !iv.contains(e.id)); // cached
      final o = v.toList()..removeWhere((e) => it.contains(e.id)); // old

      isar.writeTxnSync(() {
        isar.audienceSchedules.deleteAllSync((o + g).map((e) => e.id).toList());
        isar.audienceSchedules.putAllSync(c + g);
        donstu.audiences.addAll(c + g);
        donstu.audiences.saveSync();
        donstu.lastUpdateAudiences = DateTime.now();
        isar.universitys.putSync(donstu);
      });
      return true;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return false;
    }
  }

  static Future<bool> cacheGroups() async {
    final dif = DateTime.now().difference(donstu.lastUpdateGroups).inMinutes;
    if (donstu.groups.isNotEmpty && dif < 90) {
      return true;
    }
    try {
      final t = await DonstuAPI().getGroupsData();
      final v = donstu.groups.toList();
      final it = t.map((e) => e.id).toList();
      final iv = v.map((e) => e.id).toList();
      final g = t.toList()..removeWhere((e) => iv.contains(e.id)); // new
      final c = t.toList()..removeWhere((e) => !iv.contains(e.id)); // cached
      final o = v.toList()..removeWhere((e) => it.contains(e.id)); // old

      isar.writeTxnSync(() {
        isar.groupSchedules.deleteAllSync((o + g).map((e) => e.id).toList());
        isar.groupSchedules.putAllSync(c + g);
        donstu.groups.addAll(c + g);
        donstu.groups.saveSync();
        donstu.lastUpdateGroups = DateTime.now();
        isar.universitys.putSync(donstu);
      });
      return true;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return false;
    }
  }

  static Future<bool> cacheTeachers() async {
    final dif = DateTime.now().difference(donstu.lastUpdateTeachers).inMinutes;
    if (donstu.teachers.isNotEmpty && dif < 90) {
      return true;
    }
    try {
      final t = await DonstuAPI().getProfessorsData();
      final v = donstu.teachers.toList();
      final it = t.map((e) => e.id).toList();
      final iv = v.map((e) => e.id).toList();
      final g = t.toList()..removeWhere((e) => iv.contains(e.id)); // new
      final c = t.toList()..removeWhere((e) => !iv.contains(e.id)); // cached
      final o = v.toList()..removeWhere((e) => it.contains(e.id)); // old

      isar.writeTxnSync(() {
        isar.teacherSchedules.deleteAllSync((o + g).map((e) => e.id).toList());
        isar.teacherSchedules.putAllSync(c + g);
        donstu.teachers.addAll(c + g);
        donstu.teachers.saveSync();
        donstu.lastUpdateTeachers = DateTime.now();
        isar.universitys.putSync(donstu);
      });
      return true;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return false;
    }
  }

  static Future<AudienceSchedule> cacheAudienceSchedule(
      AudienceSchedule t) async {
    if ((DateTime.now().difference(t.lastUpdate).inMinutes > 90 ||
            t.schedules.isEmpty) &&
        await isOnline.value) {
      try {
        final l = await DonstuAPI().getRaspsAudElementData(t.id);

        isar.writeTxnSync(() {
          t.lastUpdate = DateTime.now();
          t.schedules = l;
          isar.audienceSchedules.putSync(t);
        });
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
        EasyLoading.showInfo('no_internet'.tr);
      }
    }
    return t;
  }

  static Future<GroupSchedule> cacheGroupSchedule(GroupSchedule t) async {
    if ((DateTime.now().difference(t.lastUpdate).inMinutes > 90 ||
            t.schedules.isEmpty) &&
        await isOnline.value) {
      try {
        final l = await DonstuAPI().getRaspsGroupElementData(t.id);

        isar.writeTxnSync(() {
          t.lastUpdate = DateTime.now();
          t.schedules = l;
          isar.groupSchedules.putSync(t);
        });
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
        EasyLoading.showInfo('no_internet'.tr);
      }
    }
    return t;
  }

  static Future<TeacherSchedule> cacheTeacherSchedule(TeacherSchedule t) async {
    if ((DateTime.now().difference(t.lastUpdate).inMinutes > 90 ||
            t.schedules.isEmpty) &&
        await isOnline.value) {
      try {
        final l = await DonstuAPI().getRaspsProfElementData(t.id);

        isar.writeTxnSync(() {
          t.lastUpdate = DateTime.now();
          t.schedules = l;
          isar.teacherSchedules.putSync(t);
        });
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
        EasyLoading.showInfo('no_internet'.tr);
      }
    }
    return t;
  }
}
