import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_tracker/features/skin-analysis/domain/entities/skin_prediction.dart';
import 'package:pet_tracker/features/skin-analysis/domain/repositories/skin_analysis_repository.dart';
import 'package:pet_tracker/features/skin-analysis/infrastructure/datasources/skin_analysis_datasource_impl.dart';
import 'package:pet_tracker/features/skin-analysis/infrastructure/repositories/skin_analysis_repository_impl.dart';

// Repository Provider
final skinAnalysisRepositoryProvider = Provider<SkinAnalysisRepository>((ref) {
  return SkinAnalysisRepositoryImpl(SkinAnalysisDatasourceImpl());
});

class SkinAnalysisState {
  final bool isLoading;
  final SkinPrediction? prediction;
  final String? errorMessage;
  final File? selectedImage;

  SkinAnalysisState({
    this.isLoading = false,
    this.prediction,
    this.errorMessage,
    this.selectedImage,
  });

  factory SkinAnalysisState.initial() => SkinAnalysisState(
        isLoading: false,
        prediction: null,
        errorMessage: null,
        selectedImage: null,
      );

  SkinAnalysisState copyWith({
    bool? isLoading,
    SkinPrediction? prediction,
    String? errorMessage,
    File? selectedImage,
    bool clearPrediction = false,
    bool clearError = false,
  }) {
    return SkinAnalysisState(
      isLoading: isLoading ?? this.isLoading,
      prediction: clearPrediction ? null : (prediction ?? this.prediction),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      selectedImage: selectedImage ?? this.selectedImage,
    );
  }
}

class SkinAnalysisNotifier extends StateNotifier<SkinAnalysisState> {
  final SkinAnalysisRepository repository;

  SkinAnalysisNotifier(this.repository)
      : super(SkinAnalysisState.initial());

  void setSelectedImage(File image) {
    state = state.copyWith(selectedImage: image);
  }

  Future<void> analyzeSkin() async {
    if (state.selectedImage == null) return;

    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearPrediction: true,
    );

    try {
      final prediction = await repository.analyzeSkin(state.selectedImage!);

      state = state.copyWith(
        isLoading: false,
        prediction: prediction,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  void reset() {
    state = SkinAnalysisState.initial();
  }
}

final skinAnalysisProvider =
    StateNotifierProvider<SkinAnalysisNotifier, SkinAnalysisState>(
  (ref) {
    final repo = ref.watch(skinAnalysisRepositoryProvider);
    return SkinAnalysisNotifier(repo);
  },
);