import 'package:flutter/material.dart';

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

  String grammarText = 'I is an engeered';
  String spellingText = 'Seperatethewordds carefully';
  String autoText = 'Whats you\'re name?';
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
          CustomTextFieldWithErrors(
            controller: grammarController,
            hintText: 'Enter text to check grammar...',
            errors: [
              TextError(
                start: 2,
                end: 4,
                type: ErrorType.grammar,
                suggestion: 'am',
                originalText: 'is',
              ),
              TextError(
                start: 8,
                end: 16,
                type: ErrorType.grammar,
                suggestion: 'engineer',
                originalText: 'engeered',
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.language, color: Colors.grey[600], size: 16),
              SizedBox(width: 4),
              Text('en-GB', style: TextStyle(color: Colors.grey[600])),
            ],
          ),
          SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Simulate grammar check
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Grammar check completed!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text('Check Grammar'),
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
          CustomTextFieldWithErrors(
            controller: spellingController,
            hintText: 'Enter text to check spelling...',
            errors: [
              TextError(
                start: 0,
                end: 16,
                type: ErrorType.spelling,
                suggestion: 'Separate the words',
                originalText: 'Seperatethewordds',
              ),
            ],
          ),
          SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Simulate spelling check
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Spelling check completed!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text('Check Spelling'),
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

enum ErrorType { grammar, spelling, autocorrect }

class TextError {
  final int start;
  final int end;
  final ErrorType type;
  final String suggestion;
  final String originalText;

  TextError({
    required this.start,
    required this.end,
    required this.type,
    required this.suggestion,
    required this.originalText,
  });
}

class CustomTextFieldWithErrors extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final List<TextError> errors;

  const CustomTextFieldWithErrors({
    super.key,
    required this.controller,
    required this.hintText,
    required this.errors,
  });

  @override
  State<CustomTextFieldWithErrors> createState() =>
      _CustomTextFieldWithErrorsState();
}

class _CustomTextFieldWithErrorsState extends State<CustomTextFieldWithErrors> {
  TextError? selectedError;
  OverlayEntry? _overlayEntry;
  final GlobalKey _textFieldKey = GlobalKey();

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  List<TextError> get _validErrors {
    String text = widget.controller.text;
    return widget.errors
        .where(
          (error) =>
              error.start >= 0 &&
              error.end <= text.length &&
              error.start < error.end,
        )
        .toList();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    selectedError = null;
  }

  TextError? _findErrorAtPosition(String text, int position) {
    for (TextError error in _validErrors) {
      if (position >= error.start && position < error.end) {
        return error;
      }
    }
    return null;
  }

  double _calculateDialogWidth(String text) {
    // Base width for padding and icon
    double baseWidth = 100.0;
    // Estimate character width (average)
    double charWidth = 8.0;
    // Calculate width based on the longer text between original and suggestion
    double textWidth = text.length * charWidth;
    // Add some padding
    double totalWidth = baseWidth + textWidth + 40.0;
    // Ensure minimum and maximum widths
    return totalWidth.clamp(120.0, 280.0);
  }

  void _showSuggestion(TextError error) {
    _removeOverlay();
    selectedError = error;

    // Calculate dialog width based on the longer text
    String longerText =
        error.originalText.length > error.suggestion.length
            ? error.originalText
            : error.suggestion;
    double dialogWidth = _calculateDialogWidth(longerText);

    _overlayEntry = OverlayEntry(
      builder:
          (context) => GestureDetector(
            onTap: _removeOverlay, // Click outside to dismiss
            child: Container(
              color: Colors.transparent,
              child: Stack(
                children: [
                  Positioned(
                    left: 20,
                    top: 200,
                    child: Material(
                      elevation: 12,
                      borderRadius: BorderRadius.circular(12),
                      shadowColor: Colors.black26,
                      child: Container(
                        width: dialogWidth,
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: _getErrorColor(error.type),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    _getErrorIcon(error.type),
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _getErrorTypeLabel(error.type),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: _removeOverlay,
                                  child: Icon(Icons.close, size: 18),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            GestureDetector(
                              onTap: () {
                                _applySuggestion(error);
                                _removeOverlay();
                              },
                              child: Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Original:',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    Text(
                                      '"${error.originalText}"',
                                      style: TextStyle(
                                        decoration: TextDecoration.lineThrough,
                                        color: Colors.red,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Suggestion:',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    Text(
                                      '"${error.suggestion}"',
                                      style: TextStyle(
                                        color: Colors.green[700],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _applySuggestion(TextError error) {
    String text = widget.controller.text;
    String newText =
        text.substring(0, error.start) +
        error.suggestion +
        text.substring(error.end);

    widget.controller.text = newText;

    // Update cursor position
    int newCursorPosition = error.start + error.suggestion.length;
    widget.controller.selection = TextSelection.fromPosition(
      TextPosition(offset: newCursorPosition),
    );

    setState(() {});
  }

  Color _getErrorColor(ErrorType type) {
    switch (type) {
      case ErrorType.grammar:
        return Colors.red;
      case ErrorType.spelling:
        return Colors.orange;
      case ErrorType.autocorrect:
        return Colors.green;
    }
  }

  IconData _getErrorIcon(ErrorType type) {
    switch (type) {
      case ErrorType.grammar:
        return Icons.arrow_forward_ios;
      case ErrorType.spelling:
        return Icons.spellcheck;
      case ErrorType.autocorrect:
        return Icons.auto_fix_high;
    }
  }

  String _getErrorTypeLabel(ErrorType type) {
    switch (type) {
      case ErrorType.grammar:
        return 'Grammar Error';
      case ErrorType.spelling:
        return 'Spelling Error';
      case ErrorType.autocorrect:
        return 'Auto-correction';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: _textFieldKey,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Stack(
        children: [
          // Rich text for displaying errors
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12),
            child: RichText(text: _buildTextSpan()),
          ),
          // Invisible text field for cursor and text input
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: TextField(
                controller: widget.controller,
                style: TextStyle(color: Colors.transparent, fontSize: 16),
                cursorColor: Colors.blue,
                cursorWidth: 2,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText:
                      widget.controller.text.isEmpty ? widget.hintText : '',
                  hintStyle: TextStyle(color: Colors.transparent),
                  contentPadding: EdgeInsets.zero,
                ),
                maxLines: 3,
                onTap: () {
                  // Handle tap to show suggestion
                  int cursorPosition = widget.controller.selection.baseOffset;
                  if (cursorPosition >= 0) {
                    TextError? error = _findErrorAtPosition(
                      widget.controller.text,
                      cursorPosition,
                    );
                    if (error != null) {
                      _showSuggestion(error);
                    } else {
                      _removeOverlay();
                    }
                  }
                },
                onChanged: (value) {
                  setState(() {});
                  _removeOverlay();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  TextSpan _buildTextSpan() {
    String text = widget.controller.text;
    if (text.isEmpty) {
      return TextSpan(
        text: widget.hintText,
        style: TextStyle(color: Colors.grey[400], fontSize: 16),
      );
    }

    List<TextSpan> spans = [];
    int currentIndex = 0;

    // Sort errors by start position
    List<TextError> sortedErrors = List.from(_validErrors);
    sortedErrors.sort((a, b) => a.start.compareTo(b.start));

    for (TextError error in sortedErrors) {
      // Add normal text before error
      if (error.start > currentIndex) {
        spans.add(
          TextSpan(
            text: text.substring(currentIndex, error.start),
            style: TextStyle(color: Colors.black, fontSize: 16),
          ),
        );
      }

      // Add error text with underline
      spans.add(
        TextSpan(
          text: text.substring(error.start, error.end),
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            decoration: TextDecoration.underline,
            decorationColor: _getErrorColor(error.type),
            decorationStyle: TextDecorationStyle.wavy,
            decorationThickness: 2,
          ),
        ),
      );
      currentIndex = error.end;
    }

    // Add remaining text
    if (currentIndex < text.length) {
      spans.add(
        TextSpan(
          text: text.substring(currentIndex),
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
      );
    }

    return TextSpan(children: spans);
  }
}
