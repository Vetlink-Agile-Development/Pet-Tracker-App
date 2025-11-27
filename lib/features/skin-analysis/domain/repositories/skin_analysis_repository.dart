import 'dart:io';
import 'package:pet_tracker/features/skin-analysis/domain/entities/skin_prediction.dart';

abstract class SkinAnalysisRepository {
  Future<SkinPrediction> analyzeSkin(File imageFile);
}
