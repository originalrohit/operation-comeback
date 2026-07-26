import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../database/database_helper.dart';
import '../models/journal_entry.dart';

const _moods = ['😄', '🙂', '😐', '🙁', '😢'];
const _types = ['Daily', 'Gratitude', 'Anger', 'Reflection'];

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final _db = DatabaseHelper.instance;
  List<JournalEntry> _entries = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final entries = await _db.getJournalEntries();
    setState(() {
      _entries = entries;
      _loading = false;
    });
  }

  Future<void> _newEntry() async {
    final contentCtrl = TextEditingController();
    String mood = _moods[1];
    String type = _types[0];

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('New Journal Entry',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: _types
                    .map((t) => ChoiceChip(
                          label: Text(t),
                          selected: type == t,
                          onSelected: (_) => setSheetState(() => type = t),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 12),
              Row(
                children: _moods
                    .map((m) => GestureDetector(
                          onTap: () => setSheetState(() => mood = m),
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: mood == m
                                  ? Theme.of(context)
                                      .colorScheme
                                      .primaryContainer
                                  : null,
                            ),
                            child:
                                Text(m, style: const TextStyle(fontSize: 22)),
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contentCtrl,
                maxLines: 5,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: "What's on your mind?",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    if (contentCtrl.text.trim().isEmpty) return;
                    await _db.insertJournalEntry(JournalEntry(
                      id: const Uuid().v4(),
                      date: DateTime.now(),
                      content: contentCtrl.text.trim(),
                      mood: mood,
                      type: type,
                    ));
                    if (ctx.mounted) Navigator.pop(ctx);
                    await _load();
                  },
                  child: const Text('Save Entry'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Journal')),
      floatingActionButton: FloatingActionButton(
        onPressed: _newEntry,
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _entries.isEmpty
              ? const Center(child: Text('No entries yet. Tap + to write one.'))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _entries.length,
                    itemBuilder: (ctx, i) {
                      final e = _entries[i];
                      return Card(
                        child: ListTile(
                          leading:
                              Text(e.mood, style: const TextStyle(fontSize: 26)),
                          title: Text(e.type,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(e.content,
                              maxLines: 3, overflow: TextOverflow.ellipsis),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(DateFormat('MMM d').format(e.date),
                                  style: Theme.of(context).textTheme.bodySmall),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, size: 18),
                                onPressed: () async {
                                  await _db.deleteJournalEntry(e.id);
                                  await _load();
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
