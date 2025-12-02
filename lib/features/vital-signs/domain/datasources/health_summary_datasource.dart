import 'package:pet_tracker/features/vital-signs/domain/entities/health_summary.dart';

abstract class HealthSummaryDatasource {
  Future<List<HealthSummary>> fetchHealthSummary(String deviceRecordId, {DateTime? month});
  Future<List<HealthSummary>> fetchHealthPrediction(String deviceRecordId);
}
