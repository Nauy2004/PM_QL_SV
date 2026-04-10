import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';
import 'health_record.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  static int? currentUserId; // Lưu ID người dùng đang đăng nhập

  final _dbUpdateController = StreamController<void>.broadcast();
  Stream<void> get onDbUpdate => _dbUpdateController.stream;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('health_tracker_v2.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    // Bảng người dùng
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        full_name TEXT
      )
    ''');

    // Bảng chỉ số sức khỏe (có liên kết user_id)
    await db.execute('''
      CREATE TABLE health_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        weight REAL NOT NULL,
        height REAL NOT NULL,
        bmi REAL NOT NULL,
        category TEXT NOT NULL,
        created_at TEXT NOT NULL,
        note TEXT,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');
  }

  // --- Chức năng User ---
  Future<int> register(String username, String password, String fullName) async {
    final db = await instance.database;
    return await db.insert('users', {
      'username': username,
      'password': password,
      'full_name': fullName,
    });
  }

  Future<Map<String, dynamic>?> login(String username, String password) async {
    final db = await instance.database;
    final maps = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    if (maps.isNotEmpty) {
      currentUserId = maps.first['id'] as int;
      return maps.first;
    }
    return null;
  }

  // --- Chức năng Records (Đã lọc theo user_id) ---
  Future<int> insertRecord(HealthRecord record) async {
    final db = await instance.database;
    if (currentUserId == null) return -1;
    
    final data = record.toMap();
    data['user_id'] = currentUserId; // Gán ID người dùng hiện tại
    
    final id = await db.insert('health_records', data);
    _dbUpdateController.add(null);
    return id;
  }

  Future<List<HealthRecord>> getAllRecords() async {
    final db = await instance.database;
    if (currentUserId == null) return [];
    
    final result = await db.query(
      'health_records', 
      where: 'user_id = ?',
      whereArgs: [currentUserId],
      orderBy: 'created_at ASC'
    );
    return result.map((json) => HealthRecord.fromMap(json)).toList();
  }

  void logout() {
    currentUserId = null;
    _dbUpdateController.add(null);
  }
}
