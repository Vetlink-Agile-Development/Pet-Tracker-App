import 'dart:io';
import 'package:dio/dio.dart';
import 'package:pet_tracker/features/skin-analysis/domain/datasources/skin_analysis_datasource.dart';
import 'package:pet_tracker/features/skin-analysis/domain/entities/skin_prediction.dart';

class SkinAnalysisDatasourceImpl extends SkinAnalysisDatasource {
  final Dio dio;
  final String baseUrl =
      'http://vetlink-ml.fmfhbkfwamcxgfhx.westus2.azurecontainer.io:8000';

  SkinAnalysisDatasourceImpl({Dio? dio}) : dio = dio ?? Dio();

  @override
  Future<SkinPrediction> analyzeSkin(File imageFile) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      });

      final response = await dio.post(
        '$baseUrl/predict',
        data: formData,
        options: Options(
          headers: {
            'accept': 'application/json',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return SkinPrediction(
          prediction: data['prediction'] as String,
          confidence: (data['confidence'] as num).toDouble(),
        );
      } else {
        throw Exception('Error al analizar la imagen');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}
