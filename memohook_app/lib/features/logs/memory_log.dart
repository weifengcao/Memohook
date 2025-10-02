class MemoryLog {
  MemoryLog({
    required this.id,
    required this.content,
    required this.createdAt,
    this.keywords = const <String>[],
  });

  final String id;
  final String content;
  final DateTime createdAt;
  final List<String> keywords;

  MemoryLog copyWith({
    String? id,
    String? content,
    DateTime? createdAt,
    List<String>? keywords,
  }) {
    return MemoryLog(
      id: id ?? this.id,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      keywords: keywords ?? this.keywords,
    );
  }

  static MemoryLog create({
    required String content,
    DateTime? createdAt,
    List<String> keywords = const <String>[],
  }) {
    final timestamp = createdAt ?? DateTime.now();
    final id = '${timestamp.microsecondsSinceEpoch}-${content.hashCode.abs()}';
    return MemoryLog(
      id: id,
      content: content,
      createdAt: timestamp,
      keywords: keywords,
    );
  }
}
