// Response model for auto correction
class TextGearsCorrectResponse {
  final bool status;
  final String corrected;

  TextGearsCorrectResponse({required this.status, required this.corrected});

  factory TextGearsCorrectResponse.fromJson(Map<String, dynamic> json) {
    return TextGearsCorrectResponse(
      status: json['status'] ?? false,
      corrected: json['response']?['corrected'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'corrected': corrected};
  }
}
