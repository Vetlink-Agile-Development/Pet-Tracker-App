import 'package:dio/dio.dart';
import '../domain/models/deworming.dart';

class DewormingService {
  final Dio dio;
  DewormingService(this.dio);

  Future<List<Deworming>> getDewormingsByDeviceId(String deviceId) async {
    try {
      final response = await dio.get('/devices/$deviceId/dewormings');
      final data = response.data as List;
      return data.map((e) => Deworming.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Deworming> createDeworming(
    String deviceId, {
    required String productName,
    required String dateAdministered,
    String? dose,
    String? batch,
    String? veterinarian,
    String? nextDueDate,
    String? observations,
    MultipartFile? image,
  }) async {
    try {
      final formData = FormData();
      formData.fields.addAll([
        MapEntry('productName', productName),
        MapEntry('dateAdministered', dateAdministered),
      ]);

      if (dose != null && dose.isNotEmpty) {
        formData.fields.add(MapEntry('dose', dose));
      }

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
        '/devices/$deviceId/dewormings',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );
      return Deworming.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Deworming> updateDeworming(
    String deviceId,
    String dewormingId, {
    required String productName,
    required String dateAdministered,
    String? dose,
    String? batch,
    String? veterinarian,
    String? nextDueDate,
    String? observations,
    MultipartFile? image,
  }) async {
    try {
      final formData = FormData();
      formData.fields.addAll([
        MapEntry('productName', productName),
        MapEntry('dateAdministered', dateAdministered),
      ]);

      if (dose != null && dose.isNotEmpty) {
        formData.fields.add(MapEntry('dose', dose));
      }

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
        '/devices/$deviceId/dewormings/$dewormingId',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );
      return Deworming.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteDeworming(String deviceId, String dewormingId) async {
    try {
      print('/devices/$deviceId/dewormings/$dewormingId');
      await dio.delete('/devices/$deviceId/dewormings/$dewormingId');
    } catch (e) {
      rethrow;
    }
  }
}
