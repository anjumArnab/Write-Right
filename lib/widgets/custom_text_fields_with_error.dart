import 'package:flutter/material.dart';

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
