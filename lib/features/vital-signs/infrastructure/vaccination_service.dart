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

  Future<Vaccination> createVaccination(String deviceId, Map<String, dynamic> data) async {
    try {
      final response = await dio.post('/devices/$deviceId/vaccinations', data: data);
      return Vaccination.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Vaccination> updateVaccination(String deviceId, String vaccinationId, Map<String, dynamic> data) async {
    try {
      final response = await dio.put('/devices/$deviceId/vaccinations/$vaccinationId', data: data);
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