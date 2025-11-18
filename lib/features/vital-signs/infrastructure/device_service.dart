import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DeviceService {
  final Dio dio;
  DeviceService(this.dio);

  Future<List<String>> getDeviceNicknames(String userId, {String? token}) async {
    final apiUrl = dotenv.env['API_URL'] ?? 'https://pet-tracker.azurewebsites.net/api/v1';
    dio.options.baseUrl = apiUrl;
    if (token != null) {
      dio.options.headers['Authorization'] = 'Bearer $token';
    }
    final response = await dio.get('/users/$userId/devices');
    final devices = response.data as List;
    return devices.map((d) => d['nickname'] as String).toList();
  }
}
