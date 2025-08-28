import 'package:flutter/material.dart';
import '../models/text_gears_response.dart';
import '../models/text_gears_correct_response.dart';
import '../models/text_gears_detect_response.dart';
import '../models/text_gears_summarize_response.dart';
import '../models/text_suggestion.dart';
import '../models/text_gears_error.dart';
import '../services/api_service.dart';
import '../widgets/custom_text_fields_with_error.dart';

class TextGearsProvider extends ChangeNotifier {
  final TextGearsApiService _apiService;

  TextGearsProvider({required String apiKey})
    : _apiService = TextGearsApiService(apiKey: apiKey);

  // Common state
  String _selectedLanguage = 'en-US';
  String get selectedLanguage => _selectedLanguage;

  void setLanguage(String language) {
    _selectedLanguage = language;
    notifyListeners();
  }

  // Grammar check state
  List<TextError> _grammarErrors = [];
  bool _isLoadingGrammar = false;
  String? _grammarErrorMessage;

  List<TextError> get grammarErrors => _grammarErrors;
  bool get isLoadingGrammar => _isLoadingGrammar;
  String? get grammarErrorMessage => _grammarErrorMessage;

  // Spelling check state
  List<TextError> _spellingErrors = [];
  bool _isLoadingSpelling = false;
  String? _spellingErrorMessage;

  List<TextError> get spellingErrors => _spellingErrors;
  bool get isLoadingSpelling => _isLoadingSpelling;
  String? get spellingErrorMessage => _spellingErrorMessage;

  // Auto-correction state
  List<TextError> _autoErrors = [];
  bool _isLoadingAutoCorrect = false;
  String? _autoErrorMessage;
  String _correctedText = '';

  List<TextError> get autoErrors => _autoErrors;
  bool get isLoadingAutoCorrect => _isLoadingAutoCorrect;
  String? get autoErrorMessage => _autoErrorMessage;
  String get correctedText => _correctedText;

  // Text suggestions state
  List<TextSuggestion> _suggestions = [];
  bool _isLoadingSuggestions = false;
  String? _suggestionsErrorMessage;
  String _correctedSuggestionText = '';

  List<TextSuggestion> get suggestions => _suggestions;
  bool get isLoadingSuggestions => _isLoadingSuggestions;
  String? get suggestionsErrorMessage => _suggestionsErrorMessage;
  String get correctedSuggestionText => _correctedSuggestionText;

  // Language detection state
  bool _isLoadingLanguage = false;
  String? _languageErrorMessage;
  String? _detectedLanguageCode;
  String? _detectedDialect;
  Map<String, double> _languageProbabilities = {};

  bool get isLoadingLanguage => _isLoadingLanguage;
  String? get languageErrorMessage => _languageErrorMessage;
  String? get detectedLanguageCode => _detectedLanguageCode;
  String? get detectedDialect => _detectedDialect;
  Map<String, double> get languageProbabilities => _languageProbabilities;

  // Text summarization state
  bool _isLoadingSummary = false;
  String? _summaryErrorMessage;
  List<String> _summaryKeywords = [];
  List<String> _summaryHighlights = [];
  List<String> _summaryResults = [];

  bool get isLoadingSummary => _isLoadingSummary;
  String? get summaryErrorMessage => _summaryErrorMessage;
  List<String> get summaryKeywords => _summaryKeywords;
  List<String> get summaryHighlights => _summaryHighlights;
  List<String> get summaryResults => _summaryResults;

  // Convert API errors to UI errors
  List<TextError> _convertApiErrorsToTextErrors(
    List<TextGearsError> apiErrors,
  ) {
    List<TextError> textErrors = [];

    for (TextGearsError apiError in apiErrors) {
      if (apiError.offset != null &&
          apiError.length != null &&
          apiError.better.isNotEmpty) {
        ErrorType errorType;
        switch (apiError.type.toLowerCase()) {
          case 'spelling':
            errorType = ErrorType.spelling;
            break;
          case 'grammar':
            errorType = ErrorType.grammar;
            break;
          default:
            errorType = ErrorType.grammar;
        }

        textErrors.add(
          TextError(
            start: apiError.offset!,
            end: apiError.offset! + apiError.length!,
            type: errorType,
            suggestion: apiError.better.first,
            originalText: apiError.bad,
          ),
        );
      }
    }

    return textErrors;
  }

  // Grammar check methods
  Future<void> checkGrammar(String text) async {
    if (text.isEmpty) {
      throw Exception('Text cannot be empty');
    }

    _isLoadingGrammar = true;
    _grammarErrorMessage = null;
    _grammarErrors = [];
    notifyListeners();

    try {
      TextGearsResponse response = await _apiService.checkGrammar(
        text: text,
        language: _selectedLanguage,
        useAI: true,
      );

      if (response.status) {
        _grammarErrors = _convertApiErrorsToTextErrors(response.errors);
      } else {
        _grammarErrorMessage = 'API returned error status';
      }
    } catch (e) {
      _grammarErrorMessage = 'Error checking grammar: ${e.toString()}';
    } finally {
      _isLoadingGrammar = false;
      notifyListeners();
    }
  }

  // Spelling check methods
  Future<void> checkSpelling(String text) async {
    if (text.isEmpty) {
      throw Exception('Text cannot be empty');
    }

    _isLoadingSpelling = true;
    _spellingErrorMessage = null;
    _spellingErrors = [];
    notifyListeners();

    try {
      TextGearsResponse response = await _apiService.checkSpelling(
        text: text,
        language: _selectedLanguage,
        useAI: true,
      );

      if (response.status) {
        _spellingErrors = _convertApiErrorsToTextErrors(response.errors);
      } else {
        _spellingErrorMessage = 'API returned error status';
      }
    } catch (e) {
      _spellingErrorMessage = 'Error checking spelling: ${e.toString()}';
    } finally {
      _isLoadingSpelling = false;
      notifyListeners();
    }
  }

  // Auto-correction methods
  Future<void> autoCorrectText(String text) async {
    if (text.isEmpty) {
      throw Exception('Text cannot be empty');
    }

    _isLoadingAutoCorrect = true;
    _autoErrorMessage = null;
    _autoErrors = [];
    _correctedText = '';
    notifyListeners();

    try {
      // Get grammar errors for highlighting
      TextGearsResponse grammarResponse = await _apiService.checkGrammar(
        text: text,
        language: _selectedLanguage,
        useAI: true,
      );

      // Get corrected text
      TextGearsCorrectResponse correctResponse = await _apiService.correctText(
        text: text,
        language: _selectedLanguage,
      );

      if (grammarResponse.status && correctResponse.status) {
        _autoErrors = _convertApiErrorsToTextErrors(grammarResponse.errors);
        _correctedText = correctResponse.corrected;
      } else {
        _autoErrorMessage = 'API returned error status';
      }
    } catch (e) {
      _autoErrorMessage = 'Error during auto-correction: ${e.toString()}';
    } finally {
      _isLoadingAutoCorrect = false;
      notifyListeners();
    }
  }

  // Text suggestions methods
  Future<void> getTextSuggestions(String text) async {
    if (text.isEmpty) {
      throw Exception('Text cannot be empty');
    }

    _isLoadingSuggestions = true;
    _suggestionsErrorMessage = null;
    _suggestions = [];
    _correctedSuggestionText = '';
    notifyListeners();

    try {
      TextGearsSuggestResponse response = await _apiService.suggestText(
        text: text,
        language: _selectedLanguage,
      );

      if (response.status) {
        _suggestions = response.suggestions;
        _correctedSuggestionText = response.corrected;
      } else {
        _suggestionsErrorMessage = 'API returned error status';
      }
    } catch (e) {
      _suggestionsErrorMessage = 'Error getting suggestions: ${e.toString()}';
    } finally {
      _isLoadingSuggestions = false;
      notifyListeners();
    }
  }

  // Language detection methods
  Future<void> detectLanguage(String text) async {
    if (text.isEmpty) {
      throw Exception('Text cannot be empty');
    }

    _isLoadingLanguage = true;
    _languageErrorMessage = null;
    _detectedLanguageCode = null;
    _detectedDialect = null;
    _languageProbabilities = {};
    notifyListeners();

    try {
      TextGearsDetectResponse response = await _apiService.detectLanguage(
        text: text,
      );

      if (response.status) {
        _detectedLanguageCode = response.language;
        _detectedDialect = response.dialect;
        _languageProbabilities = response.probabilities;
      } else {
        _languageErrorMessage = 'API returned error status';
      }
    } catch (e) {
      _languageErrorMessage = 'Error detecting language: ${e.toString()}';
    } finally {
      _isLoadingLanguage = false;
      notifyListeners();
    }
  }

  // Text summarization methods
  Future<void> summarizeText(String text, {int? maxSentences}) async {
    if (text.isEmpty) {
      throw Exception('Text cannot be empty');
    }

    if (text.length < 50) {
      throw Exception(
        'Text is too short for summarization. Please enter at least 50 characters.',
      );
    }

    _isLoadingSummary = true;
    _summaryErrorMessage = null;
    _summaryKeywords = [];
    _summaryHighlights = [];
    _summaryResults = [];
    notifyListeners();

    try {
      TextGearsSummarizeResponse response = await _apiService.summarizeText(
        text: text,
        language: _selectedLanguage,
        maxSentences: maxSentences ?? 5,
      );

      if (response.status) {
        _summaryKeywords = response.keywords;
        _summaryHighlights = response.highlight;
        _summaryResults = response.summary;
      } else {
        _summaryErrorMessage = 'API returned error status';
      }
    } catch (e) {
      _summaryErrorMessage = 'Error summarizing text: ${e.toString()}';
    } finally {
      _isLoadingSummary = false;
      notifyListeners();
    }
  }

  // Clear methods for resetting state
  void clearGrammarResults() {
    _grammarErrors = [];
    _grammarErrorMessage = null;
    notifyListeners();
  }

  void clearSpellingResults() {
    _spellingErrors = [];
    _spellingErrorMessage = null;
    notifyListeners();
  }

  void clearAutoCorrectResults() {
    _autoErrors = [];
    _autoErrorMessage = null;
    _correctedText = '';
    notifyListeners();
  }

  void clearSuggestionsResults() {
    _suggestions = [];
    _suggestionsErrorMessage = null;
    _correctedSuggestionText = '';
    notifyListeners();
  }

  void clearLanguageResults() {
    _detectedLanguageCode = null;
    _detectedDialect = null;
    _languageProbabilities = {};
    _languageErrorMessage = null;
    notifyListeners();
  }

  void clearSummaryResults() {
    _summaryKeywords = [];
    _summaryHighlights = [];
    _summaryResults = [];
    _summaryErrorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }
}
