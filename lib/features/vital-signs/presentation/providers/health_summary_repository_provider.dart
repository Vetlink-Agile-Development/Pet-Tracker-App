import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_tracker/config/consts/environments.dart';
import 'package:pet_tracker/features/vital-signs/domain/repositories/health_summary_repository.dart';
import 'package:pet_tracker/features/vital-signs/infrastructure/datasources/health_summary_datasource_impl.dart';
import 'package:pet_tracker/shared/infrastructure/services/key_value_storage_provider.dart';
import 'package:pet_tracker/shared/infrastructure/services/key_value_storage_service.dart';
import 'package:pet_tracker/features/vital-signs/infrastructure/repositories/health_summary_repository_impl.dart';
import 'package:pet_tracker/features/devices/domain/repositories/device_repository.dart';
import 'package:pet_tracker/features/devices/presentation/providers/device_provider.dart';

class HealthSummaryService {
  final HealthSummaryRepository repository;
  final KeyValueStorageService storageService;
  final DeviceRepository deviceRepository;

  HealthSummaryService({
    required this.repository,
    required this.storageService,
    required this.deviceRepository,
  });

  Future<List> getSummaries({DateTime? forMonth}) async {
    final userId = await storageService.getValue<String>('userId');
    var selectedDeviceRecordId = await storageService.getValue<String>('selectedDeviceRecordId');

    if (userId == null) throw Exception('No user found');

    final userDevices = await deviceRepository.getAllDevices(userId);
    if (userDevices.isEmpty) {
      await storageService.removeKey('selectedDeviceRecordId');
      throw Exception('No devices assigned to this user.');
    }

    if (selectedDeviceRecordId == null) {
      selectedDeviceRecordId = userDevices.first.petTrackerDeviceRecordId;
      await storageService.setKeyValue<String>('selectedDeviceRecordId', selectedDeviceRecordId);
    }

    final isOwnedDevice = userDevices.any((d) => d.petTrackerDeviceRecordId == selectedDeviceRecordId);
    if (!isOwnedDevice) throw Exception('Unauthorized access');

    return await repository.fetchHealthSummary(selectedDeviceRecordId, month: forMonth ?? DateTime.now());
  }
}

final dioProvider = Provider<Dio>((ref) {
  return Dio(BaseOptions(
    baseUrl: Environment.apiUrl,
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));
});

// Proveedor para el datasource
final healthSummaryDatasourceProvider = Provider<HealthSummaryDatasourceImpl>((ref) {
  final storageService = ref.read(keyValueStorageServiceProvider);
  final dio = ref.read(dioProvider);
  return HealthSummaryDatasourceImpl(storageService: storageService, dio: dio);
});

// Proveedor para el repositorio
final healthSummaryRepositoryProvider = Provider<HealthSummaryRepository>((ref) {
  final datasource = ref.read(healthSummaryDatasourceProvider);
  return HealthSummaryRepositoryImpl(remoteDataSource: datasource);
});

final healthSummaryServiceProvider = Provider<HealthSummaryService>((ref) {
  final repository = ref.read(healthSummaryRepositoryProvider);
  final storage = ref.read(keyValueStorageServiceProvider);
  final deviceRepo = ref.read(deviceRepositoryProvider);
  return HealthSummaryService(repository: repository, storageService: storage, deviceRepository: deviceRepo);
});