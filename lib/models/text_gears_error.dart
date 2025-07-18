class TextGearsError {
  final String id;
  final int? offset;
  final int? length;
  final String bad;
  final List<String> better;
  final String type;

  TextGearsError({
    required this.id,
    this.offset,
    this.length,
    required this.bad,
    required this.better,
    required this.type,
  });

  factory TextGearsError.fromJson(Map<String, dynamic> json) {
    return TextGearsError(
      id: json['id'] ?? '',
      offset: json['offset'],
      length: json['length'],
      bad: json['bad'] ?? '',
      better: List<String>.from(json['better'] ?? []),
      type: json['type'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'offset': offset,
      'length': length,
      'bad': bad,
      'better': better,
      'type': type,
    };
  }
}
