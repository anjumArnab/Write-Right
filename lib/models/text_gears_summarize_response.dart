// Response model for summarization
class TextGearsSummarizeResponse {
  final bool status;
  final List<String> keywords;
  final List<String> highlight;
  final List<String> summary;

  TextGearsSummarizeResponse({
    required this.status,
    required this.keywords,
    required this.highlight,
    required this.summary,
  });

  factory TextGearsSummarizeResponse.fromJson(Map<String, dynamic> json) {
    final responseData = json['response'] ?? {};

    return TextGearsSummarizeResponse(
      status: json['status'] ?? false,
      keywords:
          (responseData['keywords'] as List<dynamic>? ?? [])
              .map((e) => e.toString())
              .toList(),
      highlight:
          (responseData['highlight'] as List<dynamic>? ?? [])
              .map((e) => e.toString())
              .toList(),
      summary:
          (responseData['summary'] as List<dynamic>? ?? [])
              .map((e) => e.toString())
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'keywords': keywords,
      'highlight': highlight,
      'summary': summary,
    };
  }
}
