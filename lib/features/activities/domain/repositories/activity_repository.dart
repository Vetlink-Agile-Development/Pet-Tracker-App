import 'package:pet_tracker/features/activities/domain/entities/activity.dart';


abstract class ActivityRepository {
  Future<List<Activity>> getActivities(
    String deviceRecordId, {
    String? activityType,
    DateTime? from,
    DateTime? to,
    int page = 1,
    int pageSize = 20,
  });
}
