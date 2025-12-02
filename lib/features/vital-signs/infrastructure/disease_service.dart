import 'package:dio/dio.dart';
import '../domain/models/disease.dart';

class DiseaseService {
  final Dio dio;
  DiseaseService(this.dio);

  Future<List<Disease>> getDiseasesByDeviceId(String deviceId) async {
    try {
      final response = await dio.get('/devices/$deviceId/diseases');
      final data = response.data as List;
      return data.map((e) => Disease.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Disease> createDisease(String deviceId, dynamic data) async {
    try {
      final response = await dio.post('/devices/$deviceId/diseases', data: data);
      return Disease.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Disease> updateDisease(String deviceId, String diseaseId, dynamic data) async {
    try {
      final response = await dio.put('/devices/$deviceId/diseases/$diseaseId', data: data);
      return Disease.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteDisease(String deviceId, String diseaseId) async {
    try {
      await dio.delete('/devices/$deviceId/diseases/$diseaseId');
    } catch (e) {
      rethrow;
    }
  }
}
