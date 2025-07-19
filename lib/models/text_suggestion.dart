// Response model for text suggestions
class TextSuggestion {
  final String text;
  final String nextWord;

  TextSuggestion({required this.text, required this.nextWord});

  factory TextSuggestion.fromJson(Map<String, dynamic> json) {
    return TextSuggestion(
      text: json['text'] ?? '',
      nextWord: json['next_word'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'text': text, 'next_word': nextWord};
  }
}

class TextGearsSuggestResponse {
  final bool status;
  final String corrected;
  final List<TextSuggestion> suggestions;

  TextGearsSuggestResponse({
    required this.status,
    required this.corrected,
    required this.suggestions,
  });

  factory TextGearsSuggestResponse.fromJson(Map<String, dynamic> json) {
    return TextGearsSuggestResponse(
      status: json['status'] ?? false,
      corrected: json['response']?['corrected'] ?? '',
      suggestions:
          (json['response']?['suggestions'] as List<dynamic>? ?? [])
              .map((e) => TextSuggestion.fromJson(e as Map<String, dynamic>))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'corrected': corrected,
      'suggestions': suggestions.map((e) => e.toJson()).toList(),
    };
  }
}
