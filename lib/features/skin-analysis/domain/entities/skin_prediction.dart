class SkinPrediction {
  final String prediction;
  final double confidence;

  SkinPrediction({
    required this.prediction,
    required this.confidence,
  });

  String get translatedPrediction {
    switch (prediction.toLowerCase()) {
      case 'dermatitis':
        return 'Dermatitis';
      case 'fungal_infections':
        return 'Infección Fúngica';
      case 'healthy':
        return 'Saludable';
      case 'hypersensitivity':
        return 'Hipersensibilidad';
      case 'demodicosis':
        return 'Demodicosis';
      case 'ringworm':
        return 'Tiña';
      default:
        return prediction;
    }
  }

  bool get isHealthy => prediction.toLowerCase() == 'healthy';
}
