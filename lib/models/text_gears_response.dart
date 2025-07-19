import '../models/text_gears_error.dart';

class TextGearsResponse {
  final bool status;
  final List<TextGearsError> errors;

  TextGearsResponse({required this.status, required this.errors});

  factory TextGearsResponse.fromJson(Map<String, dynamic> json) {
    return TextGearsResponse(
      status: json['status'] ?? false,
      errors:
          (json['response']?['errors'] as List<dynamic>? ?? [])
              .map((e) => TextGearsError.fromJson(e as Map<String, dynamic>))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'errors': errors.map((e) => e.toJson()).toList()};
  }
}
