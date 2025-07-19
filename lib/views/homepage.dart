import 'package:flutter/material.dart';
import '../models/text_gears_correct_response.dart';
import '../models/text_gears_detect_response.dart';
import '../models/text_gears_summarize_response.dart';
import '../models/text_suggestion.dart';
import '../models/text_gears_error.dart';
import '../models/text_gears_response.dart';
import '../services/api_service.dart';
import '../widgets/custom_text_fields_with_error.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextGearsApiService _textGearsService;

  // Controllers for TextFormField widgets
  TextEditingController grammarController = TextEditingController();
  TextEditingController spellingController = TextEditingController();
  TextEditingController autoController = TextEditingController();
  TextEditingController suggestController = TextEditingController();
  TextEditingController langController = TextEditingController();

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
  TextEditingController summaryController = TextEditingController();
  bool isLoadingSummary = false;
  String? summaryErrorMessage;
  List<String> summaryKeywords = [];
  List<String> summaryHighlights = [];
  List<String> summaryResults = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);

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
    _tabController.dispose();
    grammarController.dispose();
    spellingController.dispose();
    autoController.dispose();
    suggestController.dispose();
    langController.dispose();
    summaryController.dispose();
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
  Future<void> _checkGrammar() async {
    String text = grammarController.text.trim();

    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter some text to check'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      isLoadingGrammar = true;
      grammarErrorMessage = null;
      grammarErrors = [];
    });

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

        setState(() {
          grammarErrors = errors;
          isLoadingGrammar = false;
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errors.isEmpty
                  ? 'No grammar errors found!'
                  : 'Found ${errors.length} grammar error(s)',
            ),
            backgroundColor: errors.isEmpty ? Colors.green : Colors.blue,
          ),
        );
      } else {
        setState(() {
          grammarErrorMessage = 'API returned error status';
          isLoadingGrammar = false;
        });
      }
    } catch (e) {
      setState(() {
        grammarErrorMessage = 'Error checking grammar: ${e.toString()}';
        isLoadingGrammar = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Check spelling using TextGears API
  Future<void> _checkSpelling() async {
    String text = spellingController.text.trim();

    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter some text to check'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      isLoadingSpelling = true;
      spellingErrorMessage = null;
      spellingErrors = [];
    });

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

        setState(() {
          spellingErrors = errors;
          isLoadingSpelling = false;
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errors.isEmpty
                  ? 'No spelling errors found!'
                  : 'Found ${errors.length} spelling error(s)',
            ),
            backgroundColor: errors.isEmpty ? Colors.green : Colors.blue,
          ),
        );
      } else {
        setState(() {
          spellingErrorMessage = 'API returned error status';
          isLoadingSpelling = false;
        });
      }
    } catch (e) {
      setState(() {
        spellingErrorMessage = 'Error checking spelling: ${e.toString()}';
        isLoadingSpelling = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Auto-correct text using TextGears API
  Future<void> _autoCorrectText() async {
    String text = autoController.text.trim();

    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter some text to auto-correct'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      isLoadingAutoCorrect = true;
      autoErrorMessage = null;
      autoErrors = [];
      correctedText = '';
    });

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

        setState(() {
          autoErrors = errors;
          correctedText = correctResponse.corrected;
          isLoadingAutoCorrect = false;
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errors.isEmpty
                  ? 'No corrections needed!'
                  : 'Found ${errors.length} correction(s)',
            ),
            backgroundColor: errors.isEmpty ? Colors.green : Colors.blue,
          ),
        );
      } else {
        setState(() {
          autoErrorMessage = 'API returned error status';
          isLoadingAutoCorrect = false;
        });
      }
    } catch (e) {
      setState(() {
        autoErrorMessage = 'Error during auto-correction: ${e.toString()}';
        isLoadingAutoCorrect = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Get text suggestions using TextGears API
  Future<void> _getTextSuggestions() async {
    String text = suggestController.text.trim();

    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter some text to get suggestions'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      isLoadingSuggestions = true;
      suggestionsErrorMessage = null;
      suggestions = [];
      correctedSuggestionText = '';
    });

    try {
      // Make API call to get text suggestions
      TextGearsSuggestResponse response = await _textGearsService.suggestText(
        text: text,
        language: detectedLanguage,
      );

      if (response.status) {
        setState(() {
          suggestions = response.suggestions;
          correctedSuggestionText = response.corrected;
          isLoadingSuggestions = false;
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              suggestions.isEmpty
                  ? 'No suggestions available for this text'
                  : 'Found ${suggestions.length} suggestion(s)',
            ),
            backgroundColor: suggestions.isEmpty ? Colors.grey : Colors.blue,
          ),
        );
      } else {
        setState(() {
          suggestionsErrorMessage = 'API returned error status';
          isLoadingSuggestions = false;
        });
      }
    } catch (e) {
      setState(() {
        suggestionsErrorMessage = 'Error getting suggestions: ${e.toString()}';
        isLoadingSuggestions = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Detect language using TextGears API
  Future<void> _detectLanguage() async {
    String text = langController.text.trim();

    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter some text for language detection'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      isLoadingLanguage = true;
      languageErrorMessage = null;
      detectedLanguageCode = null;
      detectedDialect = null;
      languageProbabilities = {};
    });

    try {
      // Make API call to detect language
      TextGearsDetectResponse response = await _textGearsService.detectLanguage(
        text: text,
      );

      if (response.status) {
        setState(() {
          detectedLanguageCode = response.language;
          detectedDialect = response.dialect;
          languageProbabilities = response.probabilities;
          isLoadingLanguage = false;
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              detectedLanguageCode != null
                  ? 'Language detected: ${_getLanguageName(detectedLanguageCode!)}'
                  : 'Language detection completed',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() {
          languageErrorMessage = 'API returned error status';
          isLoadingLanguage = false;
        });
      }
    } catch (e) {
      setState(() {
        languageErrorMessage = 'Error detecting language: ${e.toString()}';
        isLoadingLanguage = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Helper method to get language name from code
  String _getLanguageName(String languageCode) {
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
  double _getConfidencePercentage() {
    if (languageProbabilities.isEmpty || detectedLanguageCode == null) {
      return 0.0;
    }
    return (languageProbabilities[detectedLanguageCode!] ?? 0.0) * 100;
  }

  // Summarize text using TextGears API
  Future<void> _summarizeText() async {
    String text = summaryController.text.trim();

    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter some text to summarize'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (text.length < 50) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Text is too short for summarization. Please enter at least 50 characters.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      isLoadingSummary = true;
      summaryErrorMessage = null;
      summaryKeywords = [];
      summaryHighlights = [];
      summaryResults = [];
    });

    try {
      // Make API call to summarize text
      TextGearsSummarizeResponse response = await _textGearsService
          .summarizeText(
            text: text,
            language: detectedLanguage,
            maxSentences: 5, // Limit to 5 sentences in summary
          );

      if (response.status) {
        setState(() {
          summaryKeywords = response.keywords;
          summaryHighlights = response.highlight;
          summaryResults = response.summary;
          isLoadingSummary = false;
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Text summarized successfully! Generated ${summaryResults.length} key points.',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() {
          summaryErrorMessage = 'API returned error status';
          isLoadingSummary = false;
        });
      }
    } catch (e) {
      setState(() {
        summaryErrorMessage = 'Error summarizing text: ${e.toString()}';
        isLoadingSummary = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Write Right', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[600],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(text: 'Grammar'),
            Tab(text: 'Spelling'),
            Tab(text: 'Auto'),
            Tab(text: 'Suggest'),
            Tab(text: 'Lang'),
            Tab(text: 'Summary'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGrammarTab(),
          _buildSpellingTab(),
          _buildAutoTab(),
          _buildSuggestTab(),
          _buildLangTab(),
          _buildSummaryTab(),
        ],
      ),
    );
  }

  Widget _buildGrammarTab() {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Grammar Check',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Click on underlined words to see suggestions',
            style: TextStyle(color: Colors.grey[600]),
          ),
          SizedBox(height: 16),

          // Custom text field with error highlighting
          CustomTextFieldWithErrors(
            controller: grammarController,
            hintText: 'Enter text to check grammar...',
            errors: grammarErrors,
          ),

          SizedBox(height: 16),

          // Language indicator
          DropdownButton<String>(
            value: detectedLanguage,
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  detectedLanguage = newValue;
                });
              }
            },
            items:
                <String>[
                  'en-US',
                  'en-GB',
                  'fr-FR',
                  'de-DE',
                  'es-ES',
                  'it-IT',
                  'pt-PT',
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
          ),

          SizedBox(height: 16),

          // Error message display
          if (grammarErrorMessage != null)
            Container(
              padding: EdgeInsets.all(12),
              margin: EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[300]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.error, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      grammarErrorMessage!,
                      style: TextStyle(color: Colors.red[700]),
                    ),
                  ),
                ],
              ),
            ),

          // Grammar check button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoadingGrammar ? null : _checkGrammar,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
              child:
                  isLoadingGrammar
                      ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text('Checking...'),
                        ],
                      )
                      : Text('Check Grammar'),
            ),
          ),

          SizedBox(height: 16),

          // Results summary
          if (grammarErrors.isNotEmpty)
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Grammar Check Results',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Found ${grammarErrors.length} error(s)',
                    style: TextStyle(color: Colors.blue[700]),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Click on underlined words to see suggestions and apply corrections.',
                    style: TextStyle(color: Colors.blue[600], fontSize: 12),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSpellingTab() {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Spelling Check',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Click on underlined words to see suggestions',
            style: TextStyle(color: Colors.grey[600]),
          ),
          SizedBox(height: 16),

          // Custom text field with error highlighting
          CustomTextFieldWithErrors(
            controller: spellingController,
            hintText: 'Enter text to check spelling...',
            errors: spellingErrors,
          ),

          SizedBox(height: 16),

          // Language selector for spelling
          DropdownButton<String>(
            value: detectedLanguage,
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  detectedLanguage = newValue;
                });
              }
            },
            items:
                <String>[
                  'en-US',
                  'en-GB',
                  'fr-FR',
                  'de-DE',
                  'es-ES',
                  'it-IT',
                  'pt-PT',
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
          ),

          SizedBox(height: 16),

          // Error message display
          if (spellingErrorMessage != null)
            Container(
              padding: EdgeInsets.all(12),
              margin: EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[300]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.error, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      spellingErrorMessage!,
                      style: TextStyle(color: Colors.red[700]),
                    ),
                  ),
                ],
              ),
            ),

          // Spelling check button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoadingSpelling ? null : _checkSpelling,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
              child:
                  isLoadingSpelling
                      ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text('Checking...'),
                        ],
                      )
                      : Text('Check Spelling'),
            ),
          ),

          SizedBox(height: 16),

          // Results summary
          if (spellingErrors.isNotEmpty)
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.purple[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Spelling Check Results',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.purple[800],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Found ${spellingErrors.length} spelling error(s)',
                    style: TextStyle(color: Colors.purple[700]),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Click on underlined words to see suggestions and apply corrections.',
                    style: TextStyle(color: Colors.purple[600], fontSize: 12),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAutoTab() {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Auto-Correction',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Automatically detect and correct grammar and spelling errors. Tap on underlined words to apply corrections.',
            style: TextStyle(color: Colors.grey[600]),
          ),
          SizedBox(height: 16),

          // Custom text field with error highlighting - this will show auto-corrections
          CustomTextFieldWithErrors(
            controller: autoController,
            hintText: 'Enter text for auto-correction...',
            errors:
                autoErrors, // This will show autocorrect suggestions with green underlines
          ),

          SizedBox(height: 16),

          // Language selector for auto-correction
          DropdownButton<String>(
            value: detectedLanguage,
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  detectedLanguage = newValue;
                });
              }
            },
            items:
                <String>[
                  'en-US',
                  'en-GB',
                  'fr-FR',
                  'de-DE',
                  'es-ES',
                  'it-IT',
                  'pt-PT',
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
          ),

          SizedBox(height: 16),

          // Error message display
          if (autoErrorMessage != null)
            Container(
              padding: EdgeInsets.all(12),
              margin: EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[300]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.error, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      autoErrorMessage!,
                      style: TextStyle(color: Colors.red[700]),
                    ),
                  ),
                ],
              ),
            ),

          // Auto-correct button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoadingAutoCorrect ? null : _autoCorrectText,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
              child:
                  isLoadingAutoCorrect
                      ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text('Analyzing...'),
                        ],
                      )
                      : Text('Find Auto-Corrections'),
            ),
          ),

          SizedBox(height: 16),

          // Results summary - only show if there are corrections
          if (autoErrors.isNotEmpty)
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.auto_fix_high,
                        color: Colors.green[700],
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Auto-Correction Results',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green[800],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Found ${autoErrors.length} correction(s)',
                    style: TextStyle(
                      color: Colors.green[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Tap on any green underlined word in the text above to apply the suggested correction.',
                    style: TextStyle(color: Colors.green[600], fontSize: 12),
                  ),
                ],
              ),
            ),

          // Instructions when no errors found
          if (autoErrors.isEmpty &&
              !isLoadingAutoCorrect &&
              autoController.text.isNotEmpty)
            Expanded(
              child: Text(
                'No corrections needed! Your text looks good.',
                style: TextStyle(color: Colors.blue[700]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSuggestTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Text Suggestions',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Get intelligent text completion and continuation suggestions',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),

          // Text input field
          TextFormField(
            controller: suggestController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Enter text to get suggestions...',
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              suffixIcon:
                  suggestController.text.isNotEmpty
                      ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            suggestController.clear();
                            suggestions = [];
                            correctedSuggestionText = '';
                            suggestionsErrorMessage = null;
                          });
                        },
                      )
                      : null,
            ),
            onChanged: (value) {
              // Clear suggestions when text changes
              if (suggestions.isNotEmpty || suggestionsErrorMessage != null) {
                setState(() {
                  suggestions = [];
                  correctedSuggestionText = '';
                  suggestionsErrorMessage = null;
                });
              }
            },
          ),

          const SizedBox(height: 16),

          // Language selector for suggestions
          DropdownButton<String>(
            value: detectedLanguage,
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  detectedLanguage = newValue;
                });
              }
            },
            items:
                <String>[
                  'en-US',
                  'en-GB',
                  'fr-FR',
                  'de-DE',
                  'es-ES',
                  'it-IT',
                  'pt-PT',
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
          ),

          const SizedBox(height: 16),

          // Error message display
          if (suggestionsErrorMessage != null)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[300]!),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      suggestionsErrorMessage!,
                      style: TextStyle(color: Colors.red[700]),
                    ),
                  ),
                ],
              ),
            ),

          // Get suggestions button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoadingSuggestions ? null : _getTextSuggestions,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child:
                  isLoadingSuggestions
                      ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text('Getting Suggestions...'),
                        ],
                      )
                      : const Text('Get Suggestions'),
            ),
          ),

          const SizedBox(height: 16),

          // Suggestions display with Wrap implementation
          if (suggestions.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.indigo[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.indigo[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: Colors.indigo[700],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Continue with:',
                        style: TextStyle(
                          color: Colors.indigo[800],
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Wrap widget with suggestion chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        suggestions
                            .take(5)
                            .map(
                              (suggestion) => InkWell(
                                onTap:
                                    () => _applySuggestion(suggestion.nextWord),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.indigo[200]!,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.add_circle_outline,
                                        color: Colors.indigo[600],
                                        size: 16,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        suggestion.nextWord,
                                        style: TextStyle(
                                          color: Colors.indigo[800],
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                  ),

                  if (suggestions.length > 5)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        '... and ${suggestions.length - 5} more suggestions',
                        style: TextStyle(
                          color: Colors.indigo[600],
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],

          // Empty state when no suggestions
          if (suggestions.isEmpty &&
              !isLoadingSuggestions &&
              suggestController.text.isNotEmpty &&
              suggestionsErrorMessage == null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No suggestions available',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try entering more text to get better suggestions',
                    style: TextStyle(color: Colors.grey[500], fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // Method to apply suggestion to the text field
  void _applySuggestion(String suggestion) {
    String currentText = suggestController.text;

    // Add the suggestion to the end of current text
    // You can modify this logic based on your specific requirements
    String newText = '${currentText.trimRight()} $suggestion';

    setState(() {
      suggestController.text = newText;
      suggestController.selection = TextSelection.fromPosition(
        TextPosition(offset: newText.length),
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Applied suggestion: "$suggestion"'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Widget _buildLangTab() {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Language Detection',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: langController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Enter text for language detection...',
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoadingLanguage ? null : _detectLanguage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child:
                  isLoadingLanguage
                      ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text('Detecting...'),
                        ],
                      )
                      : Text('Detect'),
            ),
          ),
          SizedBox(height: 16),

          // Error message
          if (languageErrorMessage != null)
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.error, color: Colors.red[800]),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      languageErrorMessage!,
                      style: TextStyle(color: Colors.red[800]),
                    ),
                  ),
                ],
              ),
            ),

          // Detection results
          if (detectedLanguageCode != null && !isLoadingLanguage) ...[
            Text(
              'Detected Language',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_getLanguageName(detectedLanguageCode!)} (${detectedLanguageCode!}${detectedDialect != null ? '-${detectedDialect!}' : ''})',
                    style: TextStyle(
                      color: Colors.green[800],
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Confidence: ${_getConfidencePercentage().toStringAsFixed(1)}%',
                    style: TextStyle(color: Colors.green[800]),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryTab() {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Text Summarization',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Enter long text to get keywords, highlights, and summary...',
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 16),

            // Input text area
            Container(
              height: 120,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: TextField(
                controller: summaryController,
                maxLines: null,
                expands: true,
                decoration: InputDecoration(
                  hintText: 'Paste your text here (minimum 50 characters)...',
                  border: InputBorder.none,
                ),
              ),
            ),
            SizedBox(height: 16),

            // Summarize button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoadingSummary ? null : _summarizeText,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child:
                    isLoadingSummary
                        ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            Text('Summarizing...'),
                          ],
                        )
                        : Text('Summarize'),
              ),
            ),

            // Error message
            if (summaryErrorMessage != null) ...[
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red[600], size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        summaryErrorMessage!,
                        style: TextStyle(color: Colors.red[700]),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            SizedBox(height: 24),

            // Keywords Section
            if (summaryKeywords.isNotEmpty) ...[
              Text(
                'Keywords',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children:
                    summaryKeywords
                        .map(
                          (keyword) => Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.blue[200]!),
                            ),
                            child: Text(
                              keyword,
                              style: TextStyle(
                                color: Colors.blue[800],
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        )
                        .toList(),
              ),
              SizedBox(height: 24),
            ],

            // Highlights Section
            if (summaryHighlights.isNotEmpty) ...[
              Text(
                'Key Highlights',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:
                    summaryHighlights
                        .map(
                          (highlight) => Padding(
                            padding: EdgeInsets.only(bottom: 8),
                            child: _buildHighlightItem(highlight),
                          ),
                        )
                        .toList(),
              ),
              SizedBox(height: 24),
            ],

            // Summary Section
            if (summaryResults.isNotEmpty) ...[
              Text(
                'Summary',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:
                    summaryResults
                        .asMap()
                        .entries
                        .map(
                          (entry) => Padding(
                            padding: EdgeInsets.only(bottom: 8),
                            child: _buildSummaryItem(
                              entry.key + 1,
                              entry.value,
                            ),
                          ),
                        )
                        .toList(),
              ),
            ],

            // Show placeholder content if no results yet and not loading
            if (summaryKeywords.isEmpty &&
                summaryHighlights.isEmpty &&
                summaryResults.isEmpty &&
                !isLoadingSummary &&
                summaryErrorMessage == null) ...[
              Text(
                'Keywords',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Keywords will appear here after summarization...',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
              SizedBox(height: 24),

              Text(
                'Key Highlights',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Key highlights will appear here after summarization...',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
              SizedBox(height: 24),

              Text(
                'Summary',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Summary points will appear here after summarization...',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHighlightItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 4,
          height: 4,
          margin: EdgeInsets.only(top: 8, right: 8),
          decoration: BoxDecoration(
            color: Colors.orange,
            shape: BoxShape.circle,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.orange[800],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryItem(int index, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20,
          height: 20,
          margin: EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: Colors.green[600],
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$index',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.green[800],
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
