import 'package:dio/dio.dart';

class ResetPasswordRepository {
  final Dio _dio = Dio();

  
  final String _baseUrl = 'https://pet-tracker.azurewebsites.net/api/v1/password-reset';

  Future<void> requestPasswordReset(String email) async {
    try {
      print('🔵 Intentando enviar correo a: $email');
      print('🔗 URL: $_baseUrl/request');

      final response = await _dio.post(
        '$_baseUrl/request', 
        data: {'email': email},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );
      
      print('✅ Respuesta exitosa: ${response.statusCode}');

    } on DioException catch (e) {
      print('🔴 Error de Dio: ${e.message}');
      print('🔴 Respuesta del servidor: ${e.response?.data}');
      
      if (e.response != null) {
        final errorMessage = e.response?.data['message'] ?? 'Error al solicitar recuperación';
        throw Exception(errorMessage);
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('El servidor tardó mucho en responder.');
      }
      
      throw Exception('Error de conexión con el servidor');
    } catch (e) {
      print('🔴 Error inesperado: $e');
      throw Exception('Ocurrió un error inesperado: $e');
    }
  }
}