import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('tasks.db');
    return _database!;
  }

  Future<void> deleteDatabaseFile() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'tasks.db');
    await deleteDatabase(path);  
  }

  Future<Database> _initDB(String filePath) async {
    await deleteDatabaseFile();  

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 2, onCreate: _createDB, onUpgrade: _onUpgradeDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        datetime TEXT NOT NULL
      )
    ''');
  }

  Future _onUpgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE tasks ADD COLUMN datetime TEXT NOT NULL DEFAULT "0000-00-00T00:00:00"');
    }
  }

  Future<List<Map<String, dynamic>>> getTasks() async {
    final db = await instance.database;
    return await db.query('tasks');
  }

  Future<void> insertTask(Map<String, dynamic> task) async {
    final db = await instance.database;

    if (!task.containsKey('datetime')) {
      task['datetime'] = DateTime.now().toIso8601String(); 
    }

    Map<String, dynamic> adjustedTask = {
      'title': task['title'],
      'description': task['description'],
      'datetime': task['datetime'],
    };

    await db.insert('tasks', adjustedTask);
  }

  Future<void> updateTask(Map<String, dynamic> task) async {
    final db = await instance.database;
    await db.update('tasks', task, where: 'id = ?', whereArgs: [task['id']]);
  }

  Future<void> deleteTask(int id) async {
    final db = await instance.database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }
}
