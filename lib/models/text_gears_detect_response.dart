class TextGearsDetectResponse {
  final bool status;
  final String? language;
  final String? dialect;
  final Map<String, double> probabilities;

  TextGearsDetectResponse({
    required this.status,
    this.language,
    this.dialect,
    required this.probabilities,
  });

  factory TextGearsDetectResponse.fromJson(Map<String, dynamic> json) {
    final responseData = json['response'] ?? {};
    final probabilities = <String, double>{};

    if (responseData['probabilities'] != null) {
      final probData = responseData['probabilities'] as Map<String, dynamic>;
      probData.forEach((key, value) {
        probabilities[key] = (value as num).toDouble();
      });
    }

    return TextGearsDetectResponse(
      status: json['status'] ?? false,
      language: responseData['language'],
      dialect: responseData['dialect'],
      probabilities: probabilities,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'language': language,
      'dialect': dialect,
      'probabilities': probabilities,
    };
  }
}
