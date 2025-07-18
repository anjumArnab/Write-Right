import 'dart:convert';
import 'package:http/http.dart' as http;
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

// Exception class for API errors
class TextGearsException implements Exception {
  final String message;
  final int? statusCode;

  TextGearsException(this.message, [this.statusCode]);

  @override
  String toString() => 'TextGearsException: $message';
}

// API Service class
class TextGearsApiService {
  static const String _baseUrl = 'https://api.textgears.com/grammar';
  final String _apiKey;
  final http.Client _client;

  TextGearsApiService({required String apiKey, http.Client? client})
    : _apiKey = apiKey,
      _client = client ?? http.Client();

  /// Check grammar and spelling in the provided text
  ///
  /// [text] - UTF-8 encoded text to check
  /// [language] - Language code (optional, defaults to 'en-US')
  /// [whitelist] - Array of words/phrases to ignore (optional)
  /// [dictionaryId] - Custom dictionary ID (optional)
  /// [useAI] - Whether to use TextGears AI for improved analysis (optional)
  Future<TextGearsResponse> checkGrammar({
    required String text,
    String? language,
    List<String>? whitelist,
    String? dictionaryId,
    bool? useAI,
  }) async {
    try {
      // Validate input
      if (text.isEmpty) {
        throw TextGearsException('Text cannot be empty');
      }

      // Prepare request parameters
      final Map<String, dynamic> params = {'text': text, 'key': _apiKey};

      // Add optional parameters
      if (language != null && language.isNotEmpty) {
        params['language'] = language;
      }

      if (whitelist != null && whitelist.isNotEmpty) {
        params['whitelist'] = whitelist;
      }

      if (dictionaryId != null && dictionaryId.isNotEmpty) {
        params['dictionary_id'] = dictionaryId;
      }

      if (useAI != null) {
        params['ai'] = useAI;
      }

      // Make the API request
      final response = await _client.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: params.map((key, value) => MapEntry(key, value.toString())),
      );

      // Handle response
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return TextGearsResponse.fromJson(jsonResponse);
      } else {
        throw TextGearsException(
          'API request failed with status: ${response.statusCode}',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is TextGearsException) {
        rethrow;
      }
      throw TextGearsException('Network error: ${e.toString()}');
    }
  }

  /// Check grammar with default settings (English, no whitelist, AI enabled)
  Future<TextGearsResponse> checkGrammarSimple(String text) async {
    return checkGrammar(text: text, language: 'en-US', useAI: true);
  }

  /// Get grammar errors count
  Future<int> getErrorsCount(String text) async {
    final response = await checkGrammarSimple(text);
    return response.errors.length;
  }

  /// Get only spelling errors
  Future<List<TextGearsError>> getSpellingErrors(String text) async {
    final response = await checkGrammarSimple(text);
    return response.errors.where((error) => error.type == 'spelling').toList();
  }

  /// Get only grammar errors
  Future<List<TextGearsError>> getGrammarErrors(String text) async {
    final response = await checkGrammarSimple(text);
    return response.errors.where((error) => error.type == 'grammar').toList();
  }

  /// Apply first suggestion to all errors in text
  String applyFirstSuggestions(
    String originalText,
    List<TextGearsError> errors,
  ) {
    if (errors.isEmpty) return originalText;

    String correctedText = originalText;
    int offset = 0;

    // Filter errors that have valid offset and length
    final validErrors =
        errors
            .where(
              (error) =>
                  error.offset != null &&
                  error.length != null &&
                  error.better.isNotEmpty,
            )
            .toList();

    // Sort errors by offset to apply corrections from left to right
    final sortedErrors = List<TextGearsError>.from(validErrors)
      ..sort((a, b) => a.offset!.compareTo(b.offset!));

    for (final error in sortedErrors) {
      final adjustedOffset = error.offset! + offset;
      final before = correctedText.substring(0, adjustedOffset);
      final after = correctedText.substring(adjustedOffset + error.length!);
      correctedText = before + error.better.first + after;

      // Update offset for next corrections
      offset += error.better.first.length - error.length!;
    }

    return correctedText;
  }

  /// Dispose of the HTTP client
  void dispose() {
    _client.close();
  }
}
