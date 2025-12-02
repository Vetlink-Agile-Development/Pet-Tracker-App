import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/activity.dart';

class ActivityDatasource {
  final String baseUrl = 'https://pet-tracker.azurewebsites.net/api/v1';

  Future<List<Activity>> getActivities(
    String deviceRecordId, {
    String? activityType,
    DateTime? from,
    DateTime? to,
    int page = 1,
    int pageSize = 20,
  }) async {
    final query = <String, String>{
      'page': page.toString(),
      'pageSize': pageSize.toString(),
    };
    if (activityType != null) {
      // send both variations in case backend expects camelCase or snake_case
      query['activityType'] = activityType;
      query['activity_type'] = activityType;
    }
    if (from != null) query['from'] = from.toIso8601String();
    if (to != null) query['to'] = to.toIso8601String();

    final uri = Uri.parse('$baseUrl/devices/$deviceRecordId/activities').replace(queryParameters: query);
    final response = await http.get(uri);

    if (response.statusCode != 200) throw Exception('Error al cargar actividades');

    final List data = json.decode(response.body);
    return data.map((json) => Activity.fromJson(json)).toList();
  }
}
