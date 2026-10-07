import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:ikms/data/models/db.dart';

/// Remote university schedule API client contract.
///
/// Each university implements this in its own folder under
/// `lib/data/universities/<slug>/`.
abstract class UniversityAPI {
  /// Shared Dio instance configured with retries and timeouts.
  final Dio dio;

  /// Stable catalog id matching [University.id] in Isar.
  final int universityId;

  /// Creates a client pointed at [baseUrl] for [universityId].
  UniversityAPI(this.universityId, String baseUrl) : dio = Dio() {
    dio.options
      ..baseUrl = baseUrl
      ..connectTimeout = const Duration(seconds: 60)
      ..receiveTimeout = const Duration(seconds: 60);
    dio.interceptors.addAll([
      RetryInterceptor(
        dio: dio,
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
  }

  /// Fetches the audience catalog (Isar ids must be composite).
  Future<List<AudienceSchedule>> getAudiencesData();

  /// Fetches the professors catalog (Isar ids must be composite).
  Future<List<TeacherSchedule>> getProfessorsData();

  /// Fetches the groups catalog (Isar ids must be composite).
  Future<List<GroupSchedule>> getGroupsData();

  /// Fetches lessons for a group **remote** id.
  Future<List<Schedule>> getRaspsGroupElementData(int? remoteId);

  /// Fetches lessons for an audience **remote** id.
  Future<List<Schedule>> getRaspsAudElementData(int? remoteId);

  /// Fetches lessons for a professor **remote** id.
  Future<List<Schedule>> getRaspsProfElementData(int? remoteId);
}
