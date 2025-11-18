import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/disease.dart';
import '../../infrastructure/disease_service.dart';
import 'package:dio/dio.dart';

final diseaseProvider = FutureProvider.family<List<Disease>, String>((ref, petId) async {
  final dio = Dio(); // TODO: Reemplazar con la instancia global/configurada
  final service = DiseaseService(dio);
  return await service.getDiseasesByPetId(petId);
});
