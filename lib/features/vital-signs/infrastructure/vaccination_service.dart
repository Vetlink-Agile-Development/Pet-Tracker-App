import 'package:dio/dio.dart';
import '../domain/models/vaccination.dart';

class VaccinationService {
  final Dio dio;
  VaccinationService(this.dio);

  Future<List<Vaccination>> getVaccinationsByDeviceId(String deviceId) async {
    try {
      final response = await dio.get('/devices/$deviceId/vaccinations');
      final data = response.data as List;
      return data.map((e) => Vaccination.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Vaccination> createVaccination(
    String deviceId, {
    required String vaccineName,
    required String dateAdministered,
    String? batch,
    String? veterinarian,
    String? nextDueDate,
    String? observations,
    MultipartFile? image,
  }) async {
    try {
      final formData = FormData();
      formData.fields.addAll([
        MapEntry('vaccineName', vaccineName),
        MapEntry('dateAdministered', dateAdministered),
      ]);
      
      if (batch != null && batch.isNotEmpty) {
        formData.fields.add(MapEntry('batch', batch));
      }
      
      if (veterinarian != null && veterinarian.isNotEmpty) {
        formData.fields.add(MapEntry('veterinarian', veterinarian));
      }
      
      if (nextDueDate != null && nextDueDate.isNotEmpty) {
        formData.fields.add(MapEntry('nextDueDate', nextDueDate));
      }
      
      if (observations != null && observations.isNotEmpty) {
        formData.fields.add(MapEntry('observations', observations));
      }
      
      if (image != null) {
        formData.files.add(MapEntry('image', image));
      }

      final response = await dio.post(
        '/devices/$deviceId/vaccinations',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );
      return Vaccination.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Vaccination> updateVaccination(
    String deviceId,
    String vaccinationId, {
    required String vaccineName,
    required String dateAdministered,
    String? batch,
    String? veterinarian,
    String? nextDueDate,
    String? observations,
    MultipartFile? image,
  }) async {
    try {
      final formData = FormData();
      formData.fields.addAll([
        MapEntry('vaccineName', vaccineName),
        MapEntry('dateAdministered', dateAdministered),
      ]);
      
      if (batch != null && batch.isNotEmpty) {
        formData.fields.add(MapEntry('batch', batch));
      }
      
      if (veterinarian != null && veterinarian.isNotEmpty) {
        formData.fields.add(MapEntry('veterinarian', veterinarian));
      }
      
      if (nextDueDate != null && nextDueDate.isNotEmpty) {
        formData.fields.add(MapEntry('nextDueDate', nextDueDate));
      }
      
      if (observations != null && observations.isNotEmpty) {
        formData.fields.add(MapEntry('observations', observations));
      }
      
      if (image != null) {
        formData.files.add(MapEntry('image', image));
      }

      final response = await dio.put(
        '/devices/$deviceId/vaccinations/$vaccinationId',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );
      return Vaccination.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteVaccination(String deviceId, String vaccinationId) async {
    try {
      await dio.delete('/devices/$deviceId/vaccinations/$vaccinationId');
    } catch (e) {
      rethrow;
    }
  }
}