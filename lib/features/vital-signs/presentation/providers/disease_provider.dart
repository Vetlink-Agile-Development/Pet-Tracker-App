import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/disease.dart';
import '../../infrastructure/disease_service.dart';
import 'package:dio/dio.dart';

final diseaseProvider = FutureProvider.family<List<Disease>, String>((ref, deviceId) async {
  final dio = Dio(); 
  final service = DiseaseService(dio);
  return await service.getDiseasesByDeviceId(deviceId);
});
