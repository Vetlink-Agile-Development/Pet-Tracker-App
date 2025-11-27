import 'dart:io';
import 'package:pet_tracker/features/skin-analysis/domain/entities/skin_prediction.dart';

abstract class SkinAnalysisDatasource {
  Future<SkinPrediction> analyzeSkin(File imageFile);
}
