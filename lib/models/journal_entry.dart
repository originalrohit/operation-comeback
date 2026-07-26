class JournalEntry {
  final String id;
  final DateTime date;
  final String content;
  final String mood; // emoji string: 😄 🙂 😐 🙁 😢
  final String type; // Daily, Gratitude, Anger, Reflection

  JournalEntry({
    required this.id,
    required this.date,
    required this.content,
    required this.mood,
    required this.type,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'date': date.toIso8601String(),
        'content': content,
        'mood': mood,
        'type': type,
      };

  factory JournalEntry.fromMap(Map<String, dynamic> m) => JournalEntry(
        id: m['id'] as String,
        date: DateTime.parse(m['date'] as String),
        content: m['content'] as String,
        mood: m['mood'] as String,
        type: m['type'] as String,
      );
}
