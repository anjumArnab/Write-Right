import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/check_button.dart';
import '../widgets/lang_dropdown.dart';
import '../widgets/custom_text_fields_with_error.dart';
import '../provider/text_gears_provider.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Controllers for TextFormField widgets
  TextEditingController grammarController = TextEditingController();
  TextEditingController spellingController = TextEditingController();
  TextEditingController autoController = TextEditingController();
  TextEditingController suggestController = TextEditingController();
  TextEditingController langController = TextEditingController();
  TextEditingController summaryController = TextEditingController();

  String grammarText =
      'My friend don\'t goes to school regular. He always playing games and not studying good. Yesterday they was very tired but still go to park for play.';
  String spellingText = 'The techer gave us alot of homework yestarday';
  String autoText = 'Whats you\'re name? I have recieved you\'re message.';
  String suggestionText = 'My name is Seth. My family';
  String summaryText = 'The quick brown fox jumps over';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);

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

  // Check grammar using provider
  Future<void> _checkGrammar() async {
    String text = grammarController.text.trim();

    if (text.isEmpty) {
      _showSnackBar('Please enter some text to check', Colors.orange);
      return;
    }

    final provider = Provider.of<TextGearsProvider>(context, listen: false);

    try {
      await provider.checkGrammar(text);

      final errors = provider.grammarErrors;
      _showSnackBar(
        errors.isEmpty
            ? 'No grammar errors found!'
            : 'Found ${errors.length} grammar error(s)',
        errors.isEmpty ? Colors.green : Colors.blue,
      );
    } catch (e) {
      _showSnackBar('Error: ${e.toString()}', Colors.red);
    }
  }

  // Check spelling using provider
  Future<void> _checkSpelling() async {
    String text = spellingController.text.trim();

    if (text.isEmpty) {
      _showSnackBar('Please enter some text to check', Colors.orange);
      return;
    }

    final provider = Provider.of<TextGearsProvider>(context, listen: false);

    try {
      await provider.checkSpelling(text);

      final errors = provider.spellingErrors;
      _showSnackBar(
        errors.isEmpty
            ? 'No spelling errors found!'
            : 'Found ${errors.length} spelling error(s)',
        errors.isEmpty ? Colors.green : Colors.blue,
      );
    } catch (e) {
      _showSnackBar('Error: ${e.toString()}', Colors.red);
    }
  }

  // Auto-correct text using provider
  Future<void> _autoCorrectText() async {
    String text = autoController.text.trim();

    if (text.isEmpty) {
      _showSnackBar('Please enter some text to auto-correct', Colors.orange);
      return;
    }

    final provider = Provider.of<TextGearsProvider>(context, listen: false);

    try {
      await provider.autoCorrectText(text);

      final errors = provider.autoErrors;
      _showSnackBar(
        errors.isEmpty
            ? 'No corrections needed!'
            : 'Found ${errors.length} correction(s)',
        errors.isEmpty ? Colors.green : Colors.blue,
      );
    } catch (e) {
      _showSnackBar('Error: ${e.toString()}', Colors.red);
    }
  }

  // Get text suggestions using provider
  Future<void> _getTextSuggestions() async {
    String text = suggestController.text.trim();

    if (text.isEmpty) {
      _showSnackBar('Please enter some text to get suggestions', Colors.orange);
      return;
    }

    final provider = Provider.of<TextGearsProvider>(context, listen: false);

    try {
      await provider.getTextSuggestions(text);

      final suggestions = provider.suggestions;
      _showSnackBar(
        suggestions.isEmpty
            ? 'No suggestions available for this text'
            : 'Found ${suggestions.length} suggestion(s)',
        suggestions.isEmpty ? Colors.grey : Colors.blue,
      );
    } catch (e) {
      _showSnackBar('Error: ${e.toString()}', Colors.red);
    }
  }

  // Detect language using provider
  Future<void> _detectLanguage() async {
    String text = langController.text.trim();

    if (text.isEmpty) {
      _showSnackBar(
        'Please enter some text for language detection',
        Colors.orange,
      );
      return;
    }

    final provider = Provider.of<TextGearsProvider>(context, listen: false);

    try {
      await provider.detectLanguage(text);

      final detectedCode = provider.detectedLanguageCode;
      _showSnackBar(
        detectedCode != null
            ? 'Language detected: ${_getLanguageName(detectedCode)}'
            : 'Language detection completed',
        Colors.green,
      );
    } catch (e) {
      _showSnackBar('Error: ${e.toString()}', Colors.red);
    }
  }

  // Summarize text using provider
  Future<void> _summarizeText() async {
    String text = summaryController.text.trim();

    if (text.isEmpty) {
      _showSnackBar('Please enter some text to summarize', Colors.orange);
      return;
    }

    final provider = Provider.of<TextGearsProvider>(context, listen: false);

    try {
      await provider.summarizeText(text);

      final summaryResults = provider.summaryResults;
      _showSnackBar(
        'Text summarized successfully! Generated ${summaryResults.length} key points.',
        Colors.green,
      );
    } catch (e) {
      _showSnackBar('Error: ${e.toString()}', Colors.red);
    }
  }

  // Helper method for showing snack bars
  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: backgroundColor),
    );
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
  double _getConfidencePercentage(
    Map<String, double> probabilities,
    String? detectedCode,
  ) {
    if (probabilities.isEmpty || detectedCode == null) {
      return 0.0;
    }
    return (probabilities[detectedCode] ?? 0.0) * 100;
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
    return Consumer<TextGearsProvider>(
      builder: (context, provider, child) {
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
                errors: provider.grammarErrors,
              ),

              SizedBox(height: 16),

              // Language dropdown
              LanguageDropdownMenu(
                value: provider.selectedLanguage,
                onChanged: (newValue) {
                  if (newValue != null) {
                    provider.setLanguage(newValue);
                  }
                },
                label: 'Language Indicator',
              ),

              SizedBox(height: 16),

              // Error message display
              if (provider.grammarErrorMessage != null)
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
                          provider.grammarErrorMessage!,
                          style: TextStyle(color: Colors.red[700]),
                        ),
                      ),
                    ],
                  ),
                ),

              // Grammar check button
              CheckButton(
                label: 'Check Grammar',
                loadingLabel: 'Checking...',
                isLoading: provider.isLoadingGrammar,
                onPressed: _checkGrammar,
                backgroundColor: Colors.blue,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSpellingTab() {
    return Consumer<TextGearsProvider>(
      builder: (context, provider, child) {
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
                errors: provider.spellingErrors,
              ),

              SizedBox(height: 16),

              // Language selector for spelling
              LanguageDropdownMenu(
                value: provider.selectedLanguage,
                onChanged: (newValue) {
                  if (newValue != null) {
                    provider.setLanguage(newValue);
                  }
                },
                label: 'Spelling Language',
              ),

              SizedBox(height: 16),

              // Error message display
              if (provider.spellingErrorMessage != null)
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
                          provider.spellingErrorMessage!,
                          style: TextStyle(color: Colors.red[700]),
                        ),
                      ),
                    ],
                  ),
                ),

              // Spelling check button
              CheckButton(
                label: 'Check Spelling',
                loadingLabel: 'Checking...',
                isLoading: provider.isLoadingSpelling,
                onPressed: _checkSpelling,
                backgroundColor: Colors.purple,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAutoTab() {
    return Consumer<TextGearsProvider>(
      builder: (context, provider, child) {
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

              // Custom text field with error highlighting
              CustomTextFieldWithErrors(
                controller: autoController,
                hintText: 'Enter text for auto-correction...',
                errors: provider.autoErrors,
              ),

              SizedBox(height: 16),

              // Language selector for auto-correction
              LanguageDropdownMenu(
                value: provider.selectedLanguage,
                onChanged: (newValue) {
                  if (newValue != null) {
                    provider.setLanguage(newValue);
                  }
                },
                label: 'Auto-Correction Language',
              ),

              SizedBox(height: 16),

              // Error message display
              if (provider.autoErrorMessage != null)
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
                          provider.autoErrorMessage!,
                          style: TextStyle(color: Colors.red[700]),
                        ),
                      ),
                    ],
                  ),
                ),

              // Auto-correct button
              CheckButton(
                label: 'Find Auto-Corrections',
                loadingLabel: 'Analyzing...',
                isLoading: provider.isLoadingAutoCorrect,
                onPressed: _autoCorrectText,
                backgroundColor: Colors.green,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSuggestTab() {
    return Consumer<TextGearsProvider>(
      builder: (context, provider, child) {
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
                              });
                              provider.clearSuggestionsResults();
                            },
                          )
                          : null,
                ),
                onChanged: (value) {
                  // Clear suggestions when text changes
                  if (provider.suggestions.isNotEmpty ||
                      provider.suggestionsErrorMessage != null) {
                    provider.clearSuggestionsResults();
                  }
                },
              ),

              const SizedBox(height: 16),

              // Language selector for suggestions
              LanguageDropdownMenu(
                value: provider.selectedLanguage,
                onChanged: (newValue) {
                  if (newValue != null) {
                    provider.setLanguage(newValue);
                  }
                },
                label: 'Suggestions Language',
              ),

              const SizedBox(height: 16),

              // Error message display
              if (provider.suggestionsErrorMessage != null)
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
                          provider.suggestionsErrorMessage!,
                          style: TextStyle(color: Colors.red[700]),
                        ),
                      ),
                    ],
                  ),
                ),

              // Get suggestions button
              CheckButton(
                label: 'Get Suggestions',
                loadingLabel: 'Getting Suggestions...',
                isLoading: provider.isLoadingSuggestions,
                onPressed: _getTextSuggestions,
                backgroundColor: Colors.indigo,
              ),

              const SizedBox(height: 16),

              // Suggestions display with Wrap implementation
              if (provider.suggestions.isNotEmpty) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
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
                          provider.suggestions
                              .take(5)
                              .map(
                                (suggestion) => InkWell(
                                  onTap:
                                      () =>
                                          _applySuggestion(suggestion.nextWord),
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
                                    child: Text(
                                      suggestion.nextWord,
                                      style: TextStyle(
                                        color: Colors.indigo[800],
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                    ),

                    if (provider.suggestions.length > 5)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          '... and ${provider.suggestions.length - 5} more suggestions',
                          style: TextStyle(
                            color: Colors.indigo[600],
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  // Method to apply suggestion to the text field
  void _applySuggestion(String suggestion) {
    String currentText = suggestController.text;
    String newText = '${currentText.trimRight()} $suggestion';

    setState(() {
      suggestController.text = newText;
      suggestController.selection = TextSelection.fromPosition(
        TextPosition(offset: newText.length),
      );
    });

    _showSnackBar('Applied suggestion: "$suggestion"', Colors.green);
  }

  Widget _buildLangTab() {
    return Consumer<TextGearsProvider>(
      builder: (context, provider, child) {
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

              // Detect Language button
              CheckButton(
                label: 'Detect',
                loadingLabel: 'Detecting...',
                isLoading: provider.isLoadingLanguage,
                onPressed: _detectLanguage,
                backgroundColor: Colors.blue,
              ),
              SizedBox(height: 16),

              // Error message
              if (provider.languageErrorMessage != null)
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
                          provider.languageErrorMessage!,
                          style: TextStyle(color: Colors.red[800]),
                        ),
                      ),
                    ],
                  ),
                ),

              // Detection results
              if (provider.detectedLanguageCode != null &&
                  !provider.isLoadingLanguage) ...[
                Center(
                  child: Column(
                    children: [
                      SizedBox(height: 24),
                      Text(
                        'Detected Language:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        _getLanguageName(provider.detectedLanguageCode!),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      if (provider.detectedDialect != null) ...[
                        SizedBox(height: 4),
                        Text(
                          'Dialect: ${provider.detectedDialect}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                      SizedBox(height: 8),
                      Text(
                        'Confidence: ${_getConfidencePercentage(provider.languageProbabilities, provider.detectedLanguageCode).toStringAsFixed(2)}%',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryTab() {
    return Consumer<TextGearsProvider>(
      builder: (context, provider, child) {
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
                      hintText:
                          'Paste your text here (minimum 50 characters)...',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Summarize button
                CheckButton(
                  label: 'Summarize',
                  loadingLabel: 'Summarizing...',
                  isLoading: provider.isLoadingSummary,
                  onPressed: _summarizeText,
                  backgroundColor: Colors.blue,
                ),

                // Error message
                if (provider.summaryErrorMessage != null) ...[
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
                            provider.summaryErrorMessage!,
                            style: TextStyle(color: Colors.red[700]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                SizedBox(height: 24),

                // Keywords Section
                if (provider.summaryKeywords.isNotEmpty) ...[
                  Text(
                    'Keywords',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children:
                        provider.summaryKeywords
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
                if (provider.summaryHighlights.isNotEmpty) ...[
                  Text(
                    'Key Highlights',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:
                        provider.summaryHighlights
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
                if (provider.summaryResults.isNotEmpty) ...[
                  Text(
                    'Summary',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:
                        provider.summaryResults
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
                if (provider.summaryKeywords.isEmpty &&
                    provider.summaryHighlights.isEmpty &&
                    provider.summaryResults.isEmpty &&
                    !provider.isLoadingSummary &&
                    provider.summaryErrorMessage == null) ...[
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
      },
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
