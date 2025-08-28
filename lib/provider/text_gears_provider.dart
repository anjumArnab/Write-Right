import 'package:flutter/material.dart';
import '../models/text_gears_correct_response.dart';
import '../models/text_gears_detect_response.dart';
import '../models/text_gears_summarize_response.dart';
import '../models/text_suggestion.dart';
import '../models/text_gears_error.dart';
import '../models/text_gears_response.dart';
import '../services/api_service.dart';
import '../widgets/custom_text_fields_with_error.dart';

class TextGearsProvider extends ChangeNotifier {
  late TextGearsApiService _textGearsService;

  // Controllers for TextFormField widgets
  final TextEditingController grammarController = TextEditingController();
  final TextEditingController spellingController = TextEditingController();
  final TextEditingController autoController = TextEditingController();
  final TextEditingController suggestController = TextEditingController();
  final TextEditingController langController = TextEditingController();
  final TextEditingController summaryController = TextEditingController();

  // Default text values
  String grammarText = 'I is an engeered';
  String spellingText = 'Seperatethewordds carefully';
  String autoText = 'Whats you\'re name? I have recieved you\'re message.';
  String suggestionText = 'My name is Seth. My family';
  String summaryText = 'The quick brown fox jumps over';

  // Grammar check variables
  List<TextError> grammarErrors = [];
  bool isLoadingGrammar = false;
  String? grammarErrorMessage;
  String detectedLanguage = 'en-US';

  // Spelling check variables
  List<TextError> spellingErrors = [];
  bool isLoadingSpelling = false;
  String? spellingErrorMessage;

  // Auto-correction variables
  List<TextError> autoErrors = [];
  bool isLoadingAutoCorrect = false;
  String? autoErrorMessage;
  String correctedText = '';

  // Text suggestions variables
  List<TextSuggestion> suggestions = [];
  bool isLoadingSuggestions = false;
  String? suggestionsErrorMessage;
  String correctedSuggestionText = '';

  // Language detection variables
  bool isLoadingLanguage = false;
  String? languageErrorMessage;
  String? detectedLanguageCode;
  String? detectedDialect;
  Map<String, double> languageProbabilities = {};

  // Text summarization variables
  bool isLoadingSummary = false;
  String? summaryErrorMessage;
  List<String> summaryKeywords = [];
  List<String> summaryHighlights = [];
  List<String> summaryResults = [];

  TextGearsProvider() {
    // Initialize the TextGears API service
    _textGearsService = TextGearsApiService(apiKey: 'HKP36t4XOghGbAKn');

    // Initialize controllers with default text
    grammarController.text = grammarText;
    spellingController.text = spellingText;
    autoController.text = autoText;
    suggestController.text = suggestionText;
    langController.text = 'Bonjour, comment allez-vous?';
    summaryController.text = summaryText;
  }

  @override
  void dispose() {
    grammarController.dispose();
    spellingController.dispose();
    autoController.dispose();
    suggestController.dispose();
    langController.dispose();
    summaryController.dispose();
    _textGearsService.dispose();
    super.dispose();
  }

  // Convert TextGears API errors to UI TextError objects
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

  // Check grammar using TextGears API
  Future<void> checkGrammar() async {
    String text = grammarController.text.trim();

    if (text.isEmpty) {
      return;
    }

    isLoadingGrammar = true;
    grammarErrorMessage = null;
    grammarErrors = [];
    notifyListeners();

    try {
      // Make API call to check grammar
      TextGearsResponse response = await _textGearsService.checkGrammar(
        text: text,
        language: detectedLanguage,
        useAI: true,
      );

      if (response.status) {
        // Convert API errors to UI errors
        List<TextError> errors = _convertApiErrorsToTextErrors(response.errors);

        grammarErrors = errors;
        isLoadingGrammar = false;
        notifyListeners();
      } else {
        grammarErrorMessage = 'API returned error status';
        isLoadingGrammar = false;
        notifyListeners();
      }
    } catch (e) {
      grammarErrorMessage = 'Error checking grammar: ${e.toString()}';
      isLoadingGrammar = false;
      notifyListeners();
    }
  }

  // Check spelling using TextGears API
  Future<void> checkSpelling() async {
    String text = spellingController.text.trim();

    if (text.isEmpty) {
      return;
    }

    isLoadingSpelling = true;
    spellingErrorMessage = null;
    spellingErrors = [];
    notifyListeners();

    try {
      // Make API call to check spelling
      TextGearsResponse response = await _textGearsService.checkSpelling(
        text: text,
        language: detectedLanguage,
        useAI: true,
      );

      if (response.status) {
        // Convert API errors to UI errors
        List<TextError> errors = _convertApiErrorsToTextErrors(response.errors);

        spellingErrors = errors;
        isLoadingSpelling = false;
        notifyListeners();
      } else {
        spellingErrorMessage = 'API returned error status';
        isLoadingSpelling = false;
        notifyListeners();
      }
    } catch (e) {
      spellingErrorMessage = 'Error checking spelling: ${e.toString()}';
      isLoadingSpelling = false;
      notifyListeners();
    }
  }

  // Auto-correct text using TextGears API
  Future<void> autoCorrectText() async {
    String text = autoController.text.trim();

    if (text.isEmpty) {
      return;
    }

    isLoadingAutoCorrect = true;
    autoErrorMessage = null;
    autoErrors = [];
    correctedText = '';
    notifyListeners();

    try {
      // First, get grammar errors to show what will be corrected
      TextGearsResponse grammarResponse = await _textGearsService.checkGrammar(
        text: text,
        language: detectedLanguage,
        useAI: true,
      );

      // Then get the corrected text
      TextGearsCorrectResponse correctResponse = await _textGearsService
          .correctText(text: text, language: detectedLanguage);

      if (grammarResponse.status && correctResponse.status) {
        // Convert API errors to UI errors for highlighting
        List<TextError> errors = _convertApiErrorsToTextErrors(
          grammarResponse.errors,
        );

        autoErrors = errors;
        correctedText = correctResponse.corrected;
        isLoadingAutoCorrect = false;
        notifyListeners();
      } else {
        autoErrorMessage = 'API returned error status';
        isLoadingAutoCorrect = false;
        notifyListeners();
      }
    } catch (e) {
      autoErrorMessage = 'Error during auto-correction: ${e.toString()}';
      isLoadingAutoCorrect = false;
      notifyListeners();
    }
  }

  // Get text suggestions using TextGears API
  Future<void> getTextSuggestions() async {
    String text = suggestController.text.trim();

    if (text.isEmpty) {
      return;
    }

    isLoadingSuggestions = true;
    suggestionsErrorMessage = null;
    suggestions = [];
    correctedSuggestionText = '';
    notifyListeners();

    try {
      // Make API call to get text suggestions
      TextGearsSuggestResponse response = await _textGearsService.suggestText(
        text: text,
        language: detectedLanguage,
      );

      if (response.status) {
        suggestions = response.suggestions;
        correctedSuggestionText = response.corrected;
        isLoadingSuggestions = false;
        notifyListeners();
      } else {
        suggestionsErrorMessage = 'API returned error status';
        isLoadingSuggestions = false;
        notifyListeners();
      }
    } catch (e) {
      suggestionsErrorMessage = 'Error getting suggestions: ${e.toString()}';
      isLoadingSuggestions = false;
      notifyListeners();
    }
  }

  // Detect language using TextGears API
  Future<void> detectLanguage() async {
    String text = langController.text.trim();

    if (text.isEmpty) {
      return;
    }

    isLoadingLanguage = true;
    languageErrorMessage = null;
    detectedLanguageCode = null;
    detectedDialect = null;
    languageProbabilities = {};
    notifyListeners();

    try {
      // Make API call to detect language
      TextGearsDetectResponse response = await _textGearsService.detectLanguage(
        text: text,
      );

      if (response.status) {
        detectedLanguageCode = response.language;
        detectedDialect = response.dialect;
        languageProbabilities = response.probabilities;
        isLoadingLanguage = false;
        notifyListeners();
      } else {
        languageErrorMessage = 'API returned error status';
        isLoadingLanguage = false;
        notifyListeners();
      }
    } catch (e) {
      languageErrorMessage = 'Error detecting language: ${e.toString()}';
      isLoadingLanguage = false;
      notifyListeners();
    }
  }

  // Summarize text using TextGears API
  Future<void> summarizeText() async {
    String text = summaryController.text.trim();

    if (text.isEmpty || text.length < 50) {
      return;
    }

    isLoadingSummary = true;
    summaryErrorMessage = null;
    summaryKeywords = [];
    summaryHighlights = [];
    summaryResults = [];
    notifyListeners();

    try {
      // Make API call to summarize text
      TextGearsSummarizeResponse response = await _textGearsService
          .summarizeText(
            text: text,
            language: detectedLanguage,
            maxSentences: 5, // Limit to 5 sentences in summary
          );

      if (response.status) {
        summaryKeywords = response.keywords;
        summaryHighlights = response.highlight;
        summaryResults = response.summary;
        isLoadingSummary = false;
        notifyListeners();
      } else {
        summaryErrorMessage = 'API returned error status';
        isLoadingSummary = false;
        notifyListeners();
      }
    } catch (e) {
      summaryErrorMessage = 'Error summarizing text: ${e.toString()}';
      isLoadingSummary = false;
      notifyListeners();
    }
  }

  // Apply suggestion to the text field
  void applySuggestion(String suggestion) {
    String currentText = suggestController.text;
    String newText = '${currentText.trimRight()} $suggestion';

    suggestController.text = newText;
    suggestController.selection = TextSelection.fromPosition(
      TextPosition(offset: newText.length),
    );
    notifyListeners();
  }

  // Update detected language
  void updateDetectedLanguage(String language) {
    detectedLanguage = language;
    notifyListeners();
  }

  // Helper method to get language name from code
  String getLanguageName(String languageCode) {
    const Map<String, String> languageNames = {
      'en': 'English',
      'fr': 'French',
      'es': 'Spanish',
      'de': 'German',
      'it': 'Italian',
      'pt': 'Portuguese',
      'ru': 'Russian',
      'zh': 'Chinese',
      'ja': 'Japanese',
      'ko': 'Korean',
      'ar': 'Arabic',
      'hi': 'Hindi',
      'tr': 'Turkish',
      'pl': 'Polish',
      'nl': 'Dutch',
      'sv': 'Swedish',
      'da': 'Danish',
      'no': 'Norwegian',
      'fi': 'Finnish',
      'cs': 'Czech',
      'hu': 'Hungarian',
      'ro': 'Romanian',
      'bg': 'Bulgarian',
      'hr': 'Croatian',
      'sk': 'Slovak',
      'sl': 'Slovenian',
      'et': 'Estonian',
      'lv': 'Latvian',
      'lt': 'Lithuanian',
      'mt': 'Maltese',
      'ga': 'Irish',
      'cy': 'Welsh',
      'eu': 'Basque',
      'ca': 'Catalan',
      'gl': 'Galician',
      'is': 'Icelandic',
      'mk': 'Macedonian',
      'sq': 'Albanian',
      'sr': 'Serbian',
      'bs': 'Bosnian',
      'me': 'Montenegrin',
    };

    return languageNames[languageCode] ?? languageCode.toUpperCase();
  }

  // Helper method to get confidence percentage
  double getConfidencePercentage() {
    if (languageProbabilities.isEmpty || detectedLanguageCode == null) {
      return 0.0;
    }
    return (languageProbabilities[detectedLanguageCode!] ?? 0.0) * 100;
  }

  // Clear specific error states
  void clearGrammarErrors() {
    grammarErrors = [];
    grammarErrorMessage = null;
    notifyListeners();
  }

  void clearSpellingErrors() {
    spellingErrors = [];
    spellingErrorMessage = null;
    notifyListeners();
  }

  void clearAutoErrors() {
    autoErrors = [];
    autoErrorMessage = null;
    correctedText = '';
    notifyListeners();
  }

  void clearSuggestions() {
    suggestions = [];
    suggestionsErrorMessage = null;
    correctedSuggestionText = '';
    notifyListeners();
  }

  void clearLanguageDetection() {
    detectedLanguageCode = null;
    detectedDialect = null;
    languageProbabilities = {};
    languageErrorMessage = null;
    notifyListeners();
  }

  void clearSummary() {
    summaryKeywords = [];
    summaryHighlights = [];
    summaryResults = [];
    summaryErrorMessage = null;
    notifyListeners();
  }
}
