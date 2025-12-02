import 'package:pet_tracker/features/vital-signs/domain/datasources/health_summary_datasource.dart';
import 'package:pet_tracker/features/vital-signs/domain/entities/health_summary.dart';
import 'package:pet_tracker/features/vital-signs/domain/repositories/health_summary_repository.dart';

class HealthSummaryRepositoryImpl implements HealthSummaryRepository {
  final HealthSummaryDatasource remoteDataSource;

  HealthSummaryRepositoryImpl({required this.remoteDataSource});

  @override
  @override
  Future<List<HealthSummary>> fetchHealthSummary(String deviceRecordId, {DateTime? month}) async {
    return await remoteDataSource.fetchHealthSummary(deviceRecordId, month: month);
  }

  @override
  Future<List<HealthSummary>> fetchHealthPrediction(
      String deviceRecordId) async {
    return await remoteDataSource.fetchHealthPrediction(deviceRecordId);
  }
}
