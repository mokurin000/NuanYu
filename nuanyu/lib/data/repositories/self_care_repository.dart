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

  /// Sets [lastCompletedDate] to today. The [SelfCareItem.completed] getter
  /// uses this field to decide whether the item is done for the current day.
  Future<void> markCompletedToday(String id) async {
    final db = await _dbHelper.database;
    final todayStr = du.formatDate(DateTime.now());
    await db.update(
      DatabaseTables.tableSelfCareItems,
      {'last_completed_date': todayStr},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
