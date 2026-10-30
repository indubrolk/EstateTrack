
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'estate_track.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE workers (
            id INTEGER PRIMARY KEY,
            name TEXT NOT NULL,
            division TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE attendance (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            worker_id INTEGER NOT NULL,
            date TEXT NOT NULL,
            status TEXT NOT NULL,
            synced INTEGER NOT NULL DEFAULT 0,
            UNIQUE(worker_id, date),
            FOREIGN KEY(worker_id) REFERENCES workers(id)
          )
        ''');

        // Temporary sample data for development.
        final workers = [
          {'id': 1, 'name': 'Worker 001', 'division': 'A'},
          {'id': 2, 'name': 'Worker 002', 'division': 'A'},
          {'id': 3, 'name': 'Worker 003', 'division': 'A'},
        ];

        for (final worker in workers) {
          await db.insert('workers', worker);
        }
      },
    );

    return _database!;
  }

  Future<List<Map<String, Object?>>> getAttendance(
    String date,
  ) async {
    final db = await database;

    return db.rawQuery('''
      SELECT
        w.id,
        w.name,
        w.division,
        a.status
      FROM workers w
      LEFT JOIN attendance a
        ON w.id = a.worker_id
        AND a.date = ?
      ORDER BY w.name
    ''', [date]);
  }

  Future<void> saveAttendance({
    required int workerId,
    required String date,
    required String status,
  }) async {
    final db = await database;

    await db.insert(
      'attendance',
      {
        'worker_id': workerId,
        'date': date,
        'status': status,
        'synced': 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
