import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _underlineController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _syncControllers();
    widget.controller.addListener(_syncControllers);
  }

  @override
  void dispose() {
    _removeOverlay();
    _focusNode.dispose();
    _underlineController.dispose();
    widget.controller.removeListener(_syncControllers);
    super.dispose();
  }

  void _syncControllers() {
    if (_underlineController.text != widget.controller.text) {
      _underlineController.text = widget.controller.text;
    }
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

  TextError? _findErrorAtPosition(int position) {
    // Find the most specific error (smallest range) at the position
    TextError? bestMatch;
    int smallestRange = double.maxFinite.toInt();

    for (TextError error in _validErrors) {
      // Check if position is within error range
      if (position >= error.start && position < error.end) {
        int range = error.end - error.start;
        if (range < smallestRange) {
          smallestRange = range;
          bestMatch = error;
        }
      }
    }
    return bestMatch;
  }

  double _calculateDialogWidth(String text) {
    double baseWidth = 100.0;
    double charWidth = 8.0;
    double textWidth = text.length * charWidth;
    double totalWidth = baseWidth + textWidth + 40.0;
    return totalWidth.clamp(120.0, 300.0);
  }

  void _showSuggestion(TextError error) {
    _removeOverlay();
    selectedError = error;

    // Get the RenderBox to calculate position
    RenderBox? renderBox =
        _textFieldKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    Offset position = renderBox.localToGlobal(Offset.zero);
    Size size = renderBox.size;

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
                    top: position.dy + size.height + 8,
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
                                GestureDetector(
                                  onTap: _removeOverlay,
                                  child: const Icon(Icons.close, size: 18),
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
                                        decoration: TextDecoration.lineThrough,
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

    // Calculate the offset difference for cursor positioning
    int lengthDifference = error.suggestion.length - (error.end - error.start);

    widget.controller.text = newText;

    // Position cursor at the end of the replaced text
    int newCursorPosition = error.start + error.suggestion.length;
    widget.controller.selection = TextSelection.fromPosition(
      TextPosition(offset: newCursorPosition),
    );

    // Update errors list indices to account for text length change
    _adjustErrorIndicesAfterReplacement(error, lengthDifference);

    setState(() {});
  }

  void _adjustErrorIndicesAfterReplacement(
    TextError replacedError,
    int lengthDifference,
  ) {
    // This would ideally be handled by the parent widget that manages the errors list
    // For now, we just trigger a rebuild which should update the errors
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
          // Background TextField for underlines (non-interactive)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: TextField(
              controller: _underlineController,
              style: TextStyle(
                color: Colors.transparent,
                fontSize: 16,
                height: 1.2,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              maxLines: 3,
              minLines: 1,
              enabled: false,
            ),
          ),
          // Overlay for error underlines
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: IgnorePointer(
              child: RichText(
                text: _buildStyledTextSpan(),
                maxLines: 3,
                overflow: TextOverflow.visible,
              ),
            ),
          ),
          // Main interactive TextField
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                height: 1.2,
              ),
              cursorColor: Colors.blue,
              cursorWidth: 2,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText:
                    widget.controller.text.isEmpty ? widget.hintText : null,
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              maxLines: 3,
              minLines: 1,
              onTap: () {
                // Use a small delay to ensure cursor position is accurate
                Future.delayed(const Duration(milliseconds: 50), () {
                  int cursorPosition = widget.controller.selection.baseOffset;
                  if (cursorPosition >= 0 &&
                      widget.controller.text.isNotEmpty) {
                    TextError? error = _findErrorAtPosition(cursorPosition);
                    if (error != null) {
                      _showSuggestion(error);
                    } else {
                      _removeOverlay();
                    }
                  }
                });
              },
              onChanged: (value) {
                setState(() {});
                _removeOverlay();
              },
            ),
          ),
        ],
      ),
    );
  }

  TextSpan _buildStyledTextSpan() {
    String text = widget.controller.text;
    if (text.isEmpty) {
      return const TextSpan();
    }

    List<TextSpan> spans = [];
    int currentIndex = 0;

    // Sort errors by start position to handle overlaps correctly
    List<TextError> sortedErrors = List.from(_validErrors);
    sortedErrors.sort((a, b) => a.start.compareTo(b.start));

    for (TextError error in sortedErrors) {
      // Skip errors that would cause index issues
      if (error.start < currentIndex || error.end > text.length) {
        continue;
      }

      // Add normal text before error
      if (error.start > currentIndex) {
        spans.add(
          TextSpan(
            text: text.substring(currentIndex, error.start),
            style: const TextStyle(
              color: Colors.transparent,
              fontSize: 16,
              height: 1.2,
            ),
          ),
        );
      }

      // Add error text with underline
      spans.add(
        TextSpan(
          text: text.substring(error.start, error.end),
          style: TextStyle(
            color: Colors.transparent,
            fontSize: 16,
            height: 1.2,
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
          style: const TextStyle(
            color: Colors.transparent,
            fontSize: 16,
            height: 1.2,
          ),
        ),
      );
    }

    return TextSpan(children: spans);
  }
}
