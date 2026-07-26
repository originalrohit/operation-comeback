class Note {
  final String id;
  final String title;
  final String content;
  final String folder;
  final String tags; // comma separated
  final DateTime updatedAt;
  final bool pinned;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.folder,
    required this.tags,
    required this.updatedAt,
    this.pinned = false,
  });

  List<String> get tagList =>
      tags.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'content': content,
        'folder': folder,
        'tags': tags,
        'updatedAt': updatedAt.toIso8601String(),
        'pinned': pinned ? 1 : 0,
      };

  factory Note.fromMap(Map<String, dynamic> m) => Note(
        id: m['id'] as String,
        title: m['title'] as String,
        content: m['content'] as String,
        folder: m['folder'] as String,
        tags: m['tags'] as String,
        updatedAt: DateTime.parse(m['updatedAt'] as String),
        pinned: (m['pinned'] as int) == 1,
      );
}
