import 'package:uuid/uuid.dart';
import '../database/database_helper.dart';
import '../database/database_tables.dart';
import '../models/journal_entry.dart';

class JournalRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final _uuid = const Uuid();

  Future<JournalEntry> insert(JournalEntry entry) async {
    final db = await _dbHelper.database;
    final e = entry.copyWith(id: _uuid.v4());
    await db.insert(DatabaseTables.tableJournalEntries, e.toJson());
    return e;
  }

  Future<List<JournalEntry>> getAll() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      DatabaseTables.tableJournalEntries,
      orderBy: 'date DESC, time DESC',
    );
    return maps.map((m) => JournalEntry.fromJson(m)).toList();
  }

  Future<List<JournalEntry>> getByDateRange(String startDate, String endDate) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      DatabaseTables.tableJournalEntries,
      where: 'date >= ? AND date <= ?',
      whereArgs: [startDate, endDate],
      orderBy: 'date DESC, time DESC',
    );
    return maps.map((m) => JournalEntry.fromJson(m)).toList();
  }

  Future<JournalEntry?> getById(String id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      DatabaseTables.tableJournalEntries,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return JournalEntry.fromJson(maps.first);
  }

  Future<int> update(JournalEntry entry) async {
    final db = await _dbHelper.database;
    return await db.update(
      DatabaseTables.tableJournalEntries,
      entry.toJson(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  Future<int> delete(String id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      DatabaseTables.tableJournalEntries,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

