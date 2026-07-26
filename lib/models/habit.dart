class Habit {
  final String id;
  final String name;
  final String emoji;
  final String category; // Morning, Night, Custom
  final DateTime createdAt;
  final bool archived;

  Habit({
    required this.id,
    required this.name,
    required this.emoji,
    required this.category,
    required this.createdAt,
    this.archived = false,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'emoji': emoji,
        'category': category,
        'createdAt': createdAt.toIso8601String(),
        'archived': archived ? 1 : 0,
      };

  factory Habit.fromMap(Map<String, dynamic> m) => Habit(
        id: m['id'] as String,
        name: m['name'] as String,
        emoji: m['emoji'] as String,
        category: m['category'] as String,
        createdAt: DateTime.parse(m['createdAt'] as String),
        archived: (m['archived'] as int) == 1,
      );
}

class HabitLog {
  final String id;
  final String habitId;
  final String date; // yyyy-MM-dd
  final bool done;

  HabitLog({
    required this.id,
    required this.habitId,
    required this.date,
    required this.done,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'habitId': habitId,
        'date': date,
        'done': done ? 1 : 0,
      };

  factory HabitLog.fromMap(Map<String, dynamic> m) => HabitLog(
        id: m['id'] as String,
        habitId: m['habitId'] as String,
        date: m['date'] as String,
        done: (m['done'] as int) == 1,
      );
}
