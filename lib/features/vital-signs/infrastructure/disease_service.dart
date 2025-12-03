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

  Future<Disease> createDisease(
    String deviceId, {
    required String name,
    required String diagnosisDate,
    required String symptoms,
    required String treatment,
    String? observations,
    MultipartFile? image,
  }) async {
    try {
      final formData = FormData();
      formData.fields.addAll([
        MapEntry('name', name),
        MapEntry('diagnosisDate', diagnosisDate),
        MapEntry('symptoms', symptoms),
        MapEntry('treatment', treatment),
      ]);
      
      if (observations != null && observations.isNotEmpty) {
        formData.fields.add(MapEntry('observations', observations));
      }
      
      if (image != null) {
        formData.files.add(MapEntry('image', image));
      }

      final response = await dio.post(
        '/devices/$deviceId/diseases',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );
      return Disease.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Disease> updateDisease(
    String deviceId,
    String diseaseId, {
    required String name,
    required String diagnosisDate,
    required String symptoms,
    required String treatment,
    String? observations,
    MultipartFile? image,
  }) async {
    try {
      final formData = FormData();
      formData.fields.addAll([
        MapEntry('name', name),
        MapEntry('diagnosisDate', diagnosisDate),
        MapEntry('symptoms', symptoms),
        MapEntry('treatment', treatment),
      ]);
      
      if (observations != null && observations.isNotEmpty) {
        formData.fields.add(MapEntry('observations', observations));
      }
      
      if (image != null) {
        formData.files.add(MapEntry('image', image));
      }

      final response = await dio.put(
        '/devices/$deviceId/diseases/$diseaseId',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );
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
