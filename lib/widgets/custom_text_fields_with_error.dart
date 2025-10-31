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

  int get endOffset => start + length;
  int get length => end - start;

  TextError copyWith({
    int? start,
    int? end,
    ErrorType? type,
    String? suggestion,
    String? originalText,
  }) {
    return TextError(
      start: start ?? this.start,
      end: end ?? this.end,
      type: type ?? this.type,
      suggestion: suggestion ?? this.suggestion,
      originalText: originalText ?? this.originalText,
    );
  }
}

// Custom TextEditingController that handles error highlighting
class ErrorTextEditingController extends TextEditingController {
  final List<TextError> errors;
  final List<TapGestureRecognizer> _recognizers = [];
  final Function(TextError, Offset)? onErrorTap;

  ErrorTextEditingController({
    required this.errors,
    this.onErrorTap,
    String? text,
  }) : super(text: text);

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

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final defaultStyle = style ?? const TextStyle(fontSize: 16, color: Colors.black);
    
    if (text.isEmpty || errors.isEmpty) {
      return TextSpan(text: text, style: defaultStyle);
    }

    // Dispose old recognizers
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    _recognizers.clear();

    final spans = <TextSpan>[];
    int cursor = 0;

    // Sort errors by start position
    final sortedErrors = [...errors]..sort((a, b) => a.start.compareTo(b.start));

    for (var error in sortedErrors) {
      // Validate error bounds
      if (error.start < 0 || error.end > text.length || error.start >= error.end) {
        continue;
      }

      // Add text before error
      if (error.start > cursor) {
        spans.add(TextSpan(
          text: text.substring(cursor, error.start),
          style: defaultStyle,
        ));
      }

      // Create tap recognizer for this error
      final recognizer = TapGestureRecognizer()
        ..onTapDown = (details) {
          if (onErrorTap != null) {
            onErrorTap!(error, details.globalPosition);
          }
        };

      _recognizers.add(recognizer);

      // Add highlighted error text
      spans.add(
        TextSpan(
          text: text.substring(error.start, error.end),
          style: defaultStyle.copyWith(
            decoration: TextDecoration.underline,
            decorationColor: _getErrorColor(error.type),
            decorationStyle: TextDecorationStyle.solid,
            decorationThickness: 3,
          ),
          recognizer: recognizer,
        ),
      );

      cursor = error.end;
    }

    // Add remaining text
    if (cursor < text.length) {
      spans.add(TextSpan(
        text: text.substring(cursor),
        style: defaultStyle,
      ));
    }

    return TextSpan(style: defaultStyle, children: spans);
  }

  @override
  void dispose() {
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    _recognizers.clear();
    super.dispose();
  }
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
  late ErrorTextEditingController _errorController;
  OverlayEntry? _overlayEntry;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _createErrorController();
    
    // Listen to the original controller and sync with error controller
    widget.controller.addListener(_syncControllers);
  }

  @override
  void didUpdateWidget(CustomTextFieldWithErrors oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Recreate error controller if errors changed
    if (widget.errors != oldWidget.errors || 
        widget.controller != oldWidget.controller) {
      _errorController.dispose();
      
      if (oldWidget.controller != widget.controller) {
        oldWidget.controller.removeListener(_syncControllers);
        widget.controller.addListener(_syncControllers);
      }
      
      _createErrorController();
    }
  }

  void _createErrorController() {
    _errorController = ErrorTextEditingController(
      errors: widget.errors,
      text: widget.controller.text,
      onErrorTap: _showSuggestion,
    );
  }

  void _syncControllers() {
    if (_errorController.text != widget.controller.text) {
      final selection = widget.controller.selection;
      _errorController.value = widget.controller.value;
      
      // Recreate controller with updated errors
      _errorController.dispose();
      _createErrorController();
      _errorController.selection = selection;
      
      setState(() {});
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_syncControllers);
    _removeOverlay();
    _errorController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

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

  void _showSuggestion(TextError error, Offset globalPosition) {
    _removeOverlay();

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    String longerText =
        error.originalText.length > error.suggestion.length
            ? error.originalText
            : error.suggestion;
    double dialogWidth = _calculateDialogWidth(longerText);

    _overlayEntry = OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: _removeOverlay,
        child: Container(
          color: Colors.transparent,
          child: Stack(
            children: [
              Positioned(
                left: (globalPosition.dx - 50).clamp(
                  20.0,
                  MediaQuery.of(context).size.width - dialogWidth - 20,
                ),
                top: globalPosition.dy + 20,
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

    // Update the main controller
    widget.controller.text = newText;
    widget.controller.selection = TextSelection.collapsed(
      offset: error.start + error.suggestion.length,
    );

    // Remove error and shift others
    widget.errors.remove(error);
    for (var e in widget.errors) {
      if (e.start > error.end) {
        e.start += diff;
        e.end += diff;
      }
    }

    // Trigger rebuild
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _focusNode.requestFocus();
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: TextField(
          controller: _errorController,
          focusNode: _focusNode,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black,
          ),
          cursorColor: Colors.blue,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: widget.hintText,
            hintStyle: TextStyle(fontSize: 16, color: Colors.grey[400]),
            isDense: true,
            contentPadding: EdgeInsets.zero,
          ),
          maxLines: null,
          onChanged: (value) {
            // Sync back to the original controller
            if (widget.controller.text != value) {
              widget.controller.text = value;
              widget.controller.selection = _errorController.selection;
            }
          },
        ),
      ),
    );
  }
}