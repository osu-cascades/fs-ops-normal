import 'package:flutter/services.dart' show rootBundle;
import 'package:sqflite/sqflite.dart';

class DatabaseManager {

  static const SCHEMA_FILE_ASSET_PATH = 'assets/db/schema_1.sql.txt';
  static const DATABASE_FILENAME = 'ops_normal.sqlite3.db';
  static const SQL = {
    'engagements': {
      'selectAll': 'SELECT * FROM engagements ORDER BY createdAt DESC',
      'selectActive': 'SELECT * FROM engagements WHERE active = TRUE ORDER BY createdAt DESC',
      'selectInactive': 'SELECT * FROM engagements WHERE active = FALSE ORDER BY createdAt DESC',
      'selectOne': 'SELECT * FROM engagements WHERE id = ?',
      'insert': 'INSERT INTO engagements(name, createdAt, active) VALUES (?, ?, ?)',
      'deactivate': 'UPDATE engagements SET active = FALSE WHERE id = ?',
      'reactivate': 'UPDATE engagements SET active = TRUE WHERE id = ?',
      'delete': 'DELETE FROM engagements WHERE id = ?',
    }
  };

  static DatabaseManager? _instance;
  final Database db;

  DatabaseManager._({required Database database}) : db = database;

  factory DatabaseManager.getInstance() {
    if (_instance == null) {
      initialize();
    }
    return _instance!;
  }

  static Future initialize() async {
    final db = await openDatabase(DATABASE_FILENAME,
      version: 1,
      onCreate: (Database db, int _) async {
        createTables(db, _, await rootBundle.loadString(SCHEMA_FILE_ASSET_PATH));
      },
      onConfigure: _configure
    );
    _instance = DatabaseManager._(database: db);
  }

  static Future _configure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  static void createTables(Database db, int _, String sql) async {
    await db.execute(sql);
  }

  Future<List<Map<String, dynamic>>> select({required String sql}) {
    return db.rawQuery(sql);
  }

  void insert({required String sql, required List<dynamic> values}) {
    db.transaction((t) async {
      await t.rawInsert(sql, values);
    });
  }

  void delete({required String sql, required int id}) {
    db.transaction( (t) async {
      await t.rawDelete(sql, [id]);
    });
  }

  void update({required String sql, required List<dynamic> values}) {
    db.transaction((t) async {
      await t.rawUpdate(sql, values);
    });
  }

}
