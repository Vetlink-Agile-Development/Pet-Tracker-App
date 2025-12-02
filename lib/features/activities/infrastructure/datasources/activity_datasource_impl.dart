import 'package:dio/dio.dart';
import 'package:pet_tracker/config/config.dart';
import 'package:pet_tracker/features/activities/domain/entities/activity.dart';
import 'package:pet_tracker/features/activities/infrastructure/mappers/activity_mapper.dart';
import 'package:pet_tracker/shared/infrastructure/services/key_value_storage_service.dart';
import '../../domain/datasources/activity_datasource.dart';

class ActivityDatasourceImpl extends ActivityDatasource {
  final Dio dio;
  final KeyValueStorageService storageService;

  ActivityDatasourceImpl({
    Dio? dio,
    required this.storageService,
  }) : dio = dio ?? Dio(BaseOptions(baseUrl: Environment.apiUrl));

  @override
  Future<List<Activity>> getActivities(
    String deviceRecordId, {
    String? activityType,
    DateTime? from,
    DateTime? to,
    int page = 1,
    int pageSize = 20,
  }) async {
    final token = await storageService.getValue<String>('token');
    final selectedApiKey = await storageService.getValue<String>('selectedApiKey');

    final query = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
    };
    // Prefer snake_case query parameter matching DB/endpoint naming
    if (activityType != null) {
      query['activity_type'] = activityType;
    }
    if (from != null) query['from'] = from.toIso8601String();
    if (to != null) query['to'] = to.toIso8601String();

    // Authorization: prefer Bearer token, fallback to x-api-key if provided
    final headers = <String, String>{};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    } else if (selectedApiKey != null) {
      headers['x-api-key'] = selectedApiKey;
    }

    // (debug prints removed)

    final response = await dio.get(
      '/devices/$deviceRecordId/activities',
      queryParameters: query,
      options: Options(headers: headers),
    );

    // (debug prints removed)

    return (response.data as List)
        .map((json) => ActivityMapper.fromJson(json))
        .toList();
  }
}
