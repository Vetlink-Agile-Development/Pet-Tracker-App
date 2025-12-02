import 'dart:convert';
import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:pet_tracker/config/consts/environments.dart';
import 'package:pet_tracker/features/vital-signs/domain/datasources/health_summary_datasource.dart';
import 'package:pet_tracker/features/vital-signs/domain/entities/health_summary.dart';
import 'package:pet_tracker/features/vital-signs/infrastructure/mappers/health_summary_mapper.dart';
import 'package:pet_tracker/shared/infrastructure/services/key_value_storage_service.dart';

class HealthSummaryDatasourceImpl implements HealthSummaryDatasource {
  final Dio dio;
  final KeyValueStorageService storageService;

  HealthSummaryDatasourceImpl({
    required this.storageService,
    Dio? dio,
  }) : dio = dio ??
            Dio(BaseOptions(
              baseUrl: Environment.apiUrl,
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json'
              },
            ));

  @override
  Future<List<HealthSummary>> fetchHealthSummary(String deviceRecordId, {DateTime? month}) async {
    try {
      final token = await storageService.getValue<String>('token');
      if (token == null) {
        developer.log('Token not found', name: 'HealthSummaryDatasource');
        throw Exception('Token not found');
      }

      final params = <String, dynamic>{};
      if (month != null) {
        params['year'] = month.year.toString();
        params['month'] = month.month.toString();
      }

      // Try the documented singular path first, but some deployments expose the
      // plural 'health-measures-monthly-summary'. If the first call returns a
      // resource-not-found/500 indicating the route isn't available, retry the
      // alternative path so the app is resilient to server differences.
      Response response;
      String pathSingular = '/devices/$deviceRecordId/health-measure-monthly-summary';
      String pathPlural = '/devices/$deviceRecordId/health-measures-monthly-summary';

      try {
        response = await dio.get(
          pathSingular,
          queryParameters: params.isEmpty ? null : params,
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        );
      } on DioException catch (e) {
        final status = e.response?.statusCode;
        final body = e.response?.data?.toString() ?? e.message;
        developer.log('First attempt failed: $status - $body', name: 'HealthSummaryDatasource');

        // If server indicates the resource doesn't exist, retry with plural path.
        final shouldTryPlural = (status == 404) || (status == 500 && (body != null && body.contains('No static resource')));
        if (shouldTryPlural) {
          try {
            response = await dio.get(
              pathPlural,
              queryParameters: params.isEmpty ? null : params,
              options: Options(headers: {'Authorization': 'Bearer $token'}),
            );
          } on DioException catch (e2) {
            developer.log('Retry with plural path failed: ${e2.response?.statusCode} - ${e2.response?.data ?? e2.message}', name: 'HealthSummaryDatasource');
            throw Exception('Error fetching health summary: ${e2.response?.data ?? e2.message}');
          }
        } else {
          // Not a resource-not-found case: rethrow with the original error details.
          throw Exception('Error fetching health summary: ${e.response?.data ?? e.message}');
        }
      }

      developer.log('Health summary fetched successfully: ${response.data}', name: 'HealthSummaryDatasource');

      return (response.data as List)
          .map((item) => HealthSummaryMapper.fromJson(item))
          .toList();
    } on DioException catch (e) {
      developer.log('Error fetching health summary: ${e.response?.data ?? e.message}', name: 'HealthSummaryDatasource');
      throw Exception('Error fetching health summary: ${e.response?.data ?? e.message}');
    }
  }

  @override
  Future<List<HealthSummary>> fetchHealthPrediction(
      String deviceRecordId) async {
    try {
      final token = await storageService.getValue<String>('token');
      if (token == null) {
        developer.log('Token not found', name: 'HealthSummaryDatasource');
        throw Exception('Token not found');
      }

      final response = await dio.post(
        Environment.predictionServiceUrl,
        data: {'petTrackerDeviceRecordId': deviceRecordId},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          responseType: ResponseType.plain,
        ),
      );

      developer.log('Raw response (String): ${response.data}', name: 'HealthSummaryDatasource');

      final List<dynamic> jsonList = jsonDecode(response.data);

      return jsonList
          .map((item) => HealthSummaryMapper.fromJson(item))
          .toList();
    } on DioException catch (e) {
      developer.log('Error fetching health summary: ${e.response?.data ?? e.message}', name: 'HealthSummaryDatasource');
      throw Exception('Error fetching health summary: ${e.response?.data ?? e.message}');
    }
  }
}
