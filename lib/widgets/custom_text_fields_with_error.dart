import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

enum ErrorType { grammar, spelling, autocorrect }

class TextError {
  int start;
  int end;
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
  final List<TextError> errors;
  final String hintText;

  const CustomTextFieldWithErrors({
    super.key,
    required this.controller,
    required this.errors,
    this.hintText = '',
  });

  @override
  State<CustomTextFieldWithErrors> createState() =>
      _CustomTextFieldWithErrorsState();
}

class _CustomTextFieldWithErrorsState extends State<CustomTextFieldWithErrors> {
  OverlayEntry? _overlayEntry;

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
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
        return Icons.edit;
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

  double _calculateDialogWidth(String text) {
    double baseWidth = 100.0;
    double charWidth = 8.0;
    double textWidth = text.length * charWidth;
    double totalWidth = baseWidth + textWidth + 40.0;
    return totalWidth.clamp(120.0, 300.0);
  }

  void _showSuggestion(BuildContext context, TextError error) {
    _removeOverlay();

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final position = renderBox.localToGlobal(Offset.zero);

    String longerText =
        error.originalText.length > error.suggestion.length
            ? error.originalText
            : error.suggestion;
    double dialogWidth = _calculateDialogWidth(longerText);

    _overlayEntry = OverlayEntry(
      builder:
          (context) => GestureDetector(
            onTap: _removeOverlay,
            child: Container(
              color: Colors.transparent,
              child: Stack(
                children: [
                  Positioned(
                    left: (position.dx + 20).clamp(
                      20.0,
                      MediaQuery.of(context).size.width - dialogWidth - 20,
                    ),
                    top: position.dy + renderBox.size.height + 8,
                    child: Material(
                      elevation: 8,
                      borderRadius: BorderRadius.circular(12),
                      shadowColor: Colors.black26,
                      child: Container(
                        width: dialogWidth,
                        padding: const EdgeInsets.all(16),
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
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _getErrorTypeLabel(error.type),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            GestureDetector(
                              onTap: () {
                                _applySuggestion(error);
                                _removeOverlay();
                              },
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey[200]!),
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
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
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

    int diff = error.suggestion.length - (error.end - error.start);

    widget.controller.text = newText;
    widget.controller.selection = TextSelection.collapsed(
      offset: error.start + error.suggestion.length,
    );

    // remove error and shift others
    setState(() {
      widget.errors.remove(error);
      for (var e in widget.errors) {
        if (e.start > error.end) {
          e.start += diff;
          e.end += diff;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final text = widget.controller.text;

    // Show hint text if no text is entered
    if (text.isEmpty && widget.hintText.isNotEmpty) {
      return GestureDetector(
        onTap: _removeOverlay,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Text(
            widget.hintText,
            style: TextStyle(fontSize: 16, color: Colors.grey[400]),
          ),
        ),
      );
    }

    final spans = <TextSpan>[];
    int cursor = 0;

    final sortedErrors = [...widget.errors]
      ..sort((a, b) => a.start.compareTo(b.start));

    for (var e in sortedErrors) {
      if (e.start > cursor) {
        spans.add(TextSpan(text: text.substring(cursor, e.start)));
      }
      spans.add(
        TextSpan(
          text: text.substring(e.start, e.end),
          style: TextStyle(
            decoration: TextDecoration.underline,
            decorationColor: _getErrorColor(e.type),
            decorationStyle: TextDecorationStyle.solid,
            decorationThickness: 3,
          ),
          recognizer:
              (TapGestureRecognizer()
                ..onTap = () {
                  _showSuggestion(context, e);
                }),
        ),
      );
      cursor = e.end;
    }
    if (cursor < text.length) {
      spans.add(TextSpan(text: text.substring(cursor)));
    }

    return GestureDetector(
      onTap: _removeOverlay,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 16, color: Colors.black),
            children: spans,
          ),
        ),
      ),
    );
  }
}
