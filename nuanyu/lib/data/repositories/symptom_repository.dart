import 'package:uuid/uuid.dart';
import '../database/database_helper.dart';
import '../database/database_tables.dart';
import '../models/symptom_record.dart';

class SymptomRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final _uuid = const Uuid();

  Future<SymptomRecord> insert(SymptomRecord record) async {
    final db = await _dbHelper.database;
    final r = record.copyWith(id: _uuid.v4());
    await db.insert(DatabaseTables.tableSymptomRecords, r.toJson());
    return r;
  }

  Future<List<SymptomRecord>> getAll() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      DatabaseTables.tableSymptomRecords,
      orderBy: 'date DESC, time DESC',
    );
    return maps.map((m) => SymptomRecord.fromJson(m)).toList();
  }

  Future<List<SymptomRecord>> getByDateRange(String startDate, String endDate) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      DatabaseTables.tableSymptomRecords,
      where: 'date >= ? AND date <= ?',
      whereArgs: [startDate, endDate],
      orderBy: 'date DESC, time DESC',
    );
    return maps.map((m) => SymptomRecord.fromJson(m)).toList();
  }

  Future<SymptomRecord?> getById(String id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      DatabaseTables.tableSymptomRecords,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return SymptomRecord.fromJson(maps.first);
  }

  Future<int> update(SymptomRecord record) async {
    final db = await _dbHelper.database;
    return await db.update(
      DatabaseTables.tableSymptomRecords,
      record.toJson(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  Future<int> delete(String id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      DatabaseTables.tableSymptomRecords,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

