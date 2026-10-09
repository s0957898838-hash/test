import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/score.dart';

class ScoreRepository {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String dbPath = await getDatabasesPath();
    String path = join(dbPath, 'student_scores.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE scores(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            studentId TEXT,
            score INTEGER,
            subject TEXT,
            createdAt TEXT
          )
        ''');
      },
    );
  }

  Future<void> loadScores() async {
    await database;
  }

  Future<int> insertScore(Score score) async {
    final db = await database;
    return await db.insert('scores', score.toMap());
  }

  // เพิ่มฟังก์ชันแก้ไขข้อมูล (Update)
  Future<int> updateScore(Score score) async {
    final db = await database;
    return await db.update(
      'scores',
      score.toMap(),
      where: 'id = ?',
      whereArgs: [score.id],
    );
  }

  Future<List<Score>> getScores() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('scores', orderBy: 'createdAt DESC');
    return List.generate(maps.length, (i) => Score.fromMap(maps[i]));
  }

  Future<int> deleteScore(int id) async {
    final db = await database;
    return await db.delete('scores', where: 'id = ?', whereArgs: [id]);
  }
}