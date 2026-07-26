import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../database/database_helper.dart';
import '../models/habit.dart';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  final _db = DatabaseHelper.instance;
  List<Habit> _habits = [];
  Map<String, bool> _todayDone = {};
  Map<String, int> _streaks = {};
  bool _loading = true;
  final _todayKey = DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final habits = await _db.getHabits();
    final todayLogs = await _db.getLogsForDate(_todayKey);
    final doneMap = {for (var l in todayLogs) l.habitId: l.done};

    final streaks = <String, int>{};
    for (final h in habits) {
      streaks[h.id] = await _computeStreak(h.id);
    }

    setState(() {
      _habits = habits;
      _todayDone = doneMap;
      _streaks = streaks;
      _loading = false;
    });
  }

  Future<int> _computeStreak(String habitId) async {
    final logs = await _db.getLogsForHabit(habitId);
    final doneDates = logs.where((l) => l.done).map((l) => l.date).toSet();
    int streak = 0;
    var cursor = DateTime.now();
    while (true) {
      final key = DateFormat('yyyy-MM-dd').format(cursor);
      if (doneDates.contains(key)) {
        streak++;
        cursor = cursor.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  Future<void> _toggle(Habit h) async {
    final newVal = !(_todayDone[h.id] ?? false);
    await _db.setHabitDone(h.id, _todayKey, newVal);
    await _load();
  }

  Future<void> _addHabit() async {
    final nameCtrl = TextEditingController();
    String emoji = '✅';
    String category = 'Custom';
    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('New Habit'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Habit name'),
                autofocus: true,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Emoji: '),
                  const SizedBox(width: 8),
                  DropdownButton<String>(
                    value: emoji,
                    items: ['✅', '💪', '📖', '🧘', '💧', '🏃', '🌙', '☀️']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => setDialogState(() => emoji = v!),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: ['Morning', 'Night', 'Custom']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setDialogState(() => category = v!),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty) return;
                await _db.insertHabit(Habit(
                  id: const Uuid().v4(),
                  name: nameCtrl.text.trim(),
                  emoji: emoji,
                  category: category,
                  createdAt: DateTime.now(),
                ));
                if (ctx.mounted) Navigator.pop(ctx);
                await _load();
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteHabit(Habit h) async {
    await _db.deleteHabit(h.id);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<Habit>>{};
    for (final h in _habits) {
      grouped.putIfAbsent(h.category, () => []).add(h);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Habits')),
      floatingActionButton: FloatingActionButton(
        onPressed: _addHabit,
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _habits.isEmpty
              ? const Center(
                  child: Text('No habits yet. Tap + to add your first one.'))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: grouped.entries.map((entry) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(entry.key,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold)),
                          ),
                          ...entry.value.map((h) => Card(
                                child: ListTile(
                                  leading: Text(h.emoji,
                                      style: const TextStyle(fontSize: 24)),
                                  title: Text(h.name),
                                  subtitle: Text(
                                      '🔥 ${_streaks[h.id] ?? 0} day streak'),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Checkbox(
                                        value: _todayDone[h.id] ?? false,
                                        onChanged: (_) => _toggle(h),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline,
                                            size: 20),
                                        onPressed: () => _deleteHabit(h),
                                      ),
                                    ],
                                  ),
                                ),
                              )),
                        ],
                      );
                    }).toList(),
                  ),
                ),
    );
  }
}
