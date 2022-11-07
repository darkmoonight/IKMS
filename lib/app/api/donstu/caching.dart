import 'package:flutter/foundation.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:project_cdis/app/api/donstu/api.dart';
import 'package:project_cdis/app/data/schema.dart';
import 'package:project_cdis/main.dart';

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

      await isar.writeTxn(() async {
        await isar.audienceSchedules
            .deleteAll((o + g).map((e) => e.id).toList());
        await isar.audienceSchedules.putAll(c + g);
        donstu.audiences.addAll(c + g);
        await donstu.audiences.save();
        donstu.lastUpdateAudiences = DateTime.now();
        await isar.universitys.put(donstu);
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

      await isar.writeTxn(() async {
        await isar.groupSchedules.deleteAll((o + g).map((e) => e.id).toList());
        await isar.groupSchedules.putAll(c + g);
        donstu.groups.addAll(c + g);
        await donstu.groups.save();
        donstu.lastUpdateGroups = DateTime.now();
        await isar.universitys.put(donstu);
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

      await isar.writeTxn(() async {
        await isar.teacherSchedules
            .deleteAll((o + g).map((e) => e.id).toList());
        await isar.teacherSchedules.putAll(c + g);
        donstu.teachers.addAll(c + g);
        await donstu.teachers.save();
        donstu.lastUpdateTeachers = DateTime.now();
        await isar.universitys.put(donstu);
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
    if (DateTime.now().difference(t.lastUpdate).inMinutes > 90 ||
        t.schedules.isEmpty) {
      try {
        final l = await DonstuAPI().getRaspsAudElementData(t.id);

        await isar.writeTxn(() async {
          t.lastUpdate = DateTime.now();
          t.schedules = l;
          await isar.audienceSchedules.put(t);
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
    if (DateTime.now().difference(t.lastUpdate).inMinutes > 90 ||
        t.schedules.isEmpty) {
      try {
        final l = await DonstuAPI().getRaspsGroupElementData(t.id);

        await isar.writeTxn(() async {
          t.lastUpdate = DateTime.now();
          t.schedules = l;
          await isar.groupSchedules.put(t);
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
    if (DateTime.now().difference(t.lastUpdate).inMinutes > 90 ||
        t.schedules.isEmpty) {
      try {
        final l = await DonstuAPI().getRaspsProfElementData(t.id);

        await isar.writeTxn(() async {
          t.lastUpdate = DateTime.now();
          t.schedules = l;
          await isar.teacherSchedules.put(t);
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
