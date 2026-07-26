import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../database/database_helper.dart';
import '../models/note.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final _db = DatabaseHelper.instance;
  List<Note> _notes = [];
  bool _loading = true;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final notes = await _db.getNotes();
    setState(() {
      _notes = notes;
      _loading = false;
    });
  }

  List<Note> get _filtered {
    if (_query.isEmpty) return _notes;
    final q = _query.toLowerCase();
    return _notes
        .where((n) =>
            n.title.toLowerCase().contains(q) ||
            n.content.toLowerCase().contains(q) ||
            n.tags.toLowerCase().contains(q))
        .toList();
  }

  Future<void> _openEditor({Note? existing}) async {
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final contentCtrl = TextEditingController(text: existing?.content ?? '');
    final folderCtrl =
        TextEditingController(text: existing?.folder ?? 'General');
    final tagsCtrl = TextEditingController(text: existing?.tags ?? '');
    bool pinned = existing?.pinned ?? false;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(existing == null ? 'New Note' : 'Edit Note'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(labelText: 'Title'),
                    autofocus: true),
                TextField(
                    controller: contentCtrl,
                    decoration: const InputDecoration(labelText: 'Content'),
                    maxLines: 5),
                TextField(
                    controller: folderCtrl,
                    decoration: const InputDecoration(labelText: 'Folder')),
                TextField(
                    controller: tagsCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Tags (comma separated)')),
                Row(
                  children: [
                    Checkbox(
                      value: pinned,
                      onChanged: (v) => setDialogState(() => pinned = v!),
                    ),
                    const Text('Pin this note'),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                if (titleCtrl.text.trim().isEmpty) return;
                await _db.insertNote(Note(
                  id: existing?.id ?? const Uuid().v4(),
                  title: titleCtrl.text.trim(),
                  content: contentCtrl.text.trim(),
                  folder: folderCtrl.text.trim().isEmpty
                      ? 'General'
                      : folderCtrl.text.trim(),
                  tags: tagsCtrl.text.trim(),
                  updatedAt: DateTime.now(),
                  pinned: pinned,
                ));
                if (ctx.mounted) Navigator.pop(ctx);
                await _load();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search notes...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEditor(),
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _filtered.isEmpty
              ? const Center(child: Text('No notes found.'))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filtered.length,
                    itemBuilder: (ctx, i) {
                      final n = _filtered[i];
                      return Card(
                        child: ListTile(
                          leading: Icon(n.pinned
                              ? Icons.push_pin
                              : Icons.push_pin_outlined),
                          title: Text(n.title),
                          subtitle: Text(n.content,
                              maxLines: 2, overflow: TextOverflow.ellipsis),
                          trailing: Text(n.folder,
                              style: Theme.of(context).textTheme.bodySmall),
                          onTap: () => _openEditor(existing: n),
                          onLongPress: () async {
                            await _db.deleteNote(n.id);
                            await _load();
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
