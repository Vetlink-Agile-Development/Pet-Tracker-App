import '../../domain/entities/activity.dart';
import '../../domain/repositories/activity_repository.dart';
import '../datasources/activity_datasource_impl.dart';

class ActivityRepositoryImpl extends ActivityRepository {
  final ActivityDatasourceImpl datasource;

  ActivityRepositoryImpl(this.datasource);

  @override
  Future<List<Activity>> getActivities(
    String deviceRecordId, {
    String? activityType,
    DateTime? from,
    DateTime? to,
    int page = 1,
    int pageSize = 20,
  }) {
    return datasource.getActivities(
      deviceRecordId,
      activityType: activityType,
      from: from,
      to: to,
      page: page,
      pageSize: pageSize,
    );
  }
}
