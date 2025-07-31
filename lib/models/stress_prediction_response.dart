class StressPredictionResponse {
  final String ensembledStressPrediction;
  final double ensembledStressConfidence;
  final String predictedAspect;
  final double logregStressConfidence;
  final double attentionModelStressConfidence;
  final double attentionModelAspectConfidence;

  StressPredictionResponse({
    required this.ensembledStressPrediction,
    required this.ensembledStressConfidence,
    required this.predictedAspect,
    required this.logregStressConfidence,
    required this.attentionModelStressConfidence,
    required this.attentionModelAspectConfidence,
  });

  factory StressPredictionResponse.fromJson(Map<String, dynamic> json) {
    return StressPredictionResponse(
      ensembledStressPrediction: json['ensembled_stress_prediction'] as String,
      ensembledStressConfidence:
          (json['ensembled_stress_confidence'] as num).toDouble(),
      predictedAspect: json['predicted_aspect'] as String,
      logregStressConfidence:
          (json['logreg_stress_confidence'] as num).toDouble(),
      attentionModelStressConfidence:
          (json['attention_model_stress_confidence'] as num).toDouble(),
      attentionModelAspectConfidence:
          (json['attention_model_aspect_confidence'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ensembled_stress_prediction': ensembledStressPrediction,
      'ensembled_stress_confidence': ensembledStressConfidence,
      'predicted_aspect': predictedAspect,
      'logreg_stress_confidence': logregStressConfidence,
      'attention_model_stress_confidence': attentionModelStressConfidence,
      'attention_model_aspect_confidence': attentionModelAspectConfidence,
    };
  }
}
