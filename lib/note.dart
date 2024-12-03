class Note {
  final int? id;
  final String title;
  final String content;
  final String createdAt;
  final String modifiedAt;
  final int accountId; // Додано поле accountId

  Note({
    required this.accountId,
    this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.modifiedAt,

  });

  /// Перетворення з Map у об'єкт Note
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      createdAt: map['created_at'],
      modifiedAt: map['modified_at'],
      accountId: map['account_id'], // Витягуємо accountId з Map
    );
  }

  /// Перетворення з Note у Map (для бази даних)
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'title': title,
      'content': content,
      'created_at': createdAt,
      'modified_at': modifiedAt,
      'account_id': accountId, // Додаємо accountId
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }
}
