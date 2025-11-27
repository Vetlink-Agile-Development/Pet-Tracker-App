import 'dart:io';
import 'package:pet_tracker/features/skin-analysis/domain/datasources/skin_analysis_datasource.dart';
import 'package:pet_tracker/features/skin-analysis/domain/entities/skin_prediction.dart';
import 'package:pet_tracker/features/skin-analysis/domain/repositories/skin_analysis_repository.dart';

class SkinAnalysisRepositoryImpl extends SkinAnalysisRepository {
  final SkinAnalysisDatasource datasource;

  SkinAnalysisRepositoryImpl(this.datasource);

  @override
  Future<SkinPrediction> analyzeSkin(File imageFile) {
    return datasource.analyzeSkin(imageFile);
  }
}
