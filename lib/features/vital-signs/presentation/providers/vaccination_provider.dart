import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/vaccination.dart';
import '../../infrastructure/vaccination_service.dart';
import 'package:dio/dio.dart';

final vaccinationProvider = FutureProvider.family<List<Vaccination>, String>((ref, deviceId) async {
  final dio = Dio();
  final service = VaccinationService(dio);
  return await service.getVaccinationsByDeviceId(deviceId);
});