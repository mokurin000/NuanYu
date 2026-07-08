import 'package:uuid/uuid.dart';
import '../database/database_helper.dart';
import '../database/database_tables.dart';
import '../models/mood_entry.dart';

class MoodRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final _uuid = const Uuid();

  Future<MoodEntry> insert(MoodEntry entry) async {
    final db = await _dbHelper.database;
    final e = entry.copyWith(id: _uuid.v4());
    await db.insert(DatabaseTables.tableMoodEntries, e.toJson());
    return e;
  }

  Future<List<MoodEntry>> getAll() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      DatabaseTables.tableMoodEntries,
      orderBy: 'date DESC, time DESC',
    );
    return maps.map((m) => MoodEntry.fromJson(m)).toList();
  }

  Future<List<MoodEntry>> getByDateRange(String startDate, String endDate) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      DatabaseTables.tableMoodEntries,
      where: 'date >= ? AND date <= ?',
      whereArgs: [startDate, endDate],
      orderBy: 'date DESC, time DESC',
    );
    return maps.map((m) => MoodEntry.fromJson(m)).toList();
  }

  Future<List<MoodEntry>> getByDate(String date) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      DatabaseTables.tableMoodEntries,
      where: 'date = ?',
      whereArgs: [date],
      orderBy: 'time DESC',
    );
    return maps.map((m) => MoodEntry.fromJson(m)).toList();
  }

  Future<MoodEntry?> getById(String id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      DatabaseTables.tableMoodEntries,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return MoodEntry.fromJson(maps.first);
  }

  Future<int> update(MoodEntry entry) async {
    final db = await _dbHelper.database;
    return await db.update(
      DatabaseTables.tableMoodEntries,
      entry.toJson(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  Future<int> delete(String id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      DatabaseTables.tableMoodEntries,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

