import 'package:dio/dio.dart';
import 'dart:developer' as developer;
import 'package:pet_tracker/config/consts/environments.dart';
import 'package:pet_tracker/features/geofences/domain/entities/geofence.dart';
import 'package:pet_tracker/features/geofences/domain/datasources/geofence_datasource.dart';
import 'package:pet_tracker/features/geofences/infrastructure/mappers/geofence_mapper.dart';
import 'package:pet_tracker/shared/infrastructure/services/key_value_storage_service.dart';

class GeofenceDatasourceImpl implements GeofenceDatasource {
  final Dio dio;
  final KeyValueStorageService storageService;

  GeofenceDatasourceImpl({
    required this.storageService,
    Dio? dio,
  }) : dio = dio ?? Dio(BaseOptions(
    baseUrl: Environment.apiUrl,
    headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
  ));

  @override
  Future<Geofence> createGeofence(Geofence geofence) async {
    try {
      final token = await storageService.getValue<String>('token');
      if (token == null) {
        developer.log('Token not found', name: 'GeofenceDatasource');
        throw Exception('Token not found');
      }

      final userId = await storageService.getValue<String>('userId');
      if (userId == null) {
        developer.log('User ID not found', name: 'GeofenceDatasource');
        throw Exception('User ID not found');
      }

      final data = {
        'name': geofence.name,
        'geoFenceStatus': geofence.geoFenceStatus,
        'coordinates': geofence.coordinates
            .map((coord) => {
                  'latitude': coord.latitude,
                  'longitude': coord.longitude,
                })
            .toList(),
        'petTrackerDeviceRecordId': geofence.petTrackerDeviceRecordId,
        'userId': userId,
      };

      final response = await dio.post(
        '/geo-fences',
        data: data,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return GeofenceMapper.fromJson(response.data);
    } on DioException catch (e) {
      developer.log('Error creating geofence: ${e.response?.data ?? e.message}', name: 'GeofenceDatasource');
      throw Exception('Error creating geofence: ${e.response?.data ?? e.message}');
    }
  }

  @override
  Future<List<Geofence>> fetchGeofences(String selectedDeviceRecordId) async {
    try {
      final token = await storageService.getValue<String>('token');
      if (token == null) {
        developer.log('Token not found', name: 'GeofenceDatasource');
        throw Exception('Token not found');
      }

      final userId = await storageService.getValue<String>('userId');
      if (userId == null) {
        developer.log('User ID not found', name: 'GeofenceDatasource');
        throw Exception('User ID not found');
      }

      final response = await dio.get(
        '/devices/$selectedDeviceRecordId/geo-fences',
        queryParameters: {'userId': userId},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return (response.data as List)
          .map((data) => GeofenceMapper.fromJson(data))
          .toList();
    } on DioException catch (e) {
      developer.log('Error fetching geofences: ${e.response?.data ?? e.message}', name: 'GeofenceDatasource');
      throw Exception('Error fetching geofences: ${e.response?.data ?? e.message}');
    }
  }

  @override
  Future<Geofence> updateGeofence(Geofence geofence) async {
    try {
      final token = await storageService.getValue<String>('token');
      if (token == null) {
        developer.log('Token not found', name: 'GeofenceDatasource');
        throw Exception('Token not found');
      }

      final userId = await storageService.getValue<String>('userId');
      if (userId == null) {
        developer.log('User ID not found', name: 'GeofenceDatasource');
        throw Exception('User ID not found');
      }

      final data = {
        'name': geofence.name,
        'geoFenceStatus': geofence.geoFenceStatus,
        'coordinates': geofence.coordinates
            .map((coord) => {
                  'latitude': coord.latitude,
                  'longitude': coord.longitude,
                })
            .toList(),
        'petTrackerDeviceRecordId': geofence.petTrackerDeviceRecordId,
        'userId': userId,
      };

      final response = await dio.put(
        '/geo-fences/${geofence.id}',
        data: data,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return GeofenceMapper.fromJson(response.data);
    } on DioException catch (e) {
      developer.log('Error updating geofence: ${e.response?.data ?? e.message}', name: 'GeofenceDatasource');
      throw Exception('Error updating geofence: ${e.response?.data ?? e.message}');
    }
  }
  
  @override
  Future<void> deleteGeofence(int geofenceId) async {
    try {
      final token = await storageService.getValue<String>('token');
        if (token == null) {
        developer.log('Token not found', name: 'GeofenceDatasource');
        throw Exception('Token not found');
      }
      await dio.delete(
        '/geo-fences/$geofenceId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      throw Exception('Error deleting geofence: ${e.response?.data ?? e.message}');
    }
  }
}
