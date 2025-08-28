class TextGearsException implements Exception {
  final String message;
  final int? statusCode;

  TextGearsException(this.message, [this.statusCode]);

  @override
  String toString() => 'TextGearsException: $message';
}
