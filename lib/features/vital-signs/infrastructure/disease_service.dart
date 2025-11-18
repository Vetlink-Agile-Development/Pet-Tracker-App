import 'package:dio/dio.dart';
import '../domain/models/disease.dart';

class DiseaseService {
  final Dio dio;
  DiseaseService(this.dio);

  Future<List<Disease>> getDiseasesByPetId(String petId) async {
    try {
      final response = await dio.get('/pets/$petId/diseases');
      final data = response.data as List;
      return data.map((e) => Disease.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Disease> createDisease(String petId, Map<String, dynamic> data) async {
    try {
      final response = await dio.post('/pets/$petId/diseases', data: data);
      return Disease.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Disease> updateDisease(String petId, String diseaseId, Map<String, dynamic> data) async {
    try {
      final response = await dio.put('/pets/$petId/diseases/$diseaseId', data: data);
      return Disease.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteDisease(String petId, String diseaseId) async {
    try {
      await dio.delete('/pets/$petId/diseases/$diseaseId');
    } catch (e) {
      rethrow;
    }
  }
}
