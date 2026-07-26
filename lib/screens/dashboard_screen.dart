import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  const DashboardScreen({super.key, required this.onToggleTheme});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _db = DatabaseHelper.instance;
  bool _loading = true;
  int _totalHabits = 0;
  int _doneToday = 0;
  int _journalCount = 0;
  int _notesCount = 0;
  String? _lastMood;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final todayKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final habits = await _db.getHabits();
    final logs = await _db.getLogsForDate(todayKey);
    final journal = await _db.getJournalEntries();
    final notes = await _db.getNotes();

    setState(() {
      _totalHabits = habits.length;
      _doneToday = logs.where((l) => l.done).length;
      _journalCount = journal.length;
      _notesCount = notes.length;
      _lastMood = journal.isNotEmpty ? journal.first.mood : null;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final progress = _totalHabits == 0 ? 0.0 : _doneToday / _totalHabits;
    final today = DateFormat('EEEE, MMM d').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Operation Comeback'),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6_outlined),
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(today, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Today's Progress",
                              style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 12),
                          LinearProgressIndicator(
                            value: progress,
                            minHeight: 10,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          const SizedBox(height: 8),
                          Text(
                              '$_doneToday of $_totalHabits habits done today'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.4,
                    children: [
                      _StatCard(
                          label: 'Habits',
                          value: '$_totalHabits',
                          icon: Icons.check_circle_outline),
                      _StatCard(
                          label: 'Journal Entries',
                          value: '$_journalCount',
                          icon: Icons.menu_book_outlined),
                      _StatCard(
                          label: 'Notes',
                          value: '$_notesCount',
                          icon: Icons.note_outlined),
                      _StatCard(
                          label: 'Last Mood',
                          value: _lastMood ?? '—',
                          icon: Icons.mood_outlined,
                          isEmoji: true),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Coming next',
                              style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 8),
                          const Text(
                              '• AI Coach\n• Academics & DSA tracker\n• Placement tracker\n• Fitness tracker\n• Finance tracker\n• Calendar & reminders'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isEmoji;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    this.isEmoji = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(value,
                style: TextStyle(
                    fontSize: isEmoji ? 24 : 22, fontWeight: FontWeight.bold)),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
