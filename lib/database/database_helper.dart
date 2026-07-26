import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/habit.dart';
import '../models/journal_entry.dart';
import '../models/note.dart';

class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'operation_comeback.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE habits (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            emoji TEXT NOT NULL,
            category TEXT NOT NULL,
            createdAt TEXT NOT NULL,
            archived INTEGER NOT NULL DEFAULT 0
          )
        ''');
        await db.execute('''
          CREATE TABLE habit_logs (
            id TEXT PRIMARY KEY,
            habitId TEXT NOT NULL,
            date TEXT NOT NULL,
            done INTEGER NOT NULL,
            UNIQUE(habitId, date)
          )
        ''');
        await db.execute('''
          CREATE TABLE journal_entries (
            id TEXT PRIMARY KEY,
            date TEXT NOT NULL,
            content TEXT NOT NULL,
            mood TEXT NOT NULL,
            type TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE notes (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            content TEXT NOT NULL,
            folder TEXT NOT NULL,
            tags TEXT NOT NULL,
            updatedAt TEXT NOT NULL,
            pinned INTEGER NOT NULL DEFAULT 0
          )
        ''');
      },
    );
  }

  // ---------- Habits ----------
  Future<void> insertHabit(Habit h) async {
    final db = await database;
    await db.insert('habits', h.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Habit>> getHabits({bool includeArchived = false}) async {
    final db = await database;
    final rows = await db.query(
      'habits',
      where: includeArchived ? null : 'archived = 0',
      orderBy: 'createdAt ASC',
    );
    return rows.map((r) => Habit.fromMap(r)).toList();
  }

  Future<void> deleteHabit(String id) async {
    final db = await database;
    await db.delete('habits', where: 'id = ?', whereArgs: [id]);
    await db.delete('habit_logs', where: 'habitId = ?', whereArgs: [id]);
  }

  Future<void> setHabitDone(String habitId, String date, bool done) async {
    final db = await database;
    final existing = await db.query('habit_logs',
        where: 'habitId = ? AND date = ?', whereArgs: [habitId, date]);
    if (existing.isNotEmpty) {
      await db.update('habit_logs', {'done': done ? 1 : 0},
          where: 'habitId = ? AND date = ?', whereArgs: [habitId, date]);
    } else {
      await db.insert('habit_logs', {
        'id': '${habitId}_$date',
        'habitId': habitId,
        'date': date,
        'done': done ? 1 : 0,
      });
    }
  }

  Future<List<HabitLog>> getLogsForHabit(String habitId) async {
    final db = await database;
    final rows = await db.query('habit_logs',
        where: 'habitId = ?', whereArgs: [habitId], orderBy: 'date DESC');
    return rows.map((r) => HabitLog.fromMap(r)).toList();
  }

  Future<List<HabitLog>> getLogsForDate(String date) async {
    final db = await database;
    final rows = await db.query('habit_logs', where: 'date = ?', whereArgs: [date]);
    return rows.map((r) => HabitLog.fromMap(r)).toList();
  }

  // ---------- Journal ----------
  Future<void> insertJournalEntry(JournalEntry e) async {
    final db = await database;
    await db.insert('journal_entries', e.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<JournalEntry>> getJournalEntries() async {
    final db = await database;
    final rows = await db.query('journal_entries', orderBy: 'date DESC');
    return rows.map((r) => JournalEntry.fromMap(r)).toList();
  }

  Future<void> deleteJournalEntry(String id) async {
    final db = await database;
    await db.delete('journal_entries', where: 'id = ?', whereArgs: [id]);
  }

  // ---------- Notes ----------
  Future<void> insertNote(Note n) async {
    final db = await database;
    await db.insert('notes', n.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Note>> getNotes() async {
    final db = await database;
    final rows =
        await db.query('notes', orderBy: 'pinned DESC, updatedAt DESC');
    return rows.map((r) => Note.fromMap(r)).toList();
  }

  Future<void> deleteNote(String id) async {
    final db = await database;
    await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }
}
