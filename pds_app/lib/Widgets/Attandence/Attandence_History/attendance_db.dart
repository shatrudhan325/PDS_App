// lib/data/local/attendance_db.dart

import 'dart:async';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pds_app/Widgets/Attandence/Attandence_History/attendance_history_record.dart';
import 'package:sqflite/sqflite.dart';

class AttendanceDb {
  AttendanceDb._internal();
  static final AttendanceDb instance = AttendanceDb._internal();

  static const _dbName = 'attendance.db';
  static const _dbVersion = 1;
  static const _tableName = 'attendance';

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, _dbName);

    return await openDatabase(path, version: _dbVersion, onCreate: _onCreate);
  }

  FutureOr<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,        -- yyyy-MM-dd (start of day)
        check_in TEXT NOT NULL,    -- ISO8601
        check_out TEXT,            -- ISO8601 (nullable)
        location TEXT NOT NULL
      );
    ''');
  }

  /// CHECK-IN: create a new row for today
  Future<AttendanceHistoryRecord> checkIn({
    String location = 'Office HQ',
  }) async {
    final db = await database;

    final now = DateTime.now();
    final dateOnly = DateTime(now.year, now.month, now.day);

    final id = await db.insert(_tableName, {
      'date': dateOnly.toIso8601String(),
      'check_in': now.toIso8601String(),
      'check_out': null,
      'location': location,
    });

    return AttendanceHistoryRecord(
      id: id,
      date: dateOnly,
      checkInTime: now,
      checkOutTime: null,
      totalHours: 'Incomplete',
      status: RecordStatus.incomplete,
      location: location,
    );
  }

  /// CHECK-OUT: update the latest record of today that has no checkout yet
  Future<AttendanceHistoryRecord?> checkOut() async {
    final db = await database;

    final today = DateTime.now();
    final dayStart = DateTime(
      today.year,
      today.month,
      today.day,
    ).toIso8601String();

    // Find today's record without checkout (latest one)
    final rows = await db.query(
      _tableName,
      where: 'date = ? AND check_out IS NULL',
      whereArgs: [dayStart],
      orderBy: 'id DESC',
      limit: 1,
    );

    if (rows.isEmpty) {
      // No open record to checkout
      return null;
    }

    final map = Map<String, dynamic>.from(rows.first);
    final now = DateTime.now();

    await db.update(
      _tableName,
      {'check_out': now.toIso8601String()},
      where: 'id = ?',
      whereArgs: [map['id']],
    );

    map['check_out'] = now.toIso8601String();

    return AttendanceHistoryRecord.fromMap(map);
  }

  /// Get all records (for PastRecordsScreen)
  Future<List<AttendanceHistoryRecord>> getAllRecords() async {
    final db = await database;
    final rows = await db.query(_tableName, orderBy: 'date DESC, id DESC');

    return rows.map((m) => AttendanceHistoryRecord.fromMap(m)).toList();
  }

  /// Total completed days (if you ever need directly from DB)
  Future<int> getTotalCompletedDays() async {
    final db = await database;
    final rows = await db.rawQuery(
      'SELECT COUNT(*) AS cnt FROM $_tableName WHERE check_out IS NOT NULL',
    );
    return (rows.first['cnt'] as int?) ?? 0;
  }

  /// Delete all (for debugging)
  Future<void> clearAll() async {
    final db = await database;
    await db.delete(_tableName);
  }
}
