import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/text_gears_exception.dart';
import '../models/text_gears_response.dart';
import '../models/text_gears_correct_response.dart';
import '../models/text_gears_detect_response.dart';
import '../models/text_gears_summarize_response.dart';
import '../models/text_suggestion.dart';
import '../models/text_gears_error.dart';

// API Service class
class TextGearsApiService {
  static const String _baseUrl = 'https://api.textgears.com';
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
        Uri.parse('$_baseUrl/grammar'),
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

  /// Check text for spelling errors
  ///
  /// [text] - UTF-8 encoded text to check
  /// [language] - Language code (optional, defaults to 'en-US')
  /// [whitelist] - Array of words/phrases to ignore (optional)
  /// [dictionaryId] - Custom dictionary ID (optional)
  /// [useAI] - Whether to use TextGears AI for improved analysis (optional)
  Future<TextGearsResponse> checkSpelling({
    required String text,
    String? language,
    List<String>? whitelist,
    String? dictionaryId,
    bool? useAI,
  }) async {
    try {
      if (text.isEmpty) {
        throw TextGearsException('Text cannot be empty');
      }

      final Map<String, dynamic> params = {'text': text, 'key': _apiKey};

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

      final response = await _client.post(
        Uri.parse('$_baseUrl/spelling'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: params.map((key, value) => MapEntry(key, value.toString())),
      );

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

  /// Auto-correct text errors
  ///
  /// [text] - UTF-8 encoded text to correct
  /// [language] - Language code (optional, defaults to 'en-US')
  /// Note: Currently only works for English language
  Future<TextGearsCorrectResponse> correctText({
    required String text,
    String? language,
  }) async {
    try {
      if (text.isEmpty) {
        throw TextGearsException('Text cannot be empty');
      }

      final Map<String, dynamic> params = {'text': text, 'key': _apiKey};

      if (language != null && language.isNotEmpty) {
        params['language'] = language;
      }

      final response = await _client.post(
        Uri.parse('$_baseUrl/correct'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: params.map((key, value) => MapEntry(key, value.toString())),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return TextGearsCorrectResponse.fromJson(jsonResponse);
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

  /// Get text suggestions and corrections
  ///
  /// [text] - UTF-8 encoded text to analyze
  /// [language] - Language code (optional, defaults to 'en-US')
  Future<TextGearsSuggestResponse> suggestText({
    required String text,
    String? language,
  }) async {
    try {
      if (text.isEmpty) {
        throw TextGearsException('Text cannot be empty');
      }

      final Map<String, dynamic> params = {'text': text, 'key': _apiKey};

      if (language != null && language.isNotEmpty) {
        params['language'] = language;
      }

      final response = await _client.post(
        Uri.parse('$_baseUrl/suggest'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: params.map((key, value) => MapEntry(key, value.toString())),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return TextGearsSuggestResponse.fromJson(jsonResponse);
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

  /// Detect language of the text
  ///
  /// [text] - UTF-8 encoded text to analyze
  Future<TextGearsDetectResponse> detectLanguage({required String text}) async {
    try {
      if (text.isEmpty) {
        throw TextGearsException('Text cannot be empty');
      }

      final Map<String, dynamic> params = {'text': text, 'key': _apiKey};

      final response = await _client.post(
        Uri.parse('$_baseUrl/detect'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: params.map((key, value) => MapEntry(key, value.toString())),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return TextGearsDetectResponse.fromJson(jsonResponse);
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

  /// Summarize text content
  ///
  /// [text] - UTF-8 encoded text to summarize
  /// [language] - Language code (optional, defaults to 'en-US')
  /// [maxSentences] - Maximum number of sentences in summary (optional)
  Future<TextGearsSummarizeResponse> summarizeText({
    required String text,
    String? language,
    int? maxSentences,
  }) async {
    try {
      if (text.isEmpty) {
        throw TextGearsException('Text cannot be empty');
      }

      final Map<String, dynamic> params = {'text': text, 'key': _apiKey};

      if (language != null && language.isNotEmpty) {
        params['language'] = language;
      }
      if (maxSentences != null) {
        params['max_sentences'] = maxSentences;
      }

      final response = await _client.post(
        Uri.parse('$_baseUrl/summarize'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: params.map((key, value) => MapEntry(key, value.toString())),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return TextGearsSummarizeResponse.fromJson(jsonResponse);
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
