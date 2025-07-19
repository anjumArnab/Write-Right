import 'package:flutter/material.dart';
import 'package:write_right/models/text_gears_error.dart';
import 'package:write_right/services/api_service.dart';
import 'package:write_right/widgets/custom_text_fields_with_error.dart';

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
  String autoText = 'Whats you\'re name?';
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
  }

  @override
  void dispose() {
    _tabController.dispose();
    grammarController.dispose();
    spellingController.dispose();
    autoController.dispose();
    suggestController.dispose();
    langController.dispose();
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
            'Click on underlined words to see suggestions',
            style: TextStyle(color: Colors.grey[600]),
          ),
          SizedBox(height: 16),
          CustomTextFieldWithErrors(
            controller: autoController,
            hintText: 'Enter text for auto-correction...',
            errors: [
              TextError(
                start: 0,
                end: 5,
                type: ErrorType.autocorrect,
                suggestion: 'What\'s',
                originalText: 'Whats',
              ),
              TextError(
                start: 6,
                end: 12,
                type: ErrorType.autocorrect,
                suggestion: 'your',
                originalText: 'you\'re',
              ),
            ],
          ),
          SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Simulate auto-correction
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Auto-correction completed!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text('Auto-Correct'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestTab() {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Text Suggestions',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: suggestController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Enter text for suggestions...',
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Continue with:',
                  style: TextStyle(
                    color: Colors.blue[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text('wishes', style: TextStyle(color: Colors.blue[800])),
                Text('lives', style: TextStyle(color: Colors.blue[800])),
                Text('enjoys', style: TextStyle(color: Colors.blue[800])),
              ],
            ),
          ),
        ],
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
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Detect'),
            ),
          ),
          SizedBox(height: 16),
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
                  'French (fr-FR)',
                  style: TextStyle(
                    color: Colors.green[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Confidence: 95%',
                  style: TextStyle(color: Colors.green[800]),
                ),
              ],
            ),
          ),
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
              'Enter long text to summarize...',
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
                maxLines: null,
                expands: true,
                decoration: InputDecoration(
                  hintText: 'Paste your text here...',
                  border: InputBorder.none,
                ),
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Summarize'),
              ),
            ),
            SizedBox(height: 24),

            // Keywords Section
            Text(
              'Keywords',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'text, readability, english, printing, fewer, words, terms, higher, features, indexes',
              style: TextStyle(color: Colors.blue[800], fontSize: 14),
            ),
            SizedBox(height: 24),

            // Highlights Section
            Text(
              'Key Highlights',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHighlightItem(
                  'The two main factors of readability are the printing and linguistic features of the text.',
                ),
                SizedBox(height: 8),
                _buildHighlightItem(
                  'In other words, pages containing simple and clear text get higher positions in the search results.',
                ),
              ],
            ),
            SizedBox(height: 24),

            // Summary Section
            Text(
              'Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryItem(
                  1,
                  'The two main factors of readability are the printing and linguistic features of the text.',
                ),
                SizedBox(height: 8),
                _buildSummaryItem(
                  2,
                  'The Flesch Kinkaid Score is the most popular way to measure the readability of English text.',
                ),
                SizedBox(height: 8),
                _buildSummaryItem(
                  3,
                  'It works on the principle of "the fewer words in the text, and the fewer syllables in them, the easier it is to perceive" and is most often used for checking essays in schools and universities.',
                ),
              ],
            ),
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
