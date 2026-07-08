import 'package:uuid/uuid.dart';
import '../database/database_helper.dart';
import '../database/database_tables.dart';
import '../models/self_care_item.dart';
import '../../core/utils/date_utils.dart' as du;

class SelfCareRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final _uuid = const Uuid();

  Future<SelfCareItem> insert(SelfCareItem item) async {
    final db = await _dbHelper.database;
    final i = item.copyWith(id: _uuid.v4());
    await db.insert(DatabaseTables.tableSelfCareItems, i.toJson());
    return i;
  }

  Future<List<SelfCareItem>> getAll() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      DatabaseTables.tableSelfCareItems,
      orderBy: 'created_at DESC',
    );
    return maps.map((m) => SelfCareItem.fromJson(m)).toList();
  }

  Future<SelfCareItem?> getById(String id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      DatabaseTables.tableSelfCareItems,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return SelfCareItem.fromJson(maps.first);
  }

  Future<int> update(SelfCareItem item) async {
    final db = await _dbHelper.database;
    return await db.update(
      DatabaseTables.tableSelfCareItems,
      item.toJson(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> delete(String id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      DatabaseTables.tableSelfCareItems,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> markCompletedToday(String id) async {
    final db = await _dbHelper.database;
    final todayStr = du.formatDate(DateTime.now());
    await db.update(
      DatabaseTables.tableSelfCareItems,
      {
        'is_completed_today': 1,
        'last_completed_date': todayStr,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> resetDailyCompletions() async {
    final db = await _dbHelper.database;
    final todayStr = du.formatDate(DateTime.now());
    await db.update(
      DatabaseTables.tableSelfCareItems,
      {'is_completed_today': 0},
      where: 'is_completed_today = 1 AND last_completed_date != ?',
      whereArgs: [todayStr],
    );
  }
}

