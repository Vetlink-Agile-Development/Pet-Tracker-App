
import 'package:dio/dio.dart';
import 'package:pet_tracker/config/consts/environments.dart';
import 'package:pet_tracker/features/auth/domain/datasources/password_reset_datasource.dart';

class PasswordResetDatasourceImpl implements PasswordResetDatasource {

  final Dio dio = Dio(BaseOptions(
    baseUrl: Environment.apiUrl,
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    },
  ));

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await dio.post(
        '/password-reset/request',
        data: {'email': email},
      );
    } catch (e) {
      throw Exception('Failed to send password reset email');
    }
  }
}